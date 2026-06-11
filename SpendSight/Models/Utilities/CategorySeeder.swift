//
//  CategorySeeder.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/12/26.
//

import SwiftUI
import CoreData

/// Utility class to seed default categories on first app launch
@MainActor
class CategorySeeder {
    // MARK: - UserDefaults Key
    private static let hasSeededKey = "hasSeededCategories"
    
    // MARK: - Default Categories
    private static let defaultCategories: [(name: String, color: String, icon: String, budget: Double?, type: Category.CategoryType)] = [
        ("Groceries",           "#4CAF50", "cart.fill",               500,  .expense),
        ("Coffee",              "#6F4E37", "cup.and.saucer.fill",      80,   .expense),
        ("Dining Out",          "#FF9800", "fork.knife",               200,  .expense),
        ("Transportation",      "#2196F3", "car.fill",                 150,  .expense),
        ("Fuel",                "#FF6F00", "fuelpump.fill",            180,  .expense),
        ("Entertainment",       "#9C27B0", "film.fill",                100,  .expense),
        ("Shopping",            "#E91E63", "bag.fill",                 200,  .expense),
        ("Utilities",           "#795548", "bolt.fill",                300,  .expense),
        ("Healthcare",          "#F44336", "cross.case.fill",          nil,  .expense),
        ("Hotel",               "#3F51B5", "bed.double.fill",          250,  .expense),
        ("Flight",              "#00ACC1", "airplane",                 300,  .expense),
        ("Travel",              "#26A69A", "suitcase.rolling.fill",    400,  .expense),
        ("Subscriptions",       "#7E57C2", "tv.fill",                  50,   .expense),
        ("Credit Card Payment", "#FF5722", "creditcard.and.123",       nil,  .expense),
        ("Income",              "#8BC34A", "dollarsign.circle.fill",   nil,  .income),
        ("Other",               "#9E9E9E", "questionmark.circle.fill", nil,  .expense),
        ("Housing",             "#607D8B", "house.fill",               1500, .expense),
    ]


    // MARK: - Seeding Method

    /// Seeds default categories if they haven't been seeded before
    static func seedIfNeeded(modelContext: NSManagedObjectContext) {
        guard !hasSeeded else { return }

        for categoryData in defaultCategories {
            let _ = Category(
                context: modelContext,
                name: categoryData.name,
                colorHex: categoryData.color,
                icon: categoryData.icon,
                monthlyBudget: categoryData.budget,
                categoryType: categoryData.type
            )
        }
        
        // Save the context
        do {
            try modelContext.save()
            // Mark as seeded
            markAsSeeded()
        } catch {
            // Handle seeding errors silently
        }
    }
    
    /// Seeds only the named categories (from the defaults list) — used when restoring
    /// a returning user's selection on a new device.
    static func seedSpecific(names: [String], modelContext: NSManagedObjectContext) {
        guard !hasSeeded else { return }

        for categoryData in defaultCategories where names.contains(categoryData.name) {
            _ = Category(
                context: modelContext,
                name: categoryData.name,
                colorHex: categoryData.color,
                icon: categoryData.icon,
                monthlyBudget: categoryData.budget,
                categoryType: categoryData.type
            )
        }

        do {
            try modelContext.save()
            markAsSeeded()
        } catch {}
    }

    // MARK: - Migration

    /// Fixes existing Income category whose typeRaw was incorrectly seeded as "expense"
    static func fixIncomeTypeMigration(modelContext: NSManagedObjectContext) {
        let request = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@ AND (type == nil OR type != %@)", "Income", "income")
        guard let broken = try? modelContext.fetch(request), !broken.isEmpty else { return }
        for category in broken {
            category.typeRaw = Category.CategoryType.income.rawValue
        }
        try? modelContext.save()
    }

    // MARK: - Helper Methods

    private static var hasSeeded: Bool {
        UserDefaults.standard.bool(forKey: hasSeededKey)
    }
    
    /// Reset seeding flag (useful for testing)
    static func resetSeedingFlag() {
        UserDefaults.standard.removeObject(forKey: hasSeededKey)
        // Seeding flag reset - categories will be re-seeded on next launch
    }
    
    /// Check if seeding is needed (useful for testing/debugging)
    static func needsSeeding() -> Bool {
        !hasSeeded
    }
}
