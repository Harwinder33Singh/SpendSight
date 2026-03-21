//
//  BudgetsView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI
import CoreData

struct BudgetsView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        predicate: NSPredicate(format: "monthlyBudget > 0"),
        animation: .default
    ) private var categoriesWithBudgets: FetchedResults<Category>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    ) private var allCategories: FetchedResults<Category>

    @State private var showingAddBudget = false
    @State private var showingBudgetDetail = false
    @State private var selectedCategory: Category?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Budget Overview Card
                    budgetOverviewCard

                    // Active Budgets Section
                    activeBudgetsSection

                    // Categories Without Budgets
                    if hasUnbudgetedCategories {
                        unbbudgetedCategoriesSection
                    }
                }
                .padding()
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBudget = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView(categories: Array(allCategories))
                    .environment(\.managedObjectContext, context)
            }
            .sheet(isPresented: $showingBudgetDetail) {
                if let category = selectedCategory {
                    BudgetDetailView(category: category)
                        .environment(\.managedObjectContext, context)
                }
            }
        }
    }

    // MARK: - Budget Overview Card

    private var budgetOverviewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Month")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Total Budget")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(totalBudgetFormatted)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(totalSpentFormatted)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(totalSpent > totalBudget ? .red : .primary)
                }
            }

            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(totalRemainingFormatted)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(totalRemaining < 0 ? .red : .green)
                }

                ProgressView(value: min(totalSpent / max(totalBudget, 1), 1.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Active Budgets Section

    private var activeBudgetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Active Budgets")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("\(categoriesWithBudgets.count) categories")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if categoriesWithBudgets.isEmpty {
                emptyBudgetsView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(categoriesWithBudgets, id: \.id) { category in
                        BudgetCategoryCard(category: category) {
                            selectedCategory = category
                            showingBudgetDetail = true
                        }
                    }
                }
            }
        }
    }

    private var emptyBudgetsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Active Budgets")
                .font(.headline)
                .foregroundStyle(.primary)

            Text("Set budgets for your categories to track spending")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Add Your First Budget") {
                showingAddBudget = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .stroke(.quaternary, lineWidth: 1)
        )
    }

    // MARK: - Unbudgeted Categories Section

    private var unbbudgetedCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categories Without Budgets")
                .font(.title3)
                .fontWeight(.semibold)

            LazyVStack(spacing: 8) {
                ForEach(unbudgetedCategories, id: \.id) { category in
                    UnbudgetedCategoryRow(category: category) {
                        selectedCategory = category
                        showingAddBudget = true
                    }
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var totalBudget: Double {
        categoriesWithBudgets.reduce(0) { $0 + ($1.monthlyBudget ?? 0) }
    }

    private var totalSpent: Double {
        categoriesWithBudgets.reduce(0) { $0 + $1.totalSpentThisMonth() }
    }

    private var totalRemaining: Double {
        totalBudget - totalSpent
    }

    private var totalBudgetFormatted: String {
        formatCurrency(totalBudget)
    }

    private var totalSpentFormatted: String {
        formatCurrency(totalSpent)
    }

    private var totalRemainingFormatted: String {
        formatCurrency(totalRemaining)
    }

    private var progressColor: Color {
        let percentage = totalSpent / max(totalBudget, 1)
        if percentage >= 1.0 {
            return .red
        } else if percentage >= 0.8 {
            return .orange
        } else {
            return .green
        }
    }

    private var hasUnbudgetedCategories: Bool {
        !unbudgetedCategories.isEmpty
    }

    private var unbudgetedCategories: [Category] {
        allCategories.filter { ($0.monthlyBudget ?? 0) <= 0 }
    }

    private func formatCurrency(_ amount: Double) -> String {
        return CurrencyService.shared.formatAmountWithoutDecimals(amount)
    }
}

// MARK: - Budget Category Card

struct BudgetCategoryCard: View {
    let category: Category
    let onTap: () -> Void

    private var spentThisMonth: Double {
        category.totalSpentThisMonth()
    }

    private var budget: Double {
        category.monthlyBudget ?? 0
    }

    private var remaining: Double {
        budget - spentThisMonth
    }

    private var usagePercentage: Double {
        guard budget > 0 else { return 0 }
        return min(spentThisMonth / budget, 1.0)
    }

    private var progressColor: Color {
        if category.isOverBudget() {
            return .red
        } else if usagePercentage >= 0.8 {
            return .orange
        } else {
            return .green
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    // Category Icon and Name
                    HStack(spacing: 12) {
                        Image(systemName: category.sfSymbol)
                            .font(.title2)
                            .foregroundStyle(category.color)
                            .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(category.name ?? "Unknown")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text("\(category.transactionCount) transactions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }

                    // Amount Info
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatCurrency(spentThisMonth))
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("of \(formatCurrency(budget))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Progress Bar and Status
                VStack(spacing: 6) {
                    HStack {
                        Text(category.isOverBudget() ? "Over budget" : "Remaining")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(formatCurrency(abs(remaining)))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(category.isOverBudget() ? .red : .green)
                    }

                    ProgressView(value: usagePercentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thinMaterial)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formatCurrency(_ amount: Double) -> String {
        return CurrencyService.shared.formatAmountWithoutDecimals(amount)
    }
}

// MARK: - Unbudgeted Category Row

struct UnbudgetedCategoryRow: View {
    let category: Category
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: category.sfSymbol)
                    .font(.title3)
                    .foregroundStyle(category.color)
                    .frame(width: 24, height: 24)

                Text(category.name ?? "Unknown")
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.thinMaterial)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BudgetsView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
