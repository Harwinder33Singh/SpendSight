//
//  AddEditAccountView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/12/26.
//

import SwiftUI
import CoreData

struct AddEditAccountView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    let account: Account?

    @State private var name: String = ""
    @State private var type: String = "Checking"
    @State private var institution: String = ""
    @State private var last4: String = ""
    @State private var initialBalance: String = ""
    @State private var hasInitialBalance: Bool = false

    @State private var showingError = false
    @State private var errorMessage = ""

    private let accountTypes = ["Checking", "Savings", "Credit Card", "Cash", "Investment", "Other"]

    private var isEditing: Bool {
        account != nil
    }

    init(account: Account? = nil) {
        self.account = account
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Account name", text: $name)
                            .textInputAutocapitalization(.words)
                            .multilineTextAlignment(.trailing)
                    }

                    Picker("Account Type", selection: $type) {
                        ForEach(accountTypes, id: \.self) { accountType in
                            HStack {
                                Image(systemName: iconForAccountType(accountType))
                                    .foregroundStyle(colorForAccountType(accountType))
                                Text(accountType)
                            }
                            .tag(accountType)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Account Details")
                }

                Section {
                    HStack {
                        Text("Bank/Institution")
                        Spacer()
                        TextField("Optional", text: $institution)
                            .textInputAutocapitalization(.words)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Last 4 Digits")
                        Spacer()
                        TextField("Optional", text: $last4)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: last4) { _, newValue in
                                // Limit to 4 digits
                                if newValue.count > 4 {
                                    last4 = String(newValue.prefix(4))
                                }
                                // Ensure only numbers
                                last4 = last4.filter { $0.isNumber }
                            }
                    }
                } header: {
                    Text("Additional Information")
                }

                if !isEditing {
                    Section {
                        Toggle("Set Initial Balance", isOn: $hasInitialBalance)

                        if hasInitialBalance {
                            HStack {
                                Text("Initial Balance")
                                Spacer()
                                TextField("0.00", text: $initialBalance)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    } header: {
                        Text("Initial Setup")
                    } footer: {
                        Text("Set the starting balance for this account (optional)")
                    }
                }

                Section {
                    HStack(spacing: 12) {
                        Image(systemName: iconForAccountType(type))
                            .font(.title2)
                            .foregroundStyle(colorForAccountType(type))
                            .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(displayName)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            HStack(spacing: 8) {
                                Text(type)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                if !last4.isEmpty {
                                    Text("•")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("••••\(last4)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            if hasInitialBalance && !initialBalance.isEmpty {
                                if let balance = Double(initialBalance) {
                                    Text("Initial Balance: \(formatCurrency(balance))")
                                        .font(.subheadline)
                                        .foregroundStyle(balance >= 0 ? .green : .red)
                                        .fontWeight(.medium)
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle(isEditing ? "Edit Account" : "Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Update" : "Add") {
                        saveAccount()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadAccountData()
            }
        }
    }

    private var displayName: String {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedInstitution = institution.trimmingCharacters(in: .whitespaces)

        if trimmedName.isEmpty {
            return "Account Name"
        }

        if !trimmedInstitution.isEmpty {
            return "\(trimmedInstitution) \(trimmedName)"
        }

        return trimmedName
    }

    private func loadAccountData() {
        guard let account = account else { return }

        name = account.name ?? ""
        type = account.type ?? "Checking"
        institution = account.institution ?? ""
        last4 = account.last4 ?? ""
    }

    private func saveAccount() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedInstitution = institution.trimmingCharacters(in: .whitespaces)
        let trimmedLast4 = last4.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else {
            errorMessage = "Account name cannot be empty"
            showingError = true
            return
        }

        // Validate last4 if provided
        if !trimmedLast4.isEmpty && (trimmedLast4.count != 4 || !trimmedLast4.allSatisfy({ $0.isNumber })) {
            errorMessage = "Last 4 digits must be exactly 4 numbers"
            showingError = true
            return
        }

        if isEditing {
            // Update existing account
            guard let account = account else { return }
            account.name = trimmedName
            account.type = type
            account.institution = trimmedInstitution.isEmpty ? nil : trimmedInstitution
            account.last4 = trimmedLast4.isEmpty ? nil : trimmedLast4
        } else {
            // Create new account
            let newAccount = Account(
                context: context,
                name: trimmedName,
                type: type,
                institution: trimmedInstitution.isEmpty ? nil : trimmedInstitution,
                last4: trimmedLast4.isEmpty ? nil : trimmedLast4
            )

            // Add initial balance as income if provided
            if hasInitialBalance, let balanceValue = Double(initialBalance), balanceValue != 0 {
                let _ = Income(
                    context: context,
                    amount: balanceValue,
                    source: "Initial Balance",
                    date: Date(),
                    account: newAccount
                )
            }
        }

        do {
            try context.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save account: \(error.localizedDescription)"
            showingError = true
        }
    }

    private func iconForAccountType(_ type: String) -> String {
        switch type.lowercased() {
        case "checking":
            return "building.columns.fill"
        case "savings":
            return "banknote.fill"
        case "credit card":
            return "creditcard.fill"
        case "cash":
            return "dollarsign.circle.fill"
        case "investment":
            return "chart.line.uptrend.xyaxis"
        default:
            return "folder.fill"
        }
    }

    private func colorForAccountType(_ type: String) -> Color {
        switch type.lowercased() {
        case "checking":
            return .blue
        case "savings":
            return .green
        case "credit card":
            return .orange
        case "cash":
            return .yellow
        case "investment":
            return .purple
        default:
            return .gray
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = Locale.current.currencySymbol ?? "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

#Preview {
    AddEditAccountView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
