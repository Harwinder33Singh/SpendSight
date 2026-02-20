//
//  TransactionComponents.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/19/26.
//

import SwiftUI
import CoreData

// MARK: - Transaction Row

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon with color
            if let category = transaction.category {
                Image(systemName: category.icon ?? "questionmark")
                    .font(.title3)
                    .foregroundStyle(category.color)
                    .frame(width: 40, height: 40)
                    .background(category.color.opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Transaction details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title ?? "Transaction")
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    // Merchant
                    if let merchant = transaction.merchant, !merchant.isEmpty {
                        Text(merchant)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    // Account indicator
                    if let account = transaction.account?.name {
                        HStack(spacing: 4) {
                            Image(systemName: "building.columns.fill")
                                .font(.caption2)
                            Text(account)
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.formattedAmount)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(transaction.isExpense ? .red : .green)
                
                // Date
                Text(formatDate(transaction.date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @ObservedObject var viewModel: TransactionsViewModel
    let categories: FetchedResults<Category>
    let accounts: FetchedResults<Account>
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                // Date filter
                Section("Date Range") {
                    Picker("Period", selection: $viewModel.selectedDateFilter) {
                        ForEach(DateFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Category filter
                Section {
                    if categories.isEmpty {
                        Text("No categories available")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(categories, id: \.objectID) { category in
                            Toggle(isOn: binding(for: category.objectID)) {
                                HStack {
                                    Image(systemName: category.icon ?? "questionmark")
                                        .foregroundStyle(category.color)
                                    Text(category.name ?? "Unknown")
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Categories")
                        Spacer()
                        if !viewModel.selectedCategories.isEmpty {
                            Text("\(viewModel.selectedCategories.count) selected")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Account filter
                Section {
                    if accounts.isEmpty {
                        Text("No accounts available")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(accounts, id: \.objectID) { account in
                            Toggle(isOn: accountBinding(for: account.objectID)) {
                                HStack {
                                    Image(systemName: account.iconName)
                                        .foregroundStyle(.blue)
                                    Text(account.displayName)
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Accounts")
                        Spacer()
                        if !viewModel.selectedAccounts.isEmpty {
                            Text("\(viewModel.selectedAccounts.count) selected")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Amount range filter
                Section("Amount Range") {
                    HStack {
                        Text("Min")
                        TextField("0", text: $viewModel.minAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Max")
                        TextField("No limit", text: $viewModel.maxAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Clear filters
                if viewModel.hasActiveFilters {
                    Section {
                        Button(role: .destructive) {
                            viewModel.clearFilters()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Clear All Filters")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Bindings
    
    private func binding(for objectID: NSManagedObjectID) -> Binding<Bool> {
        Binding(
            get: { viewModel.selectedCategories.contains(objectID) },
            set: { isSelected in
                if isSelected {
                    viewModel.selectedCategories.insert(objectID)
                } else {
                    viewModel.selectedCategories.remove(objectID)
                }
            }
        )
    }
    
    private func accountBinding(for objectID: NSManagedObjectID) -> Binding<Bool> {
        Binding(
            get: { viewModel.selectedAccounts.contains(objectID) },
            set: { isSelected in
                if isSelected {
                    viewModel.selectedAccounts.insert(objectID)
                } else {
                    viewModel.selectedAccounts.remove(objectID)
                }
            }
        )
    }
}

// MARK: - Transaction Edit View

struct TransactionEditView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var transaction: Transaction
    
    @FetchRequest(fetchRequest: Category.fetchAll())
    private var categories: FetchedResults<Category>
    
    @FetchRequest(fetchRequest: Account.fetchAll())
    private var accounts: FetchedResults<Account>
    
    @State private var amountString: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedCategory: Category?
    @State private var selectedAccount: Account?
    @State private var merchant: String = ""
    @State private var titleText: String = ""
    @State private var notes: String = ""
    @State private var paymentMethod: String = "Other"
    @State private var isRecurring: Bool = false
    @State private var didLoadInitialData: Bool = false
    @State private var showValidationError: Bool = false
    @State private var errorMessage: String = ""
    
    private let paymentMethods = ["Credit Card", "Debit Card", "Cash", "Other"]
    
    private var isIncomeCategory: Bool {
        (selectedCategory?.name?.lowercased() ?? "") == "income"
    }
    
    private var canSave: Bool {
        selectedCategory != nil && selectedAccount != nil
    }
    
    var body: some View {
        Form {
            Section("Amount") {
                TextField("Enter amount", text: $amountString)
                    .keyboardType(.decimalPad)
            }
            
            Section("Date") {
                DatePicker(
                    "Transaction Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
            }
            
            Section("Classification") {
                Picker(
                    "Category",
                    selection: Binding(
                        get: { selectedCategory?.objectID },
                        set: { newObjectID in
                            if let objectID = newObjectID {
                                selectedCategory = categories.first(where: { $0.objectID == objectID })
                            } else {
                                selectedCategory = nil
                            }
                        }
                    )
                ) {
                    Text("Choose a category").tag(nil as NSManagedObjectID?)
                    ForEach(categories, id: \.objectID) { category in
                        Text(category.name ?? "Unknown").tag(category.objectID as NSManagedObjectID?)
                    }
                }
                
                Picker(
                    "Account",
                    selection: Binding(
                        get: { selectedAccount?.objectID },
                        set: { newObjectID in
                            if let objectID = newObjectID {
                                selectedAccount = accounts.first(where: { $0.objectID == objectID })
                            } else {
                                selectedAccount = nil
                            }
                        }
                    )
                ) {
                    Text("Choose an account").tag(nil as NSManagedObjectID?)
                    ForEach(accounts, id: \.objectID) { account in
                        Text(account.displayName).tag(account.objectID as NSManagedObjectID?)
                    }
                }
                
                if !isIncomeCategory {
                    Picker("Payment Method", selection: $paymentMethod) {
                        ForEach(paymentMethods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                }
            }
            
            Section("Details") {
                TextField("Merchant (optional)", text: $merchant)
                    .textInputAutocapitalization(.words)
                TextField("Title (optional)", text: $titleText)
                    .textInputAutocapitalization(.words)
            }
            
            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 120)
            }
            
            Section("Additional") {
                Toggle("Recurring Transaction", isOn: $isRecurring)
            }
        }
        .navigationTitle("Edit Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(!canSave)
            }
        }
        .alert("Validation Error", isPresented: $showValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadInitialDataIfNeeded()
        }
    }
    
    private func loadInitialDataIfNeeded() {
        guard !didLoadInitialData else { return }
        didLoadInitialData = true
        
        amountString = amountForEditing(from: transaction.amount)
        selectedDate = transaction.date ?? Date()
        selectedCategory = transaction.category
        selectedAccount = transaction.account
        merchant = transaction.merchant ?? ""
        titleText = transaction.title ?? ""
        notes = transaction.notes ?? ""
        paymentMethod = transaction.paymentMethod ?? "Other"
        isRecurring = transaction.isRecurring
    }
    
    private func amountForEditing(from amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: abs(amount))) ?? String(abs(amount))
    }
    
    private func parseAmount() -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        
        if let parsed = formatter.number(from: amountString)?.doubleValue {
            return parsed
        }
        
        let cleaned = amountString.replacingOccurrences(of: ",", with: "")
        return Double(cleaned)
    }
    
    private func validateForm() -> Bool {
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
        
        if !notes.isEmpty && notes.count > 200 {
            errorMessage = "Notes cannot exceed 200 characters"
            showValidationError = true
            return false
        }
        
        return true
    }
    
    private func saveChanges() {
        guard validateForm(),
              let category = selectedCategory,
              let account = selectedAccount,
              let rawAmount = parseAmount()
        else { return }
        
        let isIncome = (category.name?.lowercased() ?? "") == "income"
        let signedAmount = isIncome ? rawAmount : -abs(rawAmount)
        
        let trimmedMerchant = merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTitle = titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let finalTitle: String
        if !trimmedTitle.isEmpty {
            finalTitle = trimmedTitle
        } else if !trimmedMerchant.isEmpty {
            finalTitle = trimmedMerchant
        } else {
            finalTitle = isIncome ? "Income" : "Expense"
        }
        
        transaction.amount = signedAmount
        transaction.date = selectedDate
        transaction.category = category
        transaction.account = account
        transaction.title = finalTitle
        transaction.merchant = trimmedMerchant.isEmpty ? finalTitle : trimmedMerchant
        transaction.paymentMethod = isIncome ? "N/A" : paymentMethod
        transaction.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
        transaction.isRecurring = isRecurring
        transaction.updatedAt = Date()
        
        do {
            try context.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showValidationError = true
        }
    }
}

// MARK: - Transaction Detail View

struct TransactionDetailView: View {
    @ObservedObject var transaction: Transaction
    @State private var showEditSheet: Bool = false
    
    var body: some View {
        Form {
            // Amount section
            Section {
                HStack {
                    Text("Amount")
                    Spacer()
                    Text(transaction.formattedAmount)
                        .fontWeight(.semibold)
                        .foregroundStyle(transaction.isExpense ? .red : .green)
                }
            }
            
            // Basic info
            Section("Details") {
                if let title = transaction.title {
                    LabeledContent("Title", value: title)
                }
                
                if let merchant = transaction.merchant {
                    LabeledContent("Merchant", value: merchant)
                }
                
                if let date = transaction.date {
                    LabeledContent("Date") {
                        Text(date, style: .date)
                    }
                }
            }
            
            // Category and Account
            Section("Classification") {
                if let category = transaction.category {
                    HStack {
                        Text("Category")
                        Spacer()
                        Image(systemName: category.icon ?? "questionmark")
                            .foregroundStyle(category.color)
                        Text(category.name ?? "Unknown")
                    }
                }
                
                if let account = transaction.account {
                    LabeledContent("Account", value: account.displayName)
                }
                
                if let paymentMethod = transaction.paymentMethod {
                    LabeledContent("Payment Method", value: paymentMethod)
                }
            }
            
            // Notes
            if let notes = transaction.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                        .font(.body)
                }
            }
            
            // Additional info
            Section("Additional Information") {
                Toggle("Recurring", isOn: .constant(transaction.isRecurring))
                    .disabled(true)
                
                if let createdAt = transaction.createdAt {
                    LabeledContent("Created") {
                        Text(createdAt, style: .date)
                        Text(createdAt, style: .time)
                    }
                }
            }
        }
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationStack {
                TransactionEditView(transaction: transaction)
            }
        }
    }
}

// MARK: - Previews

#Preview("Transaction Row") {
    let context = PersistenceController.shared.container.viewContext
    
    // Create sample transaction
    let category = Category(
        context: context,
        name: "Groceries",
        colorHex: "#4CAF50",
        icon: "cart.fill",
        monthlyBudget: 500
    )
    
    let account = Account(
        context: context,
        name: "Checking",
        type: "Checking"
    )
    
    let transaction = Transaction(
        context: context,
        amount: -50.25,
        title: "Whole Foods",
        merchant: "Whole Foods Market",
        date: Date(),
        notes: "Weekly groceries",
        paymentMethod: "Credit Card",
        isRecurring: false,
        category: category,
        account: account
    )
    
    return List {
        TransactionRow(transaction: transaction)
    }
}

//#Preview("Filter Sheet") {
//    let context = PersistenceController.shared.container.viewContext
//    let viewModel = TransactionsViewModel()
//    
//    FilterSheet(
//        viewModel: viewModel,
//        categories: FetchedResults(fetchRequest: Category.fetchAll(), managedObjectContext: context),
//        accounts: FetchedResults(fetchRequest: Account.fetchAll(), managedObjectContext: context)
//    )
//}
