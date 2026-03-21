//
//  Account+Extensions.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/11/26.
//

import Foundation
import CoreData

extension Account {
    
    // MARK: - Convenience Initializer
    
    /// Convenience initializer for creating a new Account with all required parameters
    /// - Parameters:
    ///   - context: The NSManagedObjectContext to insert the account into
    ///   - name: The name of the account (e.g., "Chase Checking", "Cash")
    ///   - type: The account type (e.g., "Checking", "Savings", "Credit Card", "Cash")
    ///   - institution: Optional bank/institution name (e.g., "Chase", "Bank of America")
    ///   - last4: Optional last 4 digits of account number
    convenience init(
        context: NSManagedObjectContext,
        name: String,
        type: String,
        institution: String? = nil,
        last4: String? = nil
    ) {
        // Call the designated initializer
        self.init(context: context)
        
        // Set the properties
        self.id = UUID()
        self.name = name
        self.type = type
        self.institution = institution
        self.last4 = last4
    }
    
    // MARK: - Computed Properties
    
    /// Returns a display name with institution if available (e.g., "Chase Checking")
    var displayName: String {
        if let institution = institution, !institution.isEmpty {
            return "\(institution) \(name ?? "Account")"
        }
        return name ?? "Unknown Account"
    }
    
    /// Returns a formatted account identifier (e.g., "••••1234")
    var formattedLast4: String? {
        guard let last4 = last4, !last4.isEmpty else {
            return nil
        }
        return "••••\(last4)"
    }
    
    /// Returns the number of transactions in this account
    var transactionCount: Int {
        transaction?.count ?? 0
    }
    
    /// Returns all transactions as an array (sorted by date descending)
    var transactionsArray: [Transaction] {
        let set = transaction as? Set<Transaction> ?? []
        return set.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }
    
    /// Returns the number of income entries in this account
    var incomeCount: Int {
        incomes?.count ?? 0
    }
    
    /// Returns all incomes as an array (sorted by date descending)
    var incomesArray: [Income] {
        let set = incomes as? Set<Income> ?? []
        return set.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }
    
    // MARK: - Fetch Request Builder
    
    /// Creates a fetch request for all accounts
    /// - Parameter sortDescriptors: Array of sort descriptors (defaults to name ascending)
    /// - Returns: Configured NSFetchRequest
    static func fetchRequest(
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \Account.name, ascending: true)]
    ) -> NSFetchRequest<Account> {
        let request = NSFetchRequest<Account>(entityName: "Account")
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    /// Fetch all accounts sorted by name
    static func fetchAll() -> NSFetchRequest<Account> {
        return fetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Account.name, ascending: true)])
    }
    
    /// Fetch accounts by type (e.g., "Checking", "Credit Card")
    static func fetchByType(_ type: String) -> NSFetchRequest<Account> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "type ==[cd] %@", type)
        return request
    }
    
    /// Fetch an account by name
    static func fetchByName(_ name: String) -> NSFetchRequest<Account> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", name)
        request.fetchLimit = 1
        return request
    }
    
    /// Fetch accounts by institution
    static func fetchByInstitution(_ institution: String) -> NSFetchRequest<Account> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "institution ==[cd] %@", institution)
        return request
    }
    
    // MARK: - Sort Descriptors
    
    /// Sort by name (A-Z)
    static var sortByNameAscending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \Account.name, ascending: true)
    }
    
    /// Sort by name (Z-A)
    static var sortByNameDescending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \Account.name, ascending: false)
    }
    
    /// Sort by type
    static var sortByType: NSSortDescriptor {
        NSSortDescriptor(keyPath: \Account.type, ascending: true)
    }
    
    /// Sort by institution
    static var sortByInstitution: NSSortDescriptor {
        NSSortDescriptor(keyPath: \Account.institution, ascending: true)
    }
    
    // MARK: - Validation Methods
    
    /// Validates the account before saving using DataValidationService
    /// - Throws: ValidationError if validation fails
    /// - Returns: True if valid
    @discardableResult
    func validate() throws -> Bool {
        guard let context = managedObjectContext else {
            throw ValidationError.referentialIntegrityViolation("Account must be associated with a context")
        }
        try DataValidationService.validateAccount(self, in: context)
        return true
    }

    /// Validates if this account can be safely deleted
    /// - Throws: ValidationError if deletion is not allowed
    func validateForDeletion() throws {
        guard let context = managedObjectContext else {
            throw ValidationError.referentialIntegrityViolation("Account must be associated with a context")
        }
        try DataValidationService.canDeleteAccount(self, in: context)
    }

    /// Creates a new account with validation
    static func createWithValidation(
        context: NSManagedObjectContext,
        name: String,
        type: String,
        institution: String? = nil,
        last4: String? = nil
    ) throws -> Account {
        return try DataValidationService.createAccount(
            name: name,
            type: type,
            institution: institution,
            last4: last4,
            in: context
        )
    }
    
    // MARK: - Helper Methods
    
    /// Calculate total balance for this account (income - expenses)
    /// - Parameters:
    ///   - startDate: Optional start date filter
    ///   - endDate: Optional end date filter
    /// - Returns: Current balance
    func calculateBalance(from startDate: Date? = nil, to endDate: Date? = nil) -> Double {
        var filteredTransactions = transactionsArray
        
        if let startDate = startDate {
            filteredTransactions = filteredTransactions.filter { ($0.date ?? Date()) >= startDate }
        }
        
        if let endDate = endDate {
            filteredTransactions = filteredTransactions.filter { ($0.date ?? Date()) <= endDate }
        }
        
        let transactionTotal = filteredTransactions.reduce(0.0) { $0 + $1.amount }
        
        // Add income if date range is specified or use all income
        var filteredIncomes = incomesArray
        
        if let startDate = startDate {
            filteredIncomes = filteredIncomes.filter { ($0.date ?? Date()) >= startDate }
        }
        
        if let endDate = endDate {
            filteredIncomes = filteredIncomes.filter { ($0.date ?? Date()) <= endDate }
        }
        
        let incomeTotal = filteredIncomes.reduce(0.0) { $0 + ($1.amount ) }
        
        return incomeTotal + transactionTotal  // transactions are already signed (negative for expenses)
    }
    
    /// Get current account balance (all time)
    var currentBalance: Double {
        calculateBalance()
    }
    
    /// Get formatted balance string
    var formattedBalance: String {
        return CurrencyService.shared.formatAmount(currentBalance)
    }
    
    /// Calculate total expenses for this account
    /// - Parameters:
    ///   - startDate: Optional start date filter
    ///   - endDate: Optional end date filter
    /// - Returns: Total expenses (positive number)
    func totalExpenses(from startDate: Date? = nil, to endDate: Date? = nil) -> Double {
        var filteredTransactions = transactionsArray.filter { $0.isExpense }
        
        if let startDate = startDate {
            filteredTransactions = filteredTransactions.filter { ($0.date ?? Date()) >= startDate }
        }
        
        if let endDate = endDate {
            filteredTransactions = filteredTransactions.filter { ($0.date ?? Date()) <= endDate }
        }
        
        return filteredTransactions.reduce(0.0) { $0 + abs($1.amount) }
    }
    
    /// Calculate total income for this account
    /// - Parameters:
    ///   - startDate: Optional start date filter
    ///   - endDate: Optional end date filter
    /// - Returns: Total income
    func totalIncome(from startDate: Date? = nil, to endDate: Date? = nil) -> Double {
        var filteredIncomes = incomesArray
        
        if let startDate = startDate {
            filteredIncomes = filteredIncomes.filter { ($0.date ?? Date()) >= startDate }
        }
        
        if let endDate = endDate {
            filteredIncomes = filteredIncomes.filter { ($0.date ?? Date()) <= endDate }
        }
        
        return filteredIncomes.reduce(0.0) { $0 + $1.amount }
    }
    
    /// Get spending for current month
    func spendingThisMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return 0
        }
        
        return totalExpenses(from: startOfMonth, to: endOfMonth)
    }
    
    /// Get income for current month
    func incomeThisMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return 0
        }
        
        return totalIncome(from: startOfMonth, to: endOfMonth)
    }
}

// MARK: - Validation Errors

enum AccountValidationError: LocalizedError {
    case invalidName
    case invalidType
    case invalidLast4
    
    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Account must have a non-empty name"
        case .invalidType:
            return "Account must have a type (e.g., Checking, Savings, Credit Card)"
        case .invalidLast4:
            return "Last 4 digits must be exactly 4 numbers"
        }
    }
}

// MARK: - Identifiable Conformance (for SwiftUI)

//extension Account: Identifiable {
//    // Core Data objects already have an objectID, but we're using our UUID
//}

// MARK: - Account Type Helpers

extension Account {
    /// Common account types
    enum AccountType: String, CaseIterable {
        case checking = "Checking"
        case savings = "Savings"
        case creditCard = "Credit Card"
        case cash = "Cash"
        case investment = "Investment"
        case other = "Other"
        
        var iconName: String {
            switch self {
            case .checking:
                return "building.columns.fill"
            case .savings:
                return "banknote.fill"
            case .creditCard:
                return "creditcard.fill"
            case .cash:
                return "dollarsign.circle.fill"
            case .investment:
                return "chart.line.uptrend.xyaxis"
            case .other:
                return "folder.fill"
            }
        }
    }
    
    /// Get the account type enum from the type string
    var accountType: AccountType? {
        guard let type = type else { return nil }
        return AccountType(rawValue: type)
    }
    
    /// Get the SF Symbol icon name for this account type
    var iconName: String {
        accountType?.iconName ?? "folder.fill"
    }
}

// MARK: - Default Accounts Helper

extension Account {
    /// Create default accounts for new users
    /// - Parameter context: The managed object context
    /// - Returns: Array of default accounts
    static func createDefaultAccounts(in context: NSManagedObjectContext) -> [Account] {
        let defaults: [(name: String, type: String, institution: String?)] = [
            ("Checking", "Checking", nil),
            ("Savings", "Savings", nil),
            ("Credit Card", "Credit Card", nil),
            ("Cash", "Cash", nil)
        ]
        
        return defaults.map { item in
            Account(
                context: context,
                name: item.name,
                type: item.type,
                institution: item.institution
            )
        }
    }
}
