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

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) private var allTransactions: FetchedResults<Transaction>

    @FetchRequest(fetchRequest: Category.fetchAll())
    private var categories: FetchedResults<Category>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Income.date, ascending: false)]
    ) private var allIncomes: FetchedResults<Income>

    @AppStorage("lastPlaidSync") private var lastSyncTimestamp: Double = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Sync status
                    HStack {
                        Image(systemName: "building.columns.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(lastSyncText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }

                    spendingSummarySection
                    chartsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .refreshable {
                context.refreshAllObjects()
            }
            .navigationTitle("Dashboard")
        }
    }

    // MARK: - Sync Text

    private var lastSyncText: String {
        guard lastSyncTimestamp > 0 else { return "Never synced" }
        let date = Date(timeIntervalSince1970: lastSyncTimestamp)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Synced \(formatter.localizedString(for: date, relativeTo: Date()))"
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
                SummaryCard(title: "Today",      amount: todayTotal,     icon: "calendar",             color: .blue)
                SummaryCard(title: "This Week",  amount: thisWeekTotal,  icon: "calendar.badge.clock", color: .purple)
                SummaryCard(title: "This Month", amount: thisMonthTotal, icon: "calendar.circle",      color: .orange)
                SummaryCard(title: "Daily Avg",  amount: dailyAverage,   icon: "chart.bar",            color: .green)
            }
        }
    }

    // MARK: - Charts Section

    private var chartsSection: some View {
        VStack(spacing: 20) {

            // Top Categories donut
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

            // 30-day area trend (replaces SpendingTrendChart)
            VStack(alignment: .leading, spacing: 12) {
                Text("Spending Trend (30 Days)")
                    .font(.title2)
                    .fontWeight(.bold)

                AreaTrendChart(
                    dailyData: dailySpendingData,
                    movingAverage: movingAverageData
                )
            }

            // 6-month income vs expenses bars
            VStack(alignment: .leading, spacing: 12) {
                Text("Monthly Overview")
                    .font(.title2)
                    .fontWeight(.bold)

                MonthlyBarsChart(data: monthlyBarDataPoints)
            }
        }
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

    private var monthlyBarDataPoints: [MonthlyBarData] {
        viewModel.monthlyBarData(
            from: Array(allTransactions),
            incomes: Array(allIncomes),
            months: 6
        )
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
