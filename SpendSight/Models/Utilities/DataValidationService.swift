//
//  DataValidationService.swift
//  SpendSight
//
//  Created by Harwinder Singh on 3/21/26.
//

import Foundation
import CoreData

// MARK: - Validation Errors

enum ValidationError: LocalizedError {
    case duplicateCategoryName(String)
    case duplicateAccountName(String)
    case systemCategoryProtected(String)
    case invalidCategoryName(String)
    case invalidAccountName(String)
    case invalidAmount
    case missingRequiredField(String)
    case referentialIntegrityViolation(String)
    case invalidDate
    case categoryInUse(String)
    case accountInUse(String)

    var errorDescription: String? {
        switch self {
        case .duplicateCategoryName(let name):
            return "A category named '\(name)' already exists. Please choose a different name."
        case .duplicateAccountName(let name):
            return "An account named '\(name)' already exists. Please choose a different name."
        case .systemCategoryProtected(let name):
            return "The '\(name)' category is a system category and cannot be modified or deleted."
        case .invalidCategoryName(let name):
            return "Category name '\(name)' is invalid. Names must be between 1-50 characters and contain only letters, numbers, and spaces."
        case .invalidAccountName(let name):
            return "Account name '\(name)' is invalid. Names must be between 1-50 characters."
        case .invalidAmount:
            return "Amount must be greater than 0."
        case .missingRequiredField(let field):
            return "Required field '\(field)' is missing or empty."
        case .referentialIntegrityViolation(let message):
            return "Data integrity error: \(message)"
        case .invalidDate:
            return "Date cannot be in the future."
        case .categoryInUse(let name):
            return "Category '\(name)' cannot be deleted because it has associated transactions."
        case .accountInUse(let name):
            return "Account '\(name)' cannot be deleted because it has associated transactions or income records."
        }
    }
}

// MARK: - DataValidationService

class DataValidationService {

    // MARK: - System Categories

    static let systemCategoryNames: Set<String> = [
        "Income", "Other", "Uncategorized", "Transfer"
    ]

    // MARK: - Category Validation

    /// Validates category data before creation
    static func validateCategory(_ category: Category, in context: NSManagedObjectContext) throws {
        guard let name = category.name, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.missingRequiredField("Category name")
        }

        try validateCategoryName(name, excludingCategory: category, in: context)

        // Validate color hex
        if let colorHex = category.colorHex, !isValidHexColor(colorHex) {
            throw ValidationError.missingRequiredField("Valid color")
        }

        // Validate icon
        if category.icon?.isEmpty == true {
            throw ValidationError.missingRequiredField("Category icon")
        }

        // Validate monthly budget if provided
        if category.monthlyBudget < 0 {
            throw ValidationError.invalidAmount
        }
    }

    /// Validates category name for duplicates and format
    static func validateCategoryName(_ name: String, excludingCategory: Category? = nil, in context: NSManagedObjectContext) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        // Check name format
        guard isValidCategoryName(trimmedName) else {
            throw ValidationError.invalidCategoryName(trimmedName)
        }

        // Check for duplicates
        if try categoryExists(named: trimmedName, excluding: excludingCategory, in: context) {
            throw ValidationError.duplicateCategoryName(trimmedName)
        }
    }

    /// Creates a new category with validation
    static func createCategory(
        name: String,
        colorHex: String,
        icon: String,
        monthlyBudget: Double?,
        categoryType: Category.CategoryType = .expense,
        isSystemCategory: Bool = false,
        in context: NSManagedObjectContext
    ) throws -> Category {

        try validateCategoryName(name, in: context)

        let category = Category(
            context: context,
            name: name,
            colorHex: colorHex,
            icon: icon,
            monthlyBudget: monthlyBudget,
            categoryType: categoryType,
            isSystemCategory: isSystemCategory
        )

        try validateCategory(category, in: context)
        return category
    }

    /// Checks if category can be safely deleted
    static func canDeleteCategory(_ category: Category, in context: NSManagedObjectContext) throws {
        guard let name = category.name else { return }

        // Protect system categories
        if systemCategoryNames.contains(name) {
            throw ValidationError.systemCategoryProtected(name)
        }

        // Check for associated transactions
        let transactionCount = try getTransactionCount(for: category, in: context)
        if transactionCount > 0 {
            throw ValidationError.categoryInUse(name)
        }
    }

    // MARK: - Account Validation

    /// Validates account data before creation
    static func validateAccount(_ account: Account, in context: NSManagedObjectContext) throws {
        guard let name = account.name, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.missingRequiredField("Account name")
        }

        try validateAccountName(name, excludingAccount: account, in: context)

        // Validate account type
        if account.type?.isEmpty == true {
            throw ValidationError.missingRequiredField("Account type")
        }

        // Validate last4 if provided
        if let last4 = account.last4, !last4.isEmpty {
            if !isValidLast4(last4) {
                throw ValidationError.missingRequiredField("Valid last 4 digits")
            }
        }
    }

    /// Validates account name for duplicates and format
    static func validateAccountName(_ name: String, excludingAccount: Account? = nil, in context: NSManagedObjectContext) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        // Check name format
        guard isValidAccountName(trimmedName) else {
            throw ValidationError.invalidAccountName(trimmedName)
        }

        // Check for duplicates
        if try accountExists(named: trimmedName, excluding: excludingAccount, in: context) {
            throw ValidationError.duplicateAccountName(trimmedName)
        }
    }

    /// Creates a new account with validation
    static func createAccount(
        name: String,
        type: String,
        institution: String? = nil,
        last4: String? = nil,
        in context: NSManagedObjectContext
    ) throws -> Account {

        try validateAccountName(name, in: context)

        let account = Account(
            context: context,
            name: name,
            type: type,
            institution: institution,
            last4: last4
        )

        try validateAccount(account, in: context)
        return account
    }

    /// Checks if account can be safely deleted
    static func canDeleteAccount(_ account: Account, in context: NSManagedObjectContext) throws {
        guard let name = account.name else { return }

        // Check for associated transactions
        let transactionCount = try getTransactionCount(for: account, in: context)
        if transactionCount > 0 {
            throw ValidationError.accountInUse(name)
        }

        // Check for associated income records
        let incomeCount = try getIncomeCount(for: account, in: context)
        if incomeCount > 0 {
            throw ValidationError.accountInUse(name)
        }
    }

    // MARK: - Transaction Validation

    /// Validates transaction data before creation
    static func validateTransaction(_ transaction: Transaction, in context: NSManagedObjectContext) throws {
        // Validate amount
        if transaction.amount == 0 {
            throw ValidationError.invalidAmount
        }

        // Validate date
        if let date = transaction.date, date > Date() {
            throw ValidationError.invalidDate
        }

        // Validate title
        if transaction.title?.trimmingCharacters(in: .whitespaces).isEmpty != false {
            throw ValidationError.missingRequiredField("Transaction title")
        }

        // Validate category exists
        if transaction.category == nil {
            throw ValidationError.referentialIntegrityViolation("Transaction must have a valid category")
        }

        // Validate account exists
        if transaction.account == nil {
            throw ValidationError.referentialIntegrityViolation("Transaction must have a valid account")
        }
    }

    /// Creates a new transaction with validation
    static func createTransaction(
        title: String,
        amount: Double,
        date: Date,
        merchant: String?,
        paymentMethod: String?,
        category: Category,
        account: Account,
        in context: NSManagedObjectContext
    ) throws -> Transaction {

        let transaction = Transaction(
            context: context,
            amount: amount,
            title: title,
            merchant: merchant ?? "",
            date: date,
            paymentMethod: paymentMethod ?? "",
            category: category,
            account: account
        )

        try validateTransaction(transaction, in: context)
        return transaction
    }

    // MARK: - Context Validation

    /// Validates the entire context for data integrity
    static func validateContext(_ context: NSManagedObjectContext) throws {
        // Validate all categories
        let categories = try getAllCategories(in: context)
        for category in categories {
            try validateCategory(category, in: context)
        }

        // Validate all accounts
        let accounts = try getAllAccounts(in: context)
        for account in accounts {
            try validateAccount(account, in: context)
        }

        // Validate all transactions
        let transactions = try getAllTransactions(in: context)
        for transaction in transactions {
            try validateTransaction(transaction, in: context)
        }
    }

    /// Performs a safe save with validation
    static func safeSave(_ context: NSManagedObjectContext) throws {
        // Validate context before saving
        try validateContext(context)

        // Save if validation passes
        if context.hasChanges {
            try context.save()
        }
    }

    // MARK: - Referential Integrity Checks

    /// Performs comprehensive referential integrity checks
    static func performIntegrityCheck(in context: NSManagedObjectContext) -> [String] {
        var issues: [String] = []

        do {
            // Check for orphaned transactions (missing category or account)
            let orphanedTransactions = try getOrphanedTransactions(in: context)
            if !orphanedTransactions.isEmpty {
                issues.append("Found \(orphanedTransactions.count) transactions with missing category or account references")
            }

            // Check for duplicate category names
            let duplicateCategories = try getDuplicateCategories(in: context)
            if !duplicateCategories.isEmpty {
                issues.append("Found duplicate category names: \(duplicateCategories.joined(separator: ", "))")
            }

            // Check for duplicate account names
            let duplicateAccounts = try getDuplicateAccounts(in: context)
            if !duplicateAccounts.isEmpty {
                issues.append("Found duplicate account names: \(duplicateAccounts.joined(separator: ", "))")
            }

            // Check for missing system categories
            let missingSystemCategories = getMissingSystemCategories(in: context)
            if !missingSystemCategories.isEmpty {
                issues.append("Missing system categories: \(missingSystemCategories.joined(separator: ", "))")
            }

        } catch {
            issues.append("Error during integrity check: \(error.localizedDescription)")
        }

        return issues
    }

    // MARK: - Helper Methods

    private static func isValidCategoryName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.count >= 1 && trimmed.count <= 50 &&
               trimmed.rangeOfCharacter(from: CharacterSet.alphanumerics.union(.whitespaces).inverted) == nil
    }

    private static func isValidAccountName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.count >= 1 && trimmed.count <= 50
    }

    private static func isValidHexColor(_ hex: String) -> Bool {
        let pattern = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
        return hex.range(of: pattern, options: .regularExpression) != nil
    }

    private static func isValidLast4(_ last4: String) -> Bool {
        return last4.count == 4 && last4.allSatisfy { $0.isNumber }
    }

    private static func categoryExists(named name: String, excluding category: Category?, in context: NSManagedObjectContext) throws -> Bool {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", name)

        let results = try context.fetch(request)
        return results.contains { $0 != category }
    }

    private static func accountExists(named name: String, excluding account: Account?, in context: NSManagedObjectContext) throws -> Bool {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", name)

        let results = try context.fetch(request)
        return results.contains { $0 != account }
    }

    private static func getTransactionCount(for category: Category, in context: NSManagedObjectContext) throws -> Int {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        return try context.count(for: request)
    }

    private static func getTransactionCount(for account: Account, in context: NSManagedObjectContext) throws -> Int {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "account == %@", account)
        return try context.count(for: request)
    }

    private static func getIncomeCount(for account: Account, in context: NSManagedObjectContext) throws -> Int {
        let request: NSFetchRequest<Income> = Income.fetchRequest()
        request.predicate = NSPredicate(format: "account == %@", account)
        return try context.count(for: request)
    }

    private static func getAllCategories(in context: NSManagedObjectContext) throws -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        return try context.fetch(request)
    }

    private static func getAllAccounts(in context: NSManagedObjectContext) throws -> [Account] {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        return try context.fetch(request)
    }

    private static func getAllTransactions(in context: NSManagedObjectContext) throws -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        return try context.fetch(request)
    }

    private static func getOrphanedTransactions(in context: NSManagedObjectContext) throws -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "category == nil OR account == nil")
        return try context.fetch(request)
    }

    private static func getDuplicateCategories(in context: NSManagedObjectContext) throws -> [String] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let categories = try context.fetch(request)

        var nameCount: [String: Int] = [:]
        for category in categories {
            if let name = category.name?.lowercased() {
                nameCount[name, default: 0] += 1
            }
        }

        return nameCount.compactMap { $0.value > 1 ? $0.key : nil }
    }

    private static func getDuplicateAccounts(in context: NSManagedObjectContext) throws -> [String] {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        let accounts = try context.fetch(request)

        var nameCount: [String: Int] = [:]
        for account in accounts {
            if let name = account.name?.lowercased() {
                nameCount[name, default: 0] += 1
            }
        }

        return nameCount.compactMap { $0.value > 1 ? $0.key : nil }
    }

    private static func getMissingSystemCategories(in context: NSManagedObjectContext) -> [String] {
        do {
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "isSystemCategory == YES")
            let systemCategories = try context.fetch(request)
            let existingNames = Set(systemCategories.compactMap { $0.name })

            return Array(systemCategoryNames.subtracting(existingNames))
        } catch {
            return Array(systemCategoryNames)
        }
    }
}

// MARK: - NSManagedObjectContext Extension

extension NSManagedObjectContext {
    /// Convenience method for safe save with validation
    func ss_saveWithValidation() throws {
        try DataValidationService.safeSave(self)
    }

    /// Convenience method for integrity check
    func ss_performIntegrityCheck() -> [String] {
        return DataValidationService.performIntegrityCheck(in: self)
    }
}

