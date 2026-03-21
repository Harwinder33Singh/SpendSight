//
//  CoreData+Save.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import CoreData
import Foundation

extension NSManagedObjectContext {
    /// Basic save with error handling
    func saveIfNeeded() {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            assertionFailure("Core Data save failed: \(error)")
        }
    }

    /// Saves the context if there are any changes
    func saveIfHasChanges() throws {
        if hasChanges {
            try save()
        }
    }

    /// Attempts to save with error handling
    func safeSave() {
        if hasChanges {
            do {
                try save()
            } catch {
                print("Failed to save Core Data context: \(error)")
                rollback()
            }
        }
    }

    /// Enhanced save with comprehensive validation using DataValidationService
    func saveWithValidation() throws {
        guard hasChanges else { return }

        // Use DataValidationService for validation
        try DataValidationService.safeSave(self)
    }

    /// Performs validation without saving
    func validateOnly() -> [String] {
        return DataValidationService.performIntegrityCheck(in: self)
    }

    /// Safely performs a block and saves with validation
    func performSafeOperation<T>(_ block: () throws -> T) -> Result<T, Error> {
        do {
            let result = try block()
            try saveWithValidation()
            return .success(result)
        } catch {
            rollback()
            return .failure(error)
        }
    }

    /// Returns a summary of pending changes for debugging
    var changesSummary: String {
        var summary: [String] = []

        if !insertedObjects.isEmpty {
            summary.append("Inserted: \(insertedObjects.count)")
        }

        if !updatedObjects.isEmpty {
            summary.append("Updated: \(updatedObjects.count)")
        }

        if !deletedObjects.isEmpty {
            summary.append("Deleted: \(deletedObjects.count)")
        }

        return summary.isEmpty ? "No changes" : summary.joined(separator: ", ")
    }

    /// Validates and deletes an object safely
    func safeDelete<T: NSManagedObject>(_ object: T) throws {
        // Perform type-specific validation before deletion
        if let category = object as? Category {
            try category.validateForDeletion()
        } else if let account = object as? Account {
            try account.validateForDeletion()
        }

        delete(object)
    }

    /// Batch delete with validation
    func safeBatchDelete<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil
    ) throws -> Int {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entityType))
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }

        let objects = try fetch(fetchRequest)

        // Validate each object before deletion
        for object in objects {
            try safeDelete(object)
        }

        try saveWithValidation()
        return objects.count
    }

    /// Creates a category with validation
    func createValidatedCategory(
        name: String,
        colorHex: String,
        icon: String,
        monthlyBudget: Double? = nil,
        categoryType: Category.CategoryType = .expense,
        isSystemCategory: Bool = false
    ) throws -> Category {
        return try DataValidationService.createCategory(
            name: name,
            colorHex: colorHex,
            icon: icon,
            monthlyBudget: monthlyBudget,
            categoryType: categoryType,
            isSystemCategory: isSystemCategory,
            in: self
        )
    }

    /// Creates an account with validation
    func createValidatedAccount(
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
            in: self
        )
    }

    /// Creates a transaction with validation
    func createValidatedTransaction(
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
            in: self
        )
    }

    /// Performs data integrity check and returns issues
    func performDataIntegrityCheck() -> [String] {
        return DataValidationService.performIntegrityCheck(in: self)
    }

    /// Ensures system categories exist
    func ensureSystemCategoriesExist() throws {
        let systemCategories = DataValidationService.systemCategoryNames
        let existingRequest: NSFetchRequest<Category> = Category.fetchRequest()
        existingRequest.predicate = NSPredicate(format: "isSystemCategory == YES")

        let existingCategories = try fetch(existingRequest)
        let existingNames = Set(existingCategories.compactMap { $0.name })

        for categoryName in systemCategories {
            if !existingNames.contains(categoryName) {
                let systemCategory: (name: String, color: String, icon: String, type: Category.CategoryType)

                switch categoryName {
                case "Income":
                    systemCategory = ("Income", "#8BC34A", "dollarsign.circle.fill", .income)
                case "Other":
                    systemCategory = ("Other", "#9E9E9E", "questionmark.circle.fill", .expense)
                case "Uncategorized":
                    systemCategory = ("Uncategorized", "#9E9E9E", "questionmark.diamond.fill", .expense)
                case "Transfer":
                    systemCategory = ("Transfer", "#607D8B", "arrow.left.arrow.right.circle.fill", .transfer)
                default:
                    continue
                }

                _ = try createValidatedCategory(
                    name: systemCategory.name,
                    colorHex: systemCategory.color,
                    icon: systemCategory.icon,
                    monthlyBudget: nil,
                    categoryType: systemCategory.type,
                    isSystemCategory: true
                )
            }
        }

        try saveWithValidation()
    }

    /// Runs comprehensive validation tests
    func runValidationTests() -> ValidationTestResult {
        return ValidationFramework.runValidationTests(in: self)
    }

    /// Quick validation health check
    func isDataValid() -> Bool {
        let testResults = runValidationTests()
        return testResults.allTestsPassed
    }
}