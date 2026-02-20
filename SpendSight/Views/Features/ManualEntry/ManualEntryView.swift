//
//  ManualEntryView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/14/26.
//

//
//  ManualEntryView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/14/26.
//  FIXED: Payment method order, conditional display, removed Done button
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
    @State private var paymentMethod: String = "Other"
    @State private var isRecurring: Bool = false
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
    
    /// Check if selected category is Income (hide payment method for income)
    private var isIncomeCategory: Bool {
        guard let categoryName = selectedCategory?.name?.lowercased() else { return false }
        return categoryName == "income"
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    amountSection
                    dateSection
                    categorySection
                    
                    // Show payment method right after category (but only for expenses)
                    if !isIncomeCategory {
                        paymentMethodSection
                    }
                    
                    accountSection
                    detailsSection
                    notesSection
                    recurringSection
                    actionButtons
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            // REMOVED: Done button from toolbar
            .overlay(successOverlay)
            .alert("Validation Error", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadSavedPreferences()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
        }
    }
    
    // MARK: - Form Sections
    
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount *")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            CurrencyTextField(
                title: "Enter amount",
                text: $amountString,
                focusedField: $focusedField
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 16)
            
            DatePicker(
                "Transaction Date",
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: [.date]
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category *")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 16)
            
            if categories.isEmpty {
                Text("No categories available. Please add categories first.")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            } else {
                CategoryPickerView(
                    categories: categories,
                    selected: $selectedCategory
                )
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .background(Color(.systemBackground))
    }
    
    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Payment Method")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 16)
            
            Picker("Method", selection: $paymentMethod) {
                ForEach(paymentMethods, id: \.self) { method in
                    Text(method).tag(method)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .onChange(of: paymentMethod) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: lastPaymentMethodKey)
            }
        }
        .background(Color(.systemBackground))
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Account *")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 16)
            
            if accounts.isEmpty {
                Text("No accounts available. Please add an account first.")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
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
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Details")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 16)
            
            TextField("Merchant (optional)", text: $merchant)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
                .focused($focusedField, equals: .merchant)
                .padding(.horizontal)
            
            TextField("Title (optional)", text: $titleText)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
                .focused($focusedField, equals: .title)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 16)
            
            TextEditor(text: $notes)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .focused($focusedField, equals: .notes)
                .onChange(of: notes) { _, newValue in
                    if newValue.count > 200 {
                        notes = String(newValue.prefix(200))
                    }
                }
                .padding(.horizontal)
            
            HStack {
                Spacer()
                Text("\(notes.count)/200")
                    .font(.caption)
                    .foregroundStyle(notes.count > 180 ? .orange : .secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    private var recurringSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Recurring Transaction", isOn: $isRecurring)
                .padding(.horizontal)
                .padding(.vertical, 12)
            
            if isRecurring {
                Text("Recurring frequency settings will be available in a future update.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
        .background(Color(.systemBackground))
        .padding(.top, 16)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
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
            .disabled(isSaving)
            
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
            .confirmationDialog("Clear all fields?", isPresented: $showResetConfirmation) {
                Button("Clear All Fields", role: .destructive) {
                    resetForm()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will clear all entered information.")
            }
        }
        .padding()
        .padding(.bottom, 32)
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
        // Dismiss keyboard before validation
        focusedField = nil
        
        // Amount validation
        guard let amount = parseAmount(), amount > 0 else {
            errorMessage = "Amount must be greater than 0"
            showValidationError = true
            return false
        }
        
        // Date validation
        let now = Date()
        guard selectedDate <= now else {
            errorMessage = "Date cannot be in the future"
            showValidationError = true
            return false
        }
        
        // Category validation
        guard selectedCategory != nil else {
            errorMessage = "Please select a category"
            showValidationError = true
            return false
        }
        
        // Account validation
        guard selectedAccount != nil else {
            errorMessage = "Please select an account"
            showValidationError = true
            return false
        }
        
        // Merchant validation (if provided)
        if !merchant.isEmpty && merchant.trimmingCharacters(in: .whitespaces).count < 2 {
            errorMessage = "Merchant must be at least 2 characters"
            showValidationError = true
            return false
        }
        
        // Title validation (if provided)
        if !titleText.isEmpty && titleText.trimmingCharacters(in: .whitespaces).count < 2 {
            errorMessage = "Title must be at least 2 characters"
            showValidationError = true
            return false
        }
        
        // Notes validation
        if notes.count > 200 {
            errorMessage = "Notes cannot exceed 200 characters"
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
        
        // Determine if income based on category name
        let isIncome = (category.name?.lowercased() ?? "") == "income"
        let signedAmount = isIncome ? rawAmount : -abs(rawAmount)
        
        // Determine title (fallback logic)
        let finalTitle: String
        if !titleText.isEmpty {
            finalTitle = titleText.trimmingCharacters(in: .whitespaces)
        } else if !merchant.isEmpty {
            finalTitle = merchant.trimmingCharacters(in: .whitespaces)
        } else {
            finalTitle = isIncome ? "Income" : "Expense"
        }
        
        // Determine payment method (use "N/A" for income transactions)
        let finalPaymentMethod = isIncome ? "N/A" : paymentMethod
        
        // Create transaction
        let transaction = Transaction(
            context: context,
            amount: signedAmount,
            title: finalTitle,
            merchant: merchant.isEmpty ? finalTitle : merchant.trimmingCharacters(in: .whitespaces),
            date: selectedDate,
            notes: notes.isEmpty ? nil : notes,
            paymentMethod: finalPaymentMethod,
            isRecurring: isRecurring,
            category: category,
            account: account
        )
        
        // Save to Core Data
        do {
            try context.save()
            
            print("✅ Transaction saved!")
            print("   Amount: \(signedAmount)")
            print("   Title: \(finalTitle)")
            print("   Category: \(category.name ?? "?")")
            print("   Payment Method: \(finalPaymentMethod)")
            print("   ID: \(transaction.id?.uuidString ?? "?")")
            
            // Success feedback
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showSuccess = true
            }
            
            // Hide success message and reset form
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
            print("❌ Error saving transaction: \(error)")
        }
    }
    
    private func resetForm() {
        // Clear all fields
        amountString = ""
        selectedDate = Date()
        selectedCategory = nil
        merchant = ""
        titleText = ""
        notes = ""
        isRecurring = false
        
        // Restore saved preferences
        loadSavedPreferences()
        
        // Don't auto-focus after reset
        focusedField = nil
    }
}

// MARK: - Preview
//
//#Preview {
//    NavigationStack {
//        ManualEntryView()
//            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//    }
//}
//
