//
//  ValidationFramework.swift
//  SpendSight
//
//  Created by Harwinder Singh on 3/21/26.
//

import Foundation
import CoreData

// MARK: - Validation Framework

/// Comprehensive validation framework for data integrity testing
class ValidationFramework {

    // MARK: - Test Suite

    /// Runs comprehensive validation tests
    static func runValidationTests(in context: NSManagedObjectContext) -> ValidationTestResult {
        var results = ValidationTestResult()

        // Test 1: Duplicate name checking
        results.addTest("Duplicate Category Names", passed: testDuplicateCategoryNames(context))
        results.addTest("Duplicate Account Names", passed: testDuplicateAccountNames(context))

        // Test 2: System category protection
        results.addTest("System Category Protection", passed: testSystemCategoryProtection(context))

        // Test 3: Referential integrity
        results.addTest("Referential Integrity", passed: testReferentialIntegrity(context))

        // Test 4: Validation error handling
        results.addTest("Validation Error Handling", passed: testValidationErrorHandling(context))

        // Test 5: Data consistency
        results.addTest("Data Consistency", passed: testDataConsistency(context))

        return results
    }

    // MARK: - Individual Test Methods

    private static func testDuplicateCategoryNames(_ context: NSManagedObjectContext) -> Bool {
        do {
            // Try to create a category
            let category1 = try context.createValidatedCategory(
                name: "Test Category",
                colorHex: "#FF0000",
                icon: "star.fill"
            )

            // Try to create another category with the same name (should fail)
            do {
                let _ = try context.createValidatedCategory(
                    name: "Test Category",
                    colorHex: "#00FF00",
                    icon: "heart.fill"
                )
                // If we get here, validation failed
                context.delete(category1)
                return false
            } catch ValidationError.duplicateCategoryName {
                // This is expected - cleanup and return success
                context.delete(category1)
                return true
            } catch {
                context.delete(category1)
                return false
            }
        } catch {
            return false
        }
    }

    private static func testDuplicateAccountNames(_ context: NSManagedObjectContext) -> Bool {
        do {
            // Try to create an account
            let account1 = try context.createValidatedAccount(
                name: "Test Account",
                type: "Checking"
            )

            // Try to create another account with the same name (should fail)
            do {
                let _ = try context.createValidatedAccount(
                    name: "Test Account",
                    type: "Savings"
                )
                // If we get here, validation failed
                context.delete(account1)
                return false
            } catch ValidationError.duplicateAccountName {
                // This is expected - cleanup and return success
                context.delete(account1)
                return true
            } catch {
                context.delete(account1)
                return false
            }
        } catch {
            return false
        }
    }

    private static func testSystemCategoryProtection(_ context: NSManagedObjectContext) -> Bool {
        do {
            // Ensure system categories exist
            try context.ensureSystemCategoriesExist()

            // Try to find a system category
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "isSystemCategory == YES")
            request.fetchLimit = 1

            let systemCategories = try context.fetch(request)
            guard let systemCategory = systemCategories.first else {
                return false
            }

            // Try to delete the system category (should fail)
            do {
                try systemCategory.validateForDeletion()
                // If we get here, validation failed
                return false
            } catch ValidationError.systemCategoryProtected {
                // This is expected
                return true
            } catch {
                return false
            }
        } catch {
            return false
        }
    }

    private static func testReferentialIntegrity(_ context: NSManagedObjectContext) -> Bool {
        do {
            // Create test data
            let category = try context.createValidatedCategory(
                name: "Test Category RI",
                colorHex: "#FF0000",
                icon: "star.fill"
            )

            let account = try context.createValidatedAccount(
                name: "Test Account RI",
                type: "Checking"
            )

            // Create a transaction
            let transaction = try context.createValidatedTransaction(
                title: "Test Transaction",
                amount: -10.0,
                date: Date(),
                merchant: "Test Merchant",
                paymentMethod: "Credit Card",
                category: category,
                account: account
            )

            // Try to delete category with associated transactions (should fail)
            do {
                try category.validateForDeletion()
                // Cleanup
                context.delete(transaction)
                context.delete(category)
                context.delete(account)
                return false
            } catch ValidationError.categoryInUse {
                // This is expected - cleanup and return success
                context.delete(transaction)
                context.delete(category)
                context.delete(account)
                return true
            } catch {
                context.delete(transaction)
                context.delete(category)
                context.delete(account)
                return false
            }
        } catch {
            return false
        }
    }

    private static func testValidationErrorHandling(_ context: NSManagedObjectContext) -> Bool {
        // Test invalid category name
        do {
            let _ = try context.createValidatedCategory(
                name: "",
                colorHex: "#FF0000",
                icon: "star.fill"
            )
            return false
        } catch ValidationError.missingRequiredField {
            // Expected
        } catch {
            return false
        }

        // Test invalid amount
        do {
            let category = try context.createValidatedCategory(
                name: "Test Category VEH",
                colorHex: "#FF0000",
                icon: "star.fill"
            )

            let account = try context.createValidatedAccount(
                name: "Test Account VEH",
                type: "Checking"
            )

            let _ = try context.createValidatedTransaction(
                title: "Test Transaction",
                amount: 0.0, // Invalid amount
                date: Date(),
                merchant: "Test Merchant",
                paymentMethod: "Credit Card",
                category: category,
                account: account
            )

            context.delete(category)
            context.delete(account)
            return false
        } catch ValidationError.invalidAmount {
            // Expected - cleanup
            let categories = try? context.fetch(Category.fetchByName("Test Category VEH"))
            let accounts = try? context.fetch(Account.fetchByName("Test Account VEH"))
            categories?.forEach(context.delete)
            accounts?.forEach(context.delete)
        } catch {
            return false
        }

        return true
    }

    private static func testDataConsistency(_ context: NSManagedObjectContext) -> Bool {
        do {
            // Run integrity check
            let issues = context.performDataIntegrityCheck()

            // For now, we consider it successful if no critical errors are found
            // In a real app, you might want to validate specific consistency rules
            let criticalIssues = issues.filter { $0.contains("missing") || $0.contains("orphaned") }
            return criticalIssues.isEmpty
        } catch {
            return false
        }
    }
}

// MARK: - Test Results

struct ValidationTestResult {
    private var tests: [(name: String, passed: Bool)] = []

    mutating func addTest(_ name: String, passed: Bool) {
        tests.append((name, passed))
    }

    var allTestsPassed: Bool {
        return tests.allSatisfy { $0.passed }
    }

    var passedCount: Int {
        return tests.filter { $0.passed }.count
    }

    var totalCount: Int {
        return tests.count
    }

    var summary: String {
        let status = allTestsPassed ? "✅ ALL PASSED" : "❌ SOME FAILED"
        return "\(status) (\(passedCount)/\(totalCount))"
    }

    var detailedResults: [String] {
        return tests.map { test in
            let status = test.passed ? "✅" : "❌"
            return "\(status) \(test.name)"
        }
    }

    func printResults() {
        print("🧪 Validation Test Results:")
        print("=" * 40)
        print(summary)
        print()

        for result in detailedResults {
            print(result)
        }

        if !allTestsPassed {
            print("\n⚠️ Some tests failed. Please review the validation implementation.")
        } else {
            print("\n🎉 All validation tests passed!")
        }
    }
}

// MARK: - String Extension for Repeat

private extension String {
    static func * (string: String, count: Int) -> String {
        return String(repeating: string, count: count)
    }
}