//
//  Transaction+Extensions.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/11/26.
//

import Foundation
import CoreData

extension Transaction {
    
    // MARK: - Convenience Initializer
    /// Convenience initializer for creating a new Transaction with all required parameters
    /// - Parameters:
    ///   - context: The NSManagedObjectContext to insert the transaction into
    ///   - amount: The transaction amount (positive for income, negative for expense)
    ///   - title: The title/description of the transaction
    ///   - merchant: The merchant/vendor name
    ///   - date: The date of the transaction (defaults to current date)
    ///   - notes: Optional notes about the transaction
    ///   - paymentMethod: How the transaction was paid (e.g., "Credit Card", "Cash")
    ///   - isRecurring: Whether this is a recurring transaction (defaults to false)
    ///   - category: The category this transaction belongs to
    ///   - account: The account this transaction is associated with
    
    convenience init(
        context: NSManagedObjectContext,
        amount: Double,
        title: String,
        merchant: String,
        date: Date = Date(),
        notes: String? = nil,
        paymentMethod: String,
        isRecurring: Bool = false,
        category: Category,
        account: Account
    ) {
        // Call the designated initializer
        self.init(context: context)
        
        // set other properties
        self.id = UUID()
        self.amount = amount
        self.title = title
        self.merchant = merchant
        self.date = date
        self.notes = notes
        self.paymentMethod = paymentMethod
        self.isRecurring = isRecurring
        self.category = category
        self.account = account
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    /// Returns a formatted date string for display (e.g., "Jan 15, 2026 at 3:30 PM")
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date ?? Date())
    }
    
    /// Returns a short date string (e.g., "Jan 15")
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date ?? Date())
    }
    
    /// Returns a formatted amount string with currency symbol
    var formattedAmount: String {
        return CurrencyService.shared.formatAmount(amount)
    }
    
    /// Returns the category name or "Uncategorized" if category is nil
    var categoryName: String {
        category?.name ?? "Uncategorized"
    }
    
    /// Returns the account name or "Unknown Account" if account is nil
    var accountName: String {
        account?.name ?? "Unknown Account"
    }
    
    /// Returns true if this is an expense (negative amount)
    var isExpense: Bool {
        amount < 0
    }
    
    /// Returns true if this is an income (positive amount)
    var isIncome: Bool {
        amount > 0
    }
    
    /// Returns the absolute value of the amount (always positive)
    var absoluteAmount: Double {
        abs(amount)
    }
    
    /// Returns a formatted absolute amount (always positive)
    var formattedAbsoluteAmount: String {
        return CurrencyService.shared.formatAmount(absoluteAmount)
    }
    
    // MARK: - Fetch Request Builder
    /// Creates a fetch request with optional filters
    /// - Parameters:
    ///   - startDate: Optional start date filter
    ///   - endDate: Optional end date filter
    ///   - category: Optional category filter
    ///   - account: Optional account filter
    ///   - merchant: Optional merchant name filter
    ///   - isRecurring: Optional filter for recurring transactions
    ///   - sortDescriptors: Array of sort descriptors (defaults to date descending)
    /// - Returns: Configured NSFetchRequest
    
    static func fetchRequest(
        startDate: Date? = nil,
        endDate: Date? = nil,
        category: Category? = nil,
        account: Account? = nil,
        merchant: String? = nil,
        isRecurring: Bool? = nil,
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
    ) -> NSFetchRequest<Transaction> {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        
        var predicates: [NSPredicate] = []
        
        //Date range filter
        if let startDate = startDate, let endDate = endDate {
            predicates.append(NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate as NSDate, endDate as NSDate))
        }
        
        // Category filter
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        // Account filter
        if let account = account {
            predicates.append(NSPredicate(format: "account == %@", account))
        }
        
        // Merchant filter
        if let merchant = merchant {
            predicates.append(NSPredicate(format: "merchant == %@", merchant))
        }
        
        // Recurring filter
        if let isRecurring, isRecurring {
            predicates.append(NSPredicate(format: "isRecurring == %@", NSNumber(value: isRecurring)))
        }
        
        // Combine all predicates with AND
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        request.sortDescriptors = sortDescriptors
        
        return request
    }
    
    /// Fetch all transactions
    static func fetchAll() -> NSFetchRequest<Transaction> {
        return fetchRequest()
    }
    
    /// Fetch transactions for a specific month
    static func fetchForMonth(year: Int, month: Int) -> NSFetchRequest<Transaction> {
        var components = DateComponents(year: year, month: month, day: 1)
        
        guard let startDate = Calendar.current.date(from: components), let endDate = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) else {
            return fetchAll()
        }
        
        return fetchRequest(startDate: startDate, endDate: endDate)
    }
    
    // MARK: - Validation Methods
    
    /// Validates the transaction before saving using DataValidationService
    /// - Throws: ValidationError if validation fails
    /// - Returns: True if valid
    ///
    @discardableResult
    func validate() throws -> Bool {
        guard let context = managedObjectContext else {
            throw ValidationError.referentialIntegrityViolation("Transaction must be associated with a context")
        }
        try DataValidationService.validateTransaction(self, in: context)
        return true
    }

    /// Creates a new transaction with validation
    static func createWithValidation(
        context: NSManagedObjectContext,
        title: String,
        amount: Double,
        date: Date,
        merchant: String?,
        paymentMethod: String?,
        category: Category,
        account: Account
    ) throws -> Transaction {
        return try DataValidationService.createTransaction(
            title: title,
            amount: amount,
            date: date,
            merchant: merchant,
            paymentMethod: paymentMethod,
            category: category,
            account: account,
            in: context
        )
    }
    
    /// Updates the updatedAt timestamp
    func touch() {
        self.updatedAt = Date()
    }
}

// MARK: - Transaction Type Helpers

extension Transaction {
    enum TransactionType: String, CaseIterable {
        case expense = "expense"
        case income = "income"
        case transfer = "transfer"

        var displayName: String {
            switch self {
            case .expense: return "Expense"
            case .income: return "Income"
            case .transfer: return "Transfer"
            }
        }

        var systemImage: String {
            switch self {
            case .expense: return "minus.circle.fill"
            case .income: return "plus.circle.fill"
            case .transfer: return "arrow.left.arrow.right.circle.fill"
            }
        }
    }

    /// Returns the transaction type based on amount and category
    var transactionType: TransactionType {
        if amount > 0 {
            return .income
        } else if category?.categoryType == .transfer {
            return .transfer
        } else {
            return .expense
        }
    }
}
