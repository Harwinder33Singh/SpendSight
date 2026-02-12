//
//  Categoryseedertests.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/12/26.
//

import SwiftUI
import CoreData

/// Helper methods for testing CategorySeeder
struct CategorySeederTestHelpers {
    
    /// Prints all categories in the database (for debugging)
    @MainActor
    static func printAllCategories(modelContext: NSManagedObjectContext) {
        let request = Category.fetchAll()
        do {
            let categories = try modelContext.fetch(request)
            print("\n📊 CATEGORIES IN DATABASE: \(categories.count)")
            print("─────────────────────────────────")
            for (index, category) in categories.enumerated() {
                let name = category.name ?? "Unnamed"
                let color = category.colorHex ?? "#000000"
                let icon = category.icon ?? "questionmark"
                print("\(index + 1). \(name)")
                print("   Color: \(color)")
                print("   Icon: \(icon)")
                let budget = category.monthlyBudget
                if budget > 0 {
                    print("   Budget: $\(String(format: "%.2f", budget))")
                } else {
                    print("   Budget: None")
                }
                print("")
            }
            print("─────────────────────────────────\n")
        } catch {
            print("❌ Error fetching categories: \(error)")
        }
    }
    
    /// Deletes all categories (for testing re-seeding)
    @MainActor
    static func deleteAllCategories(modelContext: NSManagedObjectContext) {
        let request = Category.fetchAll()
        do {
            let categories = try modelContext.fetch(request)
            for category in categories {
                modelContext.delete(category)
            }
            try modelContext.save()
            print("🗑️ Deleted \(categories.count) categories")
        } catch {
            print("❌ Error deleting categories: \(error)")
        }
    }
    
    /// Full reset: delete all categories AND reset seeding flag
    @MainActor
    static func fullReset(modelContext: NSManagedObjectContext) {
        print("\n🔄 PERFORMING FULL RESET")
        deleteAllCategories(modelContext: modelContext)
        CategorySeeder.resetSeedingFlag()
        print("✅ Full reset complete - restart app to re-seed\n")
    }
    
    /// Check seeding status
    static func checkSeedingStatus() {
        let needsSeeding = CategorySeeder.needsSeeding()
        print("\n📋 SEEDING STATUS")
        print("─────────────────────────────────")
        print("Needs Seeding: \(needsSeeding ? "YES" : "NO")")
        print("─────────────────────────────────\n")
    }
}

// MARK: - Debug View (Optional)

/// A simple debug view you can use to test seeding
struct CategorySeederDebugView: View {
    @Environment(\.managedObjectContext) private var modelContext
    
    var body: some View {
        List {
            Section("Seeding Status") {
                Button("Check Status") {
                    CategorySeederTestHelpers.checkSeedingStatus()
                }
                
                Button("Print All Categories") {
                    CategorySeederTestHelpers.printAllCategories(modelContext: modelContext)
                }
            }
            
            Section("Testing Actions") {
                Button("Reset Seeding Flag Only") {
                    CategorySeeder.resetSeedingFlag()
                }
                
                Button("Delete All Categories") {
                    CategorySeederTestHelpers.deleteAllCategories(modelContext: modelContext)
                }
                .foregroundStyle(.red)
                
                Button("Full Reset (Delete + Reset Flag)") {
                    CategorySeederTestHelpers.fullReset(modelContext: modelContext)
                }
                .foregroundStyle(.red)
            }
            
            Section("Re-seed") {
                Button("Seed Categories Now") {
                    CategorySeeder.seedIfNeeded(modelContext: modelContext)
                    CategorySeederTestHelpers.printAllCategories(modelContext: modelContext)
                }
            }
        }
        .navigationTitle("Category Seeder Debug")
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    return NavigationStack {
        CategorySeederDebugView()
            .environment(\.managedObjectContext, context)
    }
}
