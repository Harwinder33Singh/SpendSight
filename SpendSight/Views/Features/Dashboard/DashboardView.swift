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
                        
                        // Spending summary cards
                        spendingSummarySection
                        
                        // Charts section
                        chartsSection
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
    
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
