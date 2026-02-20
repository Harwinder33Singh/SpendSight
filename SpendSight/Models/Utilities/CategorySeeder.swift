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
    private static let defaultCategories: [(name: String, color: String, icon: String, budget: Double?)] = [("Groceries", "#4CAF50", "cart.fill", 500),
    ("Coffee", "#6F4E37", "cup.and.saucer.fill", 80),
    ("Dining Out", "#FF9800", "fork.knife", 200),
    ("Transportation", "#2196F3", "car.fill", 150),
    ("Fuel", "#FF6F00", "fuelpump.fill", 180),
    ("Entertainment", "#9C27B0", "film.fill", 100),
    ("Shopping", "#E91E63", "bag.fill", 200),
    ("Utilities", "#795548", "bolt.fill", 300),
    ("Healthcare", "#F44336", "cross.case.fill", nil),
    ("Hotel", "#3F51B5", "bed.double.fill", 250),
    ("Flight", "#00ACC1", "airplane", 300),
    ("Travel", "#26A69A", "suitcase.rolling.fill", 400),
    ("Subscriptions", "#7E57C2", "tv.fill", 50),
    ("Credit Card Payment", "#FF5722", "creditcard.and.123", nil),
    ("Income", "#8BC34A", "dollarsign.circle.fill", nil),
    ("Other", "#9E9E9E", "questionmark.circle.fill", nil),
    ("Housing", "#607D8B", "house.fill", 1500)]
    
    
    // MARK: - Seeding Method
    
    /// Seeds default categories if they haven't been seeded before
    /// - Parameter modelContext: The Core Data managed object context to insert categories into
    ///
    static func seedIfNeeded(modelContext: NSManagedObjectContext) {
        // Check if categories have already been seeded
        guard !hasSeeded else {
            print("✅ Categories already seeded, skipping...")
            return
        }
        
        print("🌱 Starting category seeding...")
        
        // Create and insert each default category
        for categoryData in defaultCategories {
            let _ = Category(
                context: modelContext,
                name: categoryData.name,
                colorHex: categoryData.color,
                icon: categoryData.icon,
                monthlyBudget: categoryData.budget
            )
            print("  ✓ Created: \(categoryData.name)")
        }
        
        // Save the context
        do {
            try modelContext.save()
            print("💾 Categories saved successfully")
            
            // Mark as seeded
            markAsSeeded()
            print("✅ Category seeding complete!")
        } catch {
            print("❌ Error saving categories: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    /// Check if categories have been seeded
    
    private static var hasSeeded: Bool {
        UserDefaults.standard.bool(forKey: hasSeededKey)
    }
    
//    /// Mark categories as seeded in UserDefaults
//    private static func markAsSeeded() {
//        UserDefaults.standard.set(true, forKey: hasSeededKey)
//    }
    
    /// Reset seeding flag (useful for testing)
    static func resetSeedingFlag() {
        UserDefaults.standard.removeObject(forKey: hasSeededKey)
        print("🔄 Seeding flag reset - categories will be re-seeded on next launch")
    }
    
    /// Check if seeding is needed (useful for testing/debugging)
    static func needsSeeding() -> Bool {
        !hasSeeded
    }
}
