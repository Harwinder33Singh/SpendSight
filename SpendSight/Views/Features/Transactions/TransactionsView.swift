//
//  TransactionsView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI
import CoreData

struct TransactionsView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel = TransactionsViewModel()
    @State private var transactionToEdit: Transaction?
    
    // Dynamic fetch request that responds to filters
    @FetchRequest private var transactions: FetchedResults<Transaction>
    
    // All categories and accounts for filtering
    @FetchRequest(fetchRequest: Category.fetchAll())
    private var allCategories: FetchedResults<Category>
    
    @FetchRequest(fetchRequest: Account.fetchAll())
    private var allAccounts: FetchedResults<Account>
    
    init() {
        _transactions = FetchRequest<Transaction>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
            animation: .default
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if filteredTransactions.isEmpty {
                    emptyStateView
                } else {
                    transactionsList
                }
            }
            .navigationTitle("Transactions")
            .searchable(text: $viewModel.searchText, prompt: "Search transactions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    filterButton
                }
            }
            .sheet(isPresented: $viewModel.showFilterSheet) {
                FilterSheet(viewModel: viewModel, categories: allCategories, accounts: allAccounts)
            }
            .sheet(item: $transactionToEdit) { transaction in
                NavigationStack {
                    TransactionEditView(transaction: transaction)
                }
            }
            .alert("Delete Transaction", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let transaction = viewModel.transactionToDelete {
                        viewModel.deleteTransaction(transaction, context: context)
                    }
                }
            } message: {
                if let transaction = viewModel.transactionToDelete {
                    Text("Are you sure you want to delete '\(transaction.title ?? "this transaction")'? This action cannot be undone.")
                }
            }
            .refreshable {
                // Refresh data (mainly useful if you add sync later)
                context.refreshAllObjects()
            }
        }
    }
    
    // MARK: - Filtered Transactions
    
    private var filteredTransactions: [Transaction] {
        transactions.filter { viewModel.matchesFilters($0) }
    }
    
    // MARK: - Grouped Transactions
    
    private var groupedTransactions: [(String, [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction -> String in
            guard let date = transaction.date else { return "Unknown" }
            return formatDateForGrouping(date)
        }
        
        return grouped.sorted { first, second in
            // Sort sections by date (most recent first)
            guard let firstDate = first.value.first?.date,
                  let secondDate = second.value.first?.date else {
                return false
            }
            return firstDate > secondDate
        }
    }
    
    // MARK: - Transactions List
    
    private var transactionsList: some View {
        List {
            ForEach(groupedTransactions, id: \.0) { section in
                Section {
                    ForEach(section.1) { transaction in
                        NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                            TransactionRow(transaction: transaction)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                transactionToEdit = transaction
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.transactionToDelete = transaction
                                viewModel.showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text(section.0)
                        .font(.headline)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Transactions", systemImage: "doc.text")
        } description: {
            if viewModel.hasActiveFilters || !viewModel.searchText.isEmpty {
                Text("No transactions match your filters")
            } else {
                Text("Start tracking your expenses by adding your first transaction")
            }
        } actions: {
            if viewModel.hasActiveFilters || !viewModel.searchText.isEmpty {
                Button("Clear Filters") {
                    viewModel.clearFilters()
                    viewModel.searchText = ""
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    // MARK: - Filter Button
    
    private var filterButton: some View {
        Button {
            viewModel.showFilterSheet = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title3)
                
                if viewModel.hasActiveFilters {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: -4)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDateForGrouping(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            return "This Week"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .month) {
            return "This Month"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Preview

#Preview {
    TransactionsView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
