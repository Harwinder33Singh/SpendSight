//
//  DataDebugView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/12/26.
//

import SwiftUI
import CoreData

struct DataDebugView: View {
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) var transactions: FetchedResults<Transaction>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
    ) var categories: FetchedResults<Category>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.name, ascending: true)]
    ) var accounts: FetchedResults<Account>
    
    var body: some View {
        NavigationStack {
            List {
                // Summary Section
                Section("Database Summary") {
                    LabeledContent("Transactions", value: "\(transactions.count)")
                    LabeledContent("Categories", value: "\(categories.count)")
                    LabeledContent("Accounts", value: "\(accounts.count)")
                }
                
                // Recent Transactions
                Section("Recent Transactions") {
                    if transactions.isEmpty {
                        Text("No transactions yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(transactions.prefix(10)) { transaction in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(transaction.title ?? "No Title")
                                        .font(.headline)
                                    Spacer()
                                    Text(transaction.formattedAmount)
                                        .foregroundStyle(transaction.isExpense ? .red : .green)
                                }
                                
                                HStack {
                                    Text(transaction.categoryName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("•")
                                        .foregroundStyle(.secondary)
                                    Text(transaction.accountName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(transaction.shortDate)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                
                // Categories
                Section("Categories") {
                    if categories.isEmpty {
                        Text("No categories yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(categories) { category in
                            HStack {
                                Image(systemName: category.icon ?? "questionmark")
                                    .foregroundStyle(category.color)
                                Text(category.name ?? "Unknown")
                                Spacer()
                                Text("\(category.transactionCount) txns")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                // Accounts
                Section("Accounts") {
                    if accounts.isEmpty {
                        Text("No accounts yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(accounts) { account in
                            VStack(alignment: .leading) {
                                Text(account.displayName)
                                    .font(.headline)
                                Text("\(account.transactionCount) transactions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                // Danger Zone
                Section("Danger Zone") {
                    Button(role: .destructive) {
                        deleteAllTransactions()
                    } label: {
                        Label("Delete All Transactions", systemImage: "trash")
                    }
                    
                    Button(role: .destructive) {
                        printDatabasePath()
                    } label: {
                        Label("Print Database Path", systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle("Data Debug")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Refresh") {
                        context.refreshAllObjects()
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func deleteAllTransactions() {
        for transaction in transactions {
            context.delete(transaction)
        }
        
        do {
            try context.save()
            print("✅ All transactions deleted")
        } catch {
            print("❌ Error deleting transactions: \(error)")
        }
    }
    
    private func printDatabasePath() {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            print("📁 Database Location:")
            print("   \(url.path)")
            
            // List all files
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: url.path)
                print("\n📄 Files in directory:")
                for file in files {
                    print("   - \(file)")
                }
            } catch {
                print("❌ Error listing files: \(error)")
            }
        }
    }
}

#Preview {
    DataDebugView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
