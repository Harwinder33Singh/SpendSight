//
//  ConnectedAccountsView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 4/15/26.
//

import SwiftUI
import CoreData

struct ConnectedAccountsView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.name, ascending: true)],
        predicate: NSPredicate(format: "plaidItemId != nil"),
        animation: .default
    ) private var connectedAccounts: FetchedResults<Account>

    @State private var isSyncing = false
    @State private var showSuccess = false
    @State private var successMessage = ""
    @State private var connectionError: PlaidConnectionError?

    private var userId: String {
        UserDefaults.standard.string(forKey: "userName") ?? "default-user"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Error banner — shows above list when sync fails
                if let error = connectionError {
                    PlaidErrorBanner(error: error) {
                        let currentError = error
                        connectionError = nil
                        switch currentError {
                        case .expiredToken, .bankDisconnected:
                            // Scroll down to the connect button — nothing to do,
                            // it's already visible in the list
                            break
                        default:
                            syncTransactions()
                        }
                    } onDismiss: {
                        connectionError = nil
                    }.padding(.top)
                }

                List {
                    // Connected banks section
                    if !connectedAccounts.isEmpty {
                        Section {
                            ForEach(connectedAccounts, id: \.objectID) { account in
                                ConnectedAccountRow(account: account)
                            }
                        } header: {
                            HStack {
                                Text("Connected Banks")
                                Spacer()
                                Text("\(connectedAccounts.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // Connect new bank section
                    Section {
                        PlaidLinkButton(userId: userId) { institutionName in
                            UserDefaults.standard.set(true, forKey: "hasConnectedBank")
                            successMessage = "\(institutionName) connected successfully"
                            showSuccess = true
                            syncTransactions()
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    } footer: {
                        Text("Your bank credentials are never stored in SpendSight. Connection is handled securely by Plaid.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Sync section
                    if !connectedAccounts.isEmpty {
                        Section {
                            Button {
                                syncTransactions()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .foregroundStyle(.blue)
                                    Text("Sync Transactions")
                                    Spacer()
                                    if isSyncing {
                                        ProgressView()
                                    }
                                }
                            }
                            .disabled(isSyncing)
                        } footer: {
                            Text("Syncs all new transactions from your connected banks")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Connected Banks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") { }
            } message: {
                Text(successMessage)
            }
        }
    }

    // MARK: - Sync Transactions

    private func syncTransactions() {
        isSyncing = true
        connectionError = nil

        Task {
            do {
                let plaidTransactions = try await PlaidService.shared.syncTransactions(userId: userId)
                await PlaidImporter.shared.importTransactions(plaidTransactions, into: context)

                await MainActor.run {
                    isSyncing = false
                    // Only show success if we actually got transactions
                    if !plaidTransactions.isEmpty {
                        successMessage = "Synced \(plaidTransactions.count) transactions"
                        showSuccess = true
                    }
                }
            } catch {
                // ← error is only available here in the catch block
                await MainActor.run {
                    isSyncing = false
                    connectionError = PlaidService.shared.detectError(from: error)
                }
            }
        }
    }

    // MARK: - Import Transactions into Core Data

    private func importTransactions(_ plaidTransactions: [PlaidTransaction]) async {
        await context.perform {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            for plaidTx in plaidTransactions {
                // Skip pending transactions
                if plaidTx.pending == true { continue }

                // Skip duplicates
                let request = Transaction.fetchRequest()
                request.predicate = NSPredicate(
                    format: "plaidTransactionId == %@",
                    plaidTx.plaidTransactionId
                )
                request.fetchLimit = 1

                if let existing = try? context.fetch(request), !existing.isEmpty {
                    continue
                }

                // Find or create matching account
                let account = findOrCreateAccount(
                    itemId: plaidTx.itemId ?? "",
                    institutionName: plaidTx.institutionName ?? "Connected Bank"
                )

                // Find matching category
                let categoryName = PlaidCategoryMapper.mapToSpendSight(plaidTx.plaidCategory)
                let category = findCategory(named: categoryName)

                guard let account = account, let category = category else { continue }

                // Parse date
                let date = dateFormatter.date(from: plaidTx.date) ?? Date()

                // Plaid: positive = expense, negative = income
                // SpendSight: negative = expense, positive = income
                let amount = -plaidTx.amount

                let transaction = Transaction(context: context)
                transaction.id = UUID()
                transaction.amount = amount
                transaction.title = plaidTx.merchantName ?? "Transaction"
                transaction.merchant = plaidTx.merchantName ?? ""
                transaction.date = date
                transaction.paymentMethod = "Bank"
                transaction.isRecurring = false
                transaction.category = category
                transaction.account = account
                transaction.plaidTransactionId = plaidTx.plaidTransactionId
                transaction.createdAt = Date()
                transaction.updatedAt = Date()
            }

            try? context.save()
        }
    }

    // MARK: - Helpers

    private func findOrCreateAccount(itemId: String, institutionName: String) -> Account? {
        let request = Account.fetchRequest()
        request.predicate = NSPredicate(format: "plaidItemId == %@", itemId)
        request.fetchLimit = 1

        if let existing = try? context.fetch(request), let account = existing.first {
            return account
        }

        // Create new account for this bank
        let account = Account(context: context)
        account.id = UUID()
        account.name = institutionName
        account.type = "Checking"
        account.plaidItemId = itemId
        account.plaidInstitutionName = institutionName
        return account
    }

    private func findCategory(named name: String) -> Category? {
        let request = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", name)
        request.fetchLimit = 1

        if let results = try? context.fetch(request), let category = results.first {
            return category
        }

        // Fall back to Other
        let fallback = Category.fetchRequest()
        fallback.predicate = NSPredicate(format: "name ==[cd] %@", "Other")
        fallback.fetchLimit = 1

        return try? context.fetch(fallback).first
    }
}

// MARK: - Connected Account Row

struct ConnectedAccountRow: View {
    let account: Account

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "building.columns.fill")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(account.plaidInstitutionName ?? account.name ?? "Bank")
                    .font(.headline)

                Text("\(account.transactionCount) transactions synced")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
}

#Preview {
    ConnectedAccountsView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
