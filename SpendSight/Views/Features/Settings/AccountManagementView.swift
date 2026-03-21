//
//  AccountManagementView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/12/26.
//

import SwiftUI
import CoreData

struct AccountManagementView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.name, ascending: true)],
        animation: .default
    ) private var accounts: FetchedResults<Account>

    @State private var showingAddAccount = false
    @State private var accountToEdit: Account?
    @State private var showingDeleteAlert = false
    @State private var accountToDelete: Account?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(accounts, id: \.objectID) { account in
                        AccountRowView(account: account) {
                            accountToEdit = account
                        } onDelete: {
                            accountToDelete = account
                            showingDeleteAlert = true
                        }
                    }
                } header: {
                    HStack {
                        Text("Bank Accounts")
                        Spacer()
                        Text("\(accounts.count)")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button {
                        showingAddAccount = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.green)
                            Text("Add New Account")
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
            .navigationTitle("Manage Accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddAccount) {
                AddEditAccountView()
                    .environment(\.managedObjectContext, context)
            }
            .sheet(item: $accountToEdit) { account in
                AddEditAccountView(account: account)
                    .environment(\.managedObjectContext, context)
            }
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    accountToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let account = accountToDelete {
                        deleteAccount(account)
                    }
                    accountToDelete = nil
                }
            } message: {
                if let account = accountToDelete {
                    let transactionCount = account.transactionCount
                    if transactionCount > 0 {
                        Text("Are you sure you want to delete '\(account.displayName)'? This will also delete \(transactionCount) associated transactions. This action cannot be undone.")
                    } else {
                        Text("Are you sure you want to delete '\(account.displayName)'? This action cannot be undone.")
                    }
                }
            }
        }
    }

    private func deleteAccount(_ account: Account) {
        withAnimation {
            context.delete(account)
            context.saveIfNeeded()
        }
    }
}

struct AccountRowView: View {
    let account: Account
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Account Type Icon
            Image(systemName: account.iconName)
                .font(.title2)
                .foregroundStyle(colorForAccountType(account.type ?? ""))
                .frame(width: 32, height: 32)

            // Account Info
            VStack(alignment: .leading, spacing: 2) {
                Text(account.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    Text(account.type ?? "Unknown")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let formattedLast4 = account.formattedLast4 {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formattedLast4)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(account.transactionCount) transactions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Current Balance
                Text("Balance: \(account.formattedBalance)")
                    .font(.subheadline)
                    .foregroundStyle(account.currentBalance >= 0 ? .green : .red)
                    .fontWeight(.medium)
            }

            Spacer()

            // Edit button
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)

            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
            }
            .tint(.blue)
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
}

#Preview {
    AccountManagementView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}