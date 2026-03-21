//
//  BudgetDetailView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 3/20/26.
//

import SwiftUI
import CoreData

struct BudgetDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var category: Category

    @State private var showingEditBudget = false
    @State private var editBudgetAmount: String = ""
    @State private var showDeleteAlert = false

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

    private var transactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return []
        }

        return category.transactionsArray.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= startOfMonth && date <= endOfMonth && transaction.isExpense
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Budget Overview Card
                    budgetOverviewCard

                    // Budget Stats
                    budgetStatsSection

                    // Recent Transactions
                    recentTransactionsSection
                }
                .padding()
            }
            .navigationTitle(category.name ?? "Budget")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            editBudgetAmount = String(format: "%.0f", budget)
                            showingEditBudget = true
                        }) {
                            Label("Edit Budget", systemImage: "pencil")
                        }

                        Button(role: .destructive, action: {
                            showDeleteAlert = true
                        }) {
                            Label("Remove Budget", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditBudget) {
                EditBudgetSheet(
                    category: category,
                    budgetAmount: $editBudgetAmount
                )
            }
            .alert("Remove Budget", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    removeBudget()
                }
            } message: {
                Text("Are you sure you want to remove the budget for \(category.name ?? "this category")? This action cannot be undone.")
            }
        }
    }

    // MARK: - Budget Overview Card

    private var budgetOverviewCard: some View {
        VStack(spacing: 16) {
            // Category Header
            HStack {
                Image(systemName: category.sfSymbol)
                    .font(.title)
                    .foregroundStyle(category.color)

                VStack(alignment: .leading) {
                    Text(category.name ?? "Unknown")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(transactions.count) transactions this month")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

            // Amount Summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatCurrency(spentThisMonth))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }

                Spacer()

                VStack(alignment: .center, spacing: 4) {
                    Text("of")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("/")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Budget")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatCurrency(budget))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
            }

            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
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

    // MARK: - Budget Stats Section

    private var budgetStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Statistics")
                .font(.title3)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Daily Average",
                    value: formatCurrency(dailyAverage),
                    icon: "calendar.day.timeline.left",
                    color: .blue
                )

                StatCard(
                    title: "Projected Total",
                    value: formatCurrency(projectedTotal),
                    icon: "chart.line.uptrend.xyaxis",
                    color: projectedTotal > budget ? .red : .green
                )

                StatCard(
                    title: "Days Remaining",
                    value: "\(daysRemaining)",
                    icon: "clock",
                    color: .orange
                )

                StatCard(
                    title: "Daily Budget",
                    value: formatCurrency(dailyBudget),
                    icon: "dollarsign.circle",
                    color: .purple
                )
            }
        }
    }

    // MARK: - Recent Transactions Section

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This Month's Transactions")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(transactions.count) total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if transactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)

                    Text("No transactions this month")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(transactions.prefix(10), id: \.id) { transaction in
                        BudgetTransactionRow(transaction: transaction)
                    }

                    if transactions.count > 10 {
                        Text("and \(transactions.count - 10) more...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top)
                    }
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var progressColor: Color {
        if category.isOverBudget() {
            return .red
        } else if usagePercentage >= 0.8 {
            return .orange
        } else {
            return .green
        }
    }

    private var dailyAverage: Double {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return 0
        }

        let daysElapsed = calendar.dateComponents([.day], from: startOfMonth, to: now).day ?? 1
        return spentThisMonth / Double(max(daysElapsed, 1))
    }

    private var projectedTotal: Double {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return spentThisMonth
        }

        let totalDaysInMonth = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day ?? 30
        return dailyAverage * Double(totalDaysInMonth)
    }

    private var daysRemaining: Int {
        let calendar = Calendar.current
        let now = Date()
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1),
                                           to: calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now) else {
            return 0
        }

        return max(calendar.dateComponents([.day], from: now, to: endOfMonth).day ?? 0, 0)
    }

    private var dailyBudget: Double {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return budget / 30
        }

        let totalDaysInMonth = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day ?? 30
        return budget / Double(totalDaysInMonth)
    }

    // MARK: - Helper Methods

    private func removeBudget() {
        category.monthlyBudget = 0
        context.saveIfNeeded()
        dismiss()
    }

    private func formatCurrency(_ amount: Double) -> String {
        return CurrencyService.shared.formatAmountWithoutDecimals(amount)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
}

struct BudgetTransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title ?? "Unknown")
                    .font(.body)
                    .fontWeight(.medium)

                Text(transaction.merchant ?? "Unknown")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(transaction.formattedAmount)
                    .font(.body)
                    .fontWeight(.medium)

                Text(transaction.shortDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.thinMaterial)
        )
    }
}

struct EditBudgetSheet: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var category: Category
    @Binding var budgetAmount: String

    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Budget Amount")) {
                    HStack {
                        Text(Locale.current.currencySymbol ?? "$")
                            .foregroundStyle(.secondary)

                        TextField("0", text: $budgetAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }

                Section(footer: footerText) {
                    EmptyView()
                }
            }
            .navigationTitle("Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBudget()
                    }
                    .disabled(!canSave)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var footerText: Text {
        if let amount = Double(budgetAmount), amount > 0 {
            let currentSpent = category.totalSpentThisMonth()
            let remaining = amount - currentSpent

            if remaining >= 0 {
                return Text("You will have **\(formatCurrency(remaining))** remaining this month based on current spending of **\(formatCurrency(currentSpent))**.")
            } else {
                return Text("You will be **\(formatCurrency(abs(remaining)))** over this budget based on current spending of **\(formatCurrency(currentSpent))**.")
            }
        }
        return Text("Enter a budget amount to see the impact.")
    }

    private var canSave: Bool {
        guard let amount = Double(budgetAmount), amount > 0 else {
            return false
        }
        return true
    }

    private func saveBudget() {
        guard let amount = Double(budgetAmount), amount > 0 else {
            showError(message: "Please enter a valid budget amount.")
            return
        }

        category.monthlyBudget = amount

        do {
            try context.save()
            dismiss()
        } catch {
            showError(message: "Failed to save budget: \(error.localizedDescription)")
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }

    private func formatCurrency(_ amount: Double) -> String {
        return CurrencyService.shared.formatAmountWithoutDecimals(amount)
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    let category = Category(context: context, name: "Groceries", colorHex: "#4CAF50", icon: "cart.fill", monthlyBudget: 500)

    return BudgetDetailView(category: category)
        .environment(\.managedObjectContext, context)
}