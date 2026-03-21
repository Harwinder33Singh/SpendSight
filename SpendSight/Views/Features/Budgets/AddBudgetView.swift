//
//  AddBudgetView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 3/20/26.
//

import SwiftUI
import CoreData

struct AddBudgetView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    let categories: [Category]

    @State private var selectedCategory: Category?
    @State private var budgetAmount: String = ""
    @State private var showError = false
    @State private var errorMessage = ""

    private var availableCategories: [Category] {
        categories.filter { ($0.monthlyBudget ?? 0) <= 0 }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Category")) {
                    if availableCategories.isEmpty {
                        Text("All categories already have budgets")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(availableCategories, id: \.id) { category in
                            CategorySelectionRow(
                                category: category,
                                isSelected: selectedCategory?.id == category.id
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                }

                if selectedCategory != nil {
                    Section(header: Text("Budget Amount")) {
                        HStack {
                            Text(Locale.current.currencySymbol ?? "$")
                                .foregroundStyle(.secondary)

                            TextField("0", text: $budgetAmount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: budgetAmount) { _, newValue in
                                    budgetAmount = sanitizeBudgetInput(newValue)
                                }
                        }
                    }

                    Section(footer: budgetFooterText) {
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Add Budget")
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

    private var budgetFooterText: Text {
        if let category = selectedCategory,
           let amount = Double(budgetAmount),
           amount > 0 {
            let currentSpent = category.totalSpentThisMonth()
            let remaining = amount - currentSpent

            if remaining >= 0 {
                return Text("You have **\(formatCurrency(remaining))** remaining this month based on current spending of **\(formatCurrency(currentSpent))**.")
            } else {
                return Text("You are **\(formatCurrency(abs(remaining)))** over this budget based on current spending of **\(formatCurrency(currentSpent))**.")
            }
        }
        return Text("Enter a budget amount to see remaining balance.")
    }

    private var canSave: Bool {
        guard selectedCategory != nil,
              let amount = Double(budgetAmount),
              amount > 0,
              amount <= 9_999_999.99 else {
            return false
        }
        return true
    }

    private func saveBudget() {
        guard let category = selectedCategory,
              let amount = Double(budgetAmount),
              amount > 0 else {
            showError(message: "Please select a category and enter a valid budget amount.")
            return
        }

        guard amount <= 9_999_999.99 else {
            showError(message: "Budget amount cannot exceed \(formatCurrency(9_999_999.99)).")
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

    // MARK: - Input Sanitization

    /// Strips non-numeric characters (including minus signs) and enforces
    /// 8 integer digits max and 2 decimal places, preventing negative or
    /// unreasonably large budget amounts.
    private func sanitizeBudgetInput(_ input: String) -> String {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        let maxIntegerDigits = 8
        var filtered = ""
        var hasSeparator = false
        var decimals = 0
        var integers = 0
        for c in input {
            if c.isNumber {
                if hasSeparator {
                    decimals += 1
                    if decimals <= 2 { filtered.append(c) }
                } else {
                    integers += 1
                    if integers <= maxIntegerDigits { filtered.append(c) }
                }
            } else if String(c) == decimalSeparator && !hasSeparator {
                hasSeparator = true
                filtered.append(c)
            }
        }
        return filtered
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = Locale.current.currencySymbol ?? "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Category Selection Row

struct CategorySelectionRow: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: category.sfSymbol)
                    .font(.title2)
                    .foregroundStyle(category.color)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name ?? "Unknown")
                        .font(.body)
                        .foregroundStyle(.primary)

                    Text("\(category.transactionCount) transactions this month")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddBudgetView(categories: [])
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
