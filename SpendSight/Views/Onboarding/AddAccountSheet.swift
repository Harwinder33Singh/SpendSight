//
//  AddAccountSheet.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/18/26.
//

import SwiftUI

struct AddAccountSheet: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var type: String = "Checking"
    @State private var institution: String = ""
    @State private var last4: String = ""
    @State private var initialBalance: String = "0"
    
    private let accountTypes = ["Checking", "Savings", "Credit Card", "Cash", "Investment", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Account Details") {
                    TextField("Account Name *", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Account Type", selection: $type) {
                        ForEach(accountTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }
                
                Section("Additional Information") {
                    TextField("Bank/Institution (Optional)", text: $institution)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Last 4 Digits (Optional)", text: $last4)
                        .keyboardType(.numberPad)
                        .onChange(of: last4) { _, newValue in
                            // Limit to 4 digits
                            if newValue.count > 4 {
                                last4 = String(newValue.prefix(4))
                            }
                        }
                }
                
                Section {
                    HStack {
                        Text("Initial Balance")
                        Spacer()
                        TextField("0.00", text: $initialBalance)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                } footer: {
                    Text("Enter the current balance of this account (optional)")
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addAccount()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func addAccount() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedInstitution = institution.trimmingCharacters(in: .whitespaces)
        let trimmedLast4 = last4.trimmingCharacters(in: .whitespaces)
        
        let balance = Double(initialBalance) ?? 0.0
        
        let account = AccountData(
            name: trimmedName,
            type: type,
            institution: trimmedInstitution.isEmpty ? nil : trimmedInstitution,
            last4: trimmedLast4.isEmpty ? nil : trimmedLast4,
            initialBalance: balance
        )
        
        viewModel.addAccount(account)
        dismiss()
    }
}

//#Preview {
//    AddAccountSheet(viewModel: OnboardingViewModel(context: PersistenceController.shared.container.viewContext))
//}
