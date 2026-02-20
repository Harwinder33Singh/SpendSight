//
//  DashboardView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI
import CoreData
import Charts

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel = DashboardViewModel()
    
    // Fetch all data needed
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) private var allTransactions: FetchedResults<Transaction>
    
    @FetchRequest(fetchRequest: Category.fetchAll())
    private var categories: FetchedResults<Category>
    
    @State private var showManualEntry = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Budget overrun alerts
                        if !overBudgetCategories.isEmpty {
                            budgetAlertBanner
                        }
                        
                        // Spending summary cards
                        spendingSummarySection
                        
                        // Charts section
                        chartsSection
                        
                        // Budget progress
                        budgetProgressSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Space for floating button
                }
                .refreshable {
                    context.refreshAllObjects()
                }
                
                // Floating action button
                floatingAddButton
            }
            .navigationTitle("Dashboard")
            .sheet(isPresented: $showManualEntry) {
                ManualEntryView()
                    .environment(\.managedObjectContext, context)
            }
        }
    }
    
    // MARK: - Budget Alert Banner
    
    private var budgetAlertBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                
                Text("Budget Alert")
                    .font(.headline)
                    .foregroundStyle(.red)
                
                Spacer()
                
                Button {
                    // Dismiss all alerts
                    overBudgetCategories.forEach { category in
                        if let id = category.id?.uuidString {
                            viewModel.dismissAlert(for: id)
                        }
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            
            Text("You're over budget in \(overBudgetCategories.count) \(overBudgetCategories.count == 1 ? "category" : "categories")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ForEach(overBudgetCategories.prefix(3), id: \.objectID) { category in
                HStack {
                    Image(systemName: category.icon ?? "questionmark")
                        .foregroundStyle(category.color)
                    Text(category.name ?? "Unknown")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(budgetProgressPercentage(for: category)))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.red.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.red.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Spending Summary
    
    private var spendingSummarySection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Spending Summary")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                SummaryCard(
                    title: "Today",
                    amount: todayTotal,
                    icon: "calendar",
                    color: .blue
                )
                
                SummaryCard(
                    title: "This Week",
                    amount: thisWeekTotal,
                    icon: "calendar.badge.clock",
                    color: .purple
                )
                
                SummaryCard(
                    title: "This Month",
                    amount: thisMonthTotal,
                    icon: "calendar.circle",
                    color: .orange
                )
                
                SummaryCard(
                    title: "Daily Avg",
                    amount: dailyAverage,
                    icon: "chart.bar",
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Charts Section
    
    private var chartsSection: some View {
        VStack(spacing: 20) {
            // Top Categories Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Top Categories")
                    .font(.title2)
                    .fontWeight(.bold)
                
                CategorySpendingChart(
                    data: topCategoriesData,
                    viewModel: viewModel
                )
                .frame(height: 300)
            }
            
            // Spending Trend Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Spending Trend (30 Days)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                SpendingTrendChart(
                    dailyData: dailySpendingData,
                    movingAverage: movingAverageData
                )
                .frame(height: 250)
            }
        }
    }
    
    // MARK: - Budget Progress Section
    
    private var budgetProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Budget Progress")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            let categoriesWithBudgets = viewModel.categoriesWithBudgets(from: Array(categories))
            
            if categoriesWithBudgets.isEmpty {
                EmptyBudgetView()
            } else {
                VStack(spacing: 16) {
                    ForEach(categoriesWithBudgets, id: \.objectID) { category in
                        BudgetProgressRow(
                            category: category,
                            progress: budgetProgress(for: category),
                            viewModel: viewModel
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Floating Add Button
    
    private var floatingAddButton: some View {
        Button {
            showManualEntry = true
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                )
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Computed Properties
    
    private var transactions: [Transaction] {
        Array(allTransactions)
    }
    
    private var todayTotal: Double {
        viewModel.totalSpending(from: transactions, in: viewModel.todayRange)
    }
    
    private var thisWeekTotal: Double {
        viewModel.totalSpending(from: transactions, in: viewModel.thisWeekRange)
    }
    
    private var thisMonthTotal: Double {
        viewModel.totalSpending(from: transactions, in: viewModel.thisMonthRange)
    }
    
    private var dailyAverage: Double {
        viewModel.averageDailySpending(from: transactions, in: viewModel.thisMonthRange)
    }
    
    private var topCategoriesData: [(category: Category, amount: Double)] {
        viewModel.topCategories(from: transactions, in: viewModel.thisMonthRange, limit: 5)
    }
    
    private var dailySpendingData: [(date: Date, amount: Double)] {
        viewModel.dailySpending(from: transactions, in: viewModel.last30DaysRange)
    }
    
    private var movingAverageData: [(date: Date, average: Double)] {
        viewModel.calculateMovingAverage(data: dailySpendingData, window: 7)
    }
    
    private var overBudgetCategories: [Category] {
        viewModel.overBudgetCategories(from: Array(categories), transactions: transactions)
    }
    
    private func budgetProgress(for category: Category) -> (spent: Double, budget: Double, percentage: Double) {
        viewModel.budgetProgress(for: category, transactions: transactions)
    }
    
    private func budgetProgressPercentage(for category: Category) -> Double {
        budgetProgress(for: category).percentage
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
