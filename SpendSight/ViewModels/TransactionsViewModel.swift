//
//  TransactionsViewModel.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/19/26.
//

import SwiftUI
import CoreData
import Combine

@MainActor
class TransactionsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var searchText: String = ""
    @Published var selectedDateFilter: DateFilter = .all
    @Published var selectedCategories: Set<NSManagedObjectID> = []
    @Published var selectedAccounts: Set<NSManagedObjectID> = []
    @Published var minAmount: String = ""
    @Published var maxAmount: String = ""
    @Published var showFilterSheet: Bool = false
    @Published var showDeleteConfirmation: Bool = false
    @Published var transactionToDelete: Transaction?
    
    // MARK: - Computed Properties
    
    var hasActiveFilters: Bool {
        selectedDateFilter != .all ||
        !selectedCategories.isEmpty ||
        !selectedAccounts.isEmpty ||
        !minAmount.isEmpty ||
        !maxAmount.isEmpty
    }
    
    var activeFilterCount: Int {
        var count = 0
        if selectedDateFilter != .all { count += 1 }
        if !selectedCategories.isEmpty { count += 1 }
        if !selectedAccounts.isEmpty { count += 1 }
        if !minAmount.isEmpty || !maxAmount.isEmpty { count += 1 }
        return count
    }
    
    // MARK: - Filter Management
    
    func clearFilters() {
        selectedDateFilter = .all
        selectedCategories.removeAll()
        selectedAccounts.removeAll()
        minAmount = ""
        maxAmount = ""
    }
    
    func toggleCategory(_ objectID: NSManagedObjectID) {
        if selectedCategories.contains(objectID) {
            selectedCategories.remove(objectID)
        } else {
            selectedCategories.insert(objectID)
        }
    }
    
    func toggleAccount(_ objectID: NSManagedObjectID) {
        if selectedAccounts.contains(objectID) {
            selectedAccounts.remove(objectID)
        } else {
            selectedAccounts.insert(objectID)
        }
    }
    
    // MARK: - Predicate Building
    
    func buildPredicate() -> NSPredicate? {
        var predicates: [NSPredicate] = []
        
        // Date filter
        if selectedDateFilter != .all {
            let dateRange = selectedDateFilter.dateRange
            predicates.append(NSPredicate(
                format: "(date >= %@) AND (date <= %@)",
                dateRange.start as NSDate,
                dateRange.end as NSDate
            ))
        }
        
        // Category filter
        if !selectedCategories.isEmpty {
            let categoryPredicate = NSPredicate(
                format: "category IN %@",
                Array(selectedCategories)
            )
            predicates.append(categoryPredicate)
        }
        
        // Account filter
        if !selectedAccounts.isEmpty {
            let accountPredicate = NSPredicate(
                format: "account IN %@",
                Array(selectedAccounts)
            )
            predicates.append(accountPredicate)
        }
        
        // Amount filter
        if let min = Double(minAmount) {
            predicates.append(NSPredicate(format: "ABS(amount) >= %f", min))
        }
        if let max = Double(maxAmount) {
            predicates.append(NSPredicate(format: "ABS(amount) <= %f", max))
        }
        
        // Search filter
        if !searchText.isEmpty {
            let searchPredicate = NSPredicate(
                format: "title CONTAINS[cd] %@ OR merchant CONTAINS[cd] %@ OR notes CONTAINS[cd] %@",
                searchText, searchText, searchText
            )
            predicates.append(searchPredicate)
        }
        
        return predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    /// Returns true when a transaction matches currently selected filters.
    func matchesFilters(_ transaction: Transaction) -> Bool {
        // Date filter
        if selectedDateFilter != .all {
            guard let date = transaction.date else { return false }
            let dateRange = selectedDateFilter.dateRange
            if date < dateRange.start || date > dateRange.end {
                return false
            }
        }
        
        // Category filter
        if !selectedCategories.isEmpty {
            guard let categoryID = transaction.category?.objectID,
                  selectedCategories.contains(categoryID) else {
                return false
            }
        }
        
        // Account filter
        if !selectedAccounts.isEmpty {
            guard let accountID = transaction.account?.objectID,
                  selectedAccounts.contains(accountID) else {
                return false
            }
        }
        
        // Amount range filter (absolute value for both income/expense)
        let absoluteAmount = abs(transaction.amount)
        if let min = parsedAmount(from: minAmount), absoluteAmount < min {
            return false
        }
        if let max = parsedAmount(from: maxAmount), absoluteAmount > max {
            return false
        }
        
        // Search filter
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            let query = trimmedSearch.lowercased()
            let fields = [
                transaction.title ?? "",
                transaction.merchant ?? "",
                transaction.notes ?? "",
                transaction.category?.name ?? "",
                transaction.account?.name ?? ""
            ]
            
            let hasMatch = fields.contains { $0.lowercased().contains(query) }
            if !hasMatch {
                return false
            }
        }
        
        return true
    }
    
    private func parsedAmount(from raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        if let direct = Double(trimmed) {
            return direct
        }
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        if let localized = formatter.number(from: trimmed)?.doubleValue {
            return localized
        }
        
        // Fallback for values like "$1,234.56"
        let allowed = Set("0123456789.,")
        let cleaned = String(trimmed.filter { allowed.contains($0) })
            .replacingOccurrences(of: ",", with: "")
        return Double(cleaned)
    }
    
    // MARK: - Delete Transaction
    
    func deleteTransaction(_ transaction: Transaction, context: NSManagedObjectContext) {
        context.delete(transaction)
        
        do {
            try context.save()
            print("✅ Transaction deleted")
        } catch {
            print("❌ Delete failed: \(error)")
        }
    }
}

// MARK: - Date Filter

enum DateFilter: String, CaseIterable, Identifiable {
    case all = "All Time"
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "This Week"
    case lastWeek = "Last Week"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case custom = "Custom Range"
    
    var id: String { rawValue }
    
    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .all:
            return (Date.distantPast, Date.distantFuture)
            
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
            
        case .yesterday:
            let start = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!
            let end = calendar.startOfDay(for: now)
            return (start, end)
            
        case .thisWeek:
            let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
            return (start, end)
            
        case .lastWeek:
            let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let start = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)!
            let end = thisWeekStart
            return (start, end)
            
        case .thisMonth:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
            
        case .lastMonth:
            let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let start = calendar.date(byAdding: .month, value: -1, to: thisMonthStart)!
            let end = thisMonthStart
            return (start, end)
            
        case .custom:
            return (Date.distantPast, Date.distantFuture)
        }
    }
}
