//
//  ManualEntryView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/14/26.
//

import SwiftUI
import CoreData

struct ManualEntryView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?

    enum Field {
        case amount, merchant, title, notes
    }

    // MARK: - State Variables
    @State private var amountString: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedCategory: Category? = nil
    @State private var selectedAccount: Account? = nil
    @State private var merchant: String = ""
    @State private var titleText: String = ""
    @State private var notes: String = ""
    @State private var paymentMethod: String = "Credit Card"
    @State private var showValidationError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isSaving: Bool = false
    @State private var showSuccess: Bool = false
    @State private var showResetConfirmation: Bool = false

    // MARK: - Constants
    private let paymentMethods = ["Credit Card", "Debit Card", "Cash", "Other"]
    private let lastAccountIDKey = "lastAccountID"
    private let lastPaymentMethodKey = "lastPaymentMethod"

    // MARK: - Fetch Requests
    @FetchRequest(fetchRequest: Category.fetchAll())
    private var categories: FetchedResults<Category>

    @FetchRequest(fetchRequest: Account.fetchAll())
    private var accounts: FetchedResults<Account>

    // MARK: - Computed Properties
    private var isIncomeCategory: Bool {
        guard let categoryName = selectedCategory?.name?.lowercased() else { return false }
        return categoryName == "income"
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Details") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        CurrencyTextField(
                            title: "0.00",
                            text: $amountString,
                            focusedField: $focusedField
                        )
                        .multilineTextAlignment(.trailing)
                    }

                    DatePicker(
                        "Date",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                }

                Section("Category & Account") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if categories.isEmpty {
                            Text("No categories available")
                                .foregroundStyle(.secondary)
                        } else {
                            CategoryPickerView(
                                categories: categories,
                                selected: $selectedCategory
                            )
                        }
                    }
                    .padding(.vertical, 4)

                    if !isIncomeCategory {
                        Picker("Payment Method", selection: $paymentMethod) {
                            ForEach(paymentMethods, id: \.self) { method in
                                Text(method).tag(method)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: paymentMethod) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: lastPaymentMethodKey)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if accounts.isEmpty {
                            Text("No accounts available")
                                .foregroundStyle(.secondary)
                        } else {
                            AccountPickerView(
                                accounts: accounts,
                                selected: $selectedAccount
                            ) { account in
                                if let account = account {
                                    UserDefaults.standard.set(
                                        account.objectID.uriRepresentation().absoluteString,
                                        forKey: lastAccountIDKey
                                    )
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Additional Details") {
                    TextField("Merchant (optional)", text: $merchant)
                        .textInputAutocapitalization(.words)
                        .focused($focusedField, equals: .merchant)

                    TextField("Title (optional)", text: $titleText)
                        .textInputAutocapitalization(.words)
                        .focused($focusedField, equals: .title)
                }

                Section {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                        .focused($focusedField, equals: .notes)
                        .onChange(of: notes) { newValue in
                            if newValue.count > 200 {
                                notes = String(newValue.prefix(200))
                            }
                        }
                } header: {
                    Text("Notes")
                } footer: {
                    HStack {
                        Spacer()
                        Text("\(notes.count)/200")
                            .foregroundStyle(notes.count > 180 ? .orange : .secondary)
                    }
                }

                Section {
                    Button {
                        saveTransaction()
                    } label: {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Text("Save Transaction")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isSaving || !isFormValid)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset Form")
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                    .disabled(isSaving)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .confirmationDialog("Clear all fields?", isPresented: $showResetConfirmation) {
                        Button("Clear All Fields", role: .destructive) {
                            resetForm()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("This will clear all entered information.")
                    }
                }
                .padding(.horizontal)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(successOverlay)
            .alert("Error", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadSavedPreferences()
            }
        }
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        Group {
            if showSuccess {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.green)

                        Text("Transaction Saved!")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .padding(32)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        guard let amount = parseAmount(), amount > 0 else { return false }
        guard selectedCategory != nil else { return false }
        guard selectedAccount != nil else { return false }
        return true
    }

    // MARK: - Helper Methods

    private func loadSavedPreferences() {
        // Load last payment method
        if let savedMethod = UserDefaults.standard.string(forKey: lastPaymentMethodKey) {
            paymentMethod = savedMethod
        }

        // Load last account
        if let lastAccountIDString = UserDefaults.standard.string(forKey: lastAccountIDKey),
           let url = URL(string: lastAccountIDString),
           let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
            selectedAccount = accounts.first(where: { $0.objectID == objectID })
        }
    }

    private func parseAmount() -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        return formatter.number(from: amountString)?.doubleValue
    }

    private func validateForm() -> Bool {
        focusedField = nil

        guard let amount = parseAmount(), amount > 0 else {
            errorMessage = "Amount must be greater than 0"
            showValidationError = true
            return false
        }

        guard selectedDate <= Date() else {
            errorMessage = "Date cannot be in the future"
            showValidationError = true
            return false
        }

        guard selectedCategory != nil else {
            errorMessage = "Please select a category"
            showValidationError = true
            return false
        }

        guard selectedAccount != nil else {
            errorMessage = "Please select an account"
            showValidationError = true
            return false
        }

        return true
    }

    private func saveTransaction() {
        guard validateForm(),
              let category = selectedCategory,
              let account = selectedAccount,
              let rawAmount = parseAmount()
        else { return }

        isSaving = true

        let isIncome = (category.name?.lowercased() ?? "") == "income"
        let signedAmount = isIncome ? rawAmount : -abs(rawAmount)

        let finalTitle: String
        if !titleText.isEmpty {
            finalTitle = titleText.trimmingCharacters(in: .whitespaces)
        } else if !merchant.isEmpty {
            finalTitle = merchant.trimmingCharacters(in: .whitespaces)
        } else {
            finalTitle = isIncome ? "Income" : "Expense"
        }

        let finalPaymentMethod = isIncome ? "N/A" : paymentMethod

        let _ = Transaction(
            context: context,
            amount: signedAmount,
            title: finalTitle,
            merchant: merchant.isEmpty ? finalTitle : merchant.trimmingCharacters(in: .whitespaces),
            date: selectedDate,
            notes: notes.isEmpty ? nil : notes,
            paymentMethod: finalPaymentMethod,
            isRecurring: false,
            category: category,
            account: account
        )

        do {
            try context.save()

            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showSuccess = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.2)) {
                    showSuccess = false
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    resetForm()
                    isSaving = false
                }
            }

        } catch {
            isSaving = false
            errorMessage = "Failed to save transaction: \(error.localizedDescription)"
            showValidationError = true
        }
    }

    private func resetForm() {
        amountString = ""
        selectedDate = Date()
        selectedCategory = nil
        merchant = ""
        titleText = ""
        notes = ""

        loadSavedPreferences()
        focusedField = nil
    }
}

#Preview {
    ManualEntryView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
