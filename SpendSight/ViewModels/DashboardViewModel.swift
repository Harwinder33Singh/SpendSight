//
//  DashboardViewModel.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/19/26.
//

import SwiftUI
import CoreData
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var dismissedAlerts: Set<String> = []
    @Published var isLoading: Bool = false
    
    // MARK: - Computed Properties
    
    var hasOverBudgetCategories: Bool {
        !overBudgetCategories.isEmpty
    }
    
    var overBudgetCategories: [Category] {
        []  // Will be calculated from actual data
    }
    
    // MARK: - Date Ranges
    
    var todayRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return (start, end)
    }
    
    var thisWeekRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start) ?? calendar.date(byAdding: .day, value: 7, to: start)!
        return (start, end)
    }
    
    var thisMonthRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .month, value: 1, to: start) ?? calendar.date(byAdding: .day, value: 30, to: start)!
        return (start, end)
    }
    
    var last30DaysRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -29, to: todayStart) ?? calendar.date(byAdding: .day, value: -29, to: Date())!
        let end = calendar.date(byAdding: .day, value: 1, to: todayStart) ?? calendar.date(byAdding: .day, value: 1, to: Date())!
        return (start, end)
    }
    
    // MARK: - Calculations
    
    func totalSpending(from transactions: [Transaction], in range: (start: Date, end: Date)) -> Double {
        transactions
            .filter { transaction in
                guard let date = transaction.date else { return false }
                return date >= range.start && date < range.end && transaction.isExpense
            }
            .reduce(0) { $0 + abs($1.amount) }
    }
    
    func averageDailySpending(from transactions: [Transaction], in range: (start: Date, end: Date)) -> Double {
        let total = totalSpending(from: transactions, in: range)
        let days = Calendar.current.dateComponents([.day], from: range.start, to: range.end).day ?? 1
        return total / Double(max(days, 1))
    }
    
    func topCategories(from transactions: [Transaction], in range: (start: Date, end: Date), limit: Int = 5) -> [(category: Category, amount: Double)] {
        // Filter to expense transactions in the provided date range
        let expensesInRange: [Transaction] = transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= range.start && date < range.end && transaction.isExpense
        }

        // Group by Category objectID, filtering out nil categories
        let expensesWithCategories = expensesInRange.compactMap { txn -> (NSManagedObjectID, Transaction)? in
            guard let categoryID = txn.category?.objectID else { return nil }
            return (categoryID, txn)
        }

        let groupedByCategoryID: [NSManagedObjectID: [Transaction]] = Dictionary(grouping: expensesWithCategories) { tuple in
            tuple.0
        }.mapValues { tuples in
            tuples.map { $0.1 }
        }

        // Compute totals per category and map back to actual Category objects
        var results: [(category: Category, amount: Double)] = []
        results.reserveCapacity(groupedByCategoryID.count)

        for (_, txns) in groupedByCategoryID {
            // Safely unwrap a category from this bucket; skip if missing
            guard let category = txns.first?.category else { continue }
            let total: Double = txns.reduce(0.0) { partial, t in
                partial + abs(t.amount)
            }
            results.append((category: category, amount: total))
        }

        // Sort by amount descending and take the requested limit
        return results
            .sorted { $0.amount > $1.amount }
            .prefix(limit)
            .map { $0 }
    }
    
    func dailySpending(from transactions: [Transaction], in range: (start: Date, end: Date)) -> [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        let expensesInRange = transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= range.start && date < range.end && transaction.isExpense
        }
        
        let dailyTotals = Dictionary(grouping: expensesInRange) { transaction -> Date in
            guard let date = transaction.date else { return Date() }
            return calendar.startOfDay(for: date)
        }.mapValues { transactions in
            transactions.reduce(0.0) { $0 + abs($1.amount) }
        }
        
        // Fill in missing days with 0 using start-of-day keys
        var result: [(date: Date, amount: Double)] = []
        var currentDate = calendar.startOfDay(for: range.start)
        let endDate = calendar.startOfDay(for: range.end)
        
        while currentDate < endDate {
            let amount = dailyTotals[currentDate] ?? 0
            result.append((date: currentDate, amount: amount))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return result.sorted { $0.date < $1.date }
    }
    
    func calculateMovingAverage(data: [(date: Date, amount: Double)], window: Int = 7) -> [(date: Date, average: Double)] {
        guard data.count >= window else { return [] }
        
        var result: [(date: Date, average: Double)] = []
        
        for i in (window - 1)..<data.count {
            let windowData = Array(data[(i - window + 1)...i])
            let average = windowData.reduce(0.0) { $0 + $1.amount } / Double(window)
            result.append((date: data[i].date, average: average))
        }
        
        return result
    }
    
    func budgetProgress(for category: Category, transactions: [Transaction]) -> (spent: Double, budget: Double, percentage: Double) {
        let budget = category.monthlyBudget ?? 0
        guard budget > 0 else { return (0, 0, 0) }
        
        let range = thisMonthRange
        let spent = transactions
            .filter { transaction in
                guard let date = transaction.date,
                      let transactionCategory = transaction.category else { return false }
                return date >= range.start &&
                       date < range.end &&
                       transaction.isExpense &&
                       transactionCategory.objectID == category.objectID
            }
            .reduce(0) { $0 + abs($1.amount) }
        
        let percentage = (spent / budget) * 100
        return (spent: spent, budget: budget, percentage: percentage)
    }
    
    func categoriesWithBudgets(from categories: [Category]) -> [Category] {
        categories.filter { ($0.monthlyBudget ?? 0) > 0 }
    }
    
    func overBudgetCategories(from categories: [Category], transactions: [Transaction]) -> [Category] {
        categoriesWithBudgets(from: categories).filter { category in
            let progress = budgetProgress(for: category, transactions: transactions)
            return progress.percentage > 100
        }
    }
    
    // MARK: - Alert Management
    
    func dismissAlert(for categoryID: String) {
        dismissedAlerts.insert(categoryID)
    }
    
    func shouldShowAlert(for categoryID: String) -> Bool {
        !dismissedAlerts.contains(categoryID)
    }
}
