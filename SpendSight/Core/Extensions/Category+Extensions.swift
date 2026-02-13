//
//  Category+Extensions.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/11/26.
//

import Foundation
import CoreData
import SwiftUI

extension Category {
    
    // MARK: - Convenience Initializer
    /// Convenience initializer for creating a new Category with all required parameters
    /// - Parameters:
    ///   - context: The NSManagedObjectContext to insert the category into
    ///   - name: The name of the category (e.g., "Groceries", "Entertainment")
    ///   - colorHex: Hex color string (e.g., "#FF5733")
    ///   - icon: SF Symbol name (e.g., "cart.fill", "film.fill")
    ///   - monthlyBudget: Optional monthly budget amount for this category
    
    convenience init(
        context: NSManagedObjectContext,
        name: String,
        colorHex: String,
        icon: String,
        monthlyBudget: Double? = nil
    ) {
        // Call the designated initializer
        self.init(context: context)
        
        // set other properties
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
        self.monthlyBudget = monthlyBudget ?? 0.0
    }
    
    // MARK: - Computed Properties
    /// Returns a SwiftUI Color from the hex string
    var color: Color {
        Color(hex: colorHex ?? "#000000") ?? .blue
    }
    
    /// Returns the hex color string (already stored, but for consistency)
    var hexColor: String {
        colorHex ?? "#000000"
    }
    
    /// Returns the SF Symbol name
    var sfSymbol: String {
        icon ?? "questionmark"
    }
    
    /// Returns true if category has a budget set
    var hasBudget: Bool {
        (monthlyBudget ?? 0) > 0
    }
    
    /// Returns formatted budget string
    var formattedBudget: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = Locale.current.currencySymbol ?? "$"
        formatter.maximumFractionDigits = 2
        guard let budget = formatter.string(from: NSNumber(value: monthlyBudget ?? 0)) else {
            return "$0.00"
        }
        return budget
    }
    
    /// Returns the number of transactions in this category
    var transactionCount: Int {
        transaction?.count ?? 0
    }
    
    /// Returns all transactions as an array (sorted by date descending)
    var transactionsArray: [Transaction] {
        let set = transaction as? Set<Transaction> ?? []
        return set.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }
    
    // MARK: - Fetch Request Builder
    /// Creates a fetch request for all categories
    /// - Parameters:
    ///   - sortDescriptors: Array of sort descriptors (defaults to name ascending)
    ///   - Returns: Configured NSFetchRequest
    
    static func fetchRequest(
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
    ) -> NSFetchRequest<Category> {
        let request = NSFetchRequest<Category>(entityName: "Category")
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    /// Fetch all categories sorted by name
    static func fetchAll() -> NSFetchRequest<Category> {
        return fetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)])
    }
    
    /// Fetch categories with budgets
    static func fetchWithBudgets() -> NSFetchRequest<Category> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "monthlyBudget > 0")
        return request
    }
    
    /// Fetch a category by name
    static func fetchByName(_ name: String) -> NSFetchRequest<Category> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", name)
        request.fetchLimit = 1
        return request
    }
    
    // MARK: - Sort Descriptors
    
    /// Sort by name (A-Z)
    static var sortByNameAscending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \Category.name, ascending: true)
    }
    
    /// Sort by name (Z-A)
    static var sortByNameDescending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \Category.name, ascending: false)
    }
    
    /// Sort by monthly budget (highest first)
    static var sortByBudgetDescending: NSSortDescriptor {
        NSSortDescriptor(key: "monthlyBudget", ascending: false)
    }
    
    
    // MARK: - Validation Methods
    
    /// Validates the category before saving
    /// - Throws: CategoryValidationError if validation fails
    /// - Returns: True if valid
    ///
    @discardableResult
    func validate() throws -> Bool {
        guard let name = name?.trimmingCharacters(in: .whitespaces), !name.isEmpty else {
            throw CategoryValidationError.invalidName
        }
        
        guard let hex = colorHex, hex.hasPrefix("#"), (hex.count == 7 || hex.count == 9) else {
            throw CategoryValidationError.invalidColorHex
        }
        
        guard let icon = icon?.trimmingCharacters(in: .whitespaces), !icon.isEmpty else {
            throw CategoryValidationError.invalidIcon
        }
        
        if (monthlyBudget ?? 0) < 0 {
            throw CategoryValidationError.negativeBudget
        }
        
        return true
    }
    
    // MARK: - Helper Methods
    /// Calculate total spending in this category for a given date range
    /// - Parameters:
    /// - startDate: Start date of the range
    /// - endDate: End date of the range
    /// - Returns: Total amount spent (positive number)
    
    func totalSpent(from startDate: Date, to endDate: Date) -> Double {
        let transactions = transactionsArray.filter {transaction in guard let date = transaction.date else {return false}
            return date >= startDate && date <= endDate && transaction.isExpense}
        
        return transactions.reduce(0) { $0 + abs($1.amount) }
    }
    
    /// Calculate total spending in this category for the current month
    /// - Returns: Total amount spent this month
    ///
    func totalSpentThisMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)), let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else { return 0 }
        return totalSpent(from: startOfMonth, to: endOfMonth)
    }
    
    /// Calculate budget remaining for the current month
    /// -  Returns: Amount remaining (negative if over budget)
    
    func budgetRemaining() -> Double {
        let budget = monthlyBudget ?? 0
        guard budget > 0 else {
            return 0
        }
        return budget - totalSpentThisMonth()
    }
    
    /// Check if over budget for the current month
    /// - Returns: True if spending exceeds budget
    func isOverBudget() -> Bool {
        let budget = monthlyBudget ?? 0
        guard budget > 0 else {
            return false
        }
        return totalSpentThisMonth() > budget
    }
    
    /// Budget usage percentage for the current month (0.0 to 1.0+)
    /// - Returns: Percentage of budget used (1.0 = 100%, can exceed 1.0 if over budget)
    func budgetUsagePercentage() -> Double {
        let budget = monthlyBudget ?? 0
        guard budget > 0 else {
            return 0
        }
        
        return totalSpentThisMonth() / budget
    }
}

// MARK: - Validation Errors

enum CategoryValidationError: LocalizedError {
    case invalidName
    case invalidColorHex
    case invalidIcon
    case negativeBudget
    
    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Category must have a non-empty name"
        case .invalidColorHex:
            return "Category must have a valid hex color (e.g., #FF5733)"
        case .invalidIcon:
            return "Category must have an icon"
        case .negativeBudget:
            return "Budget cannot be negative"
        }
    }
}

// MARK: - Identifiable Conformance (for SwiftUI)

// extension Category: Identifiable {
//     // Core Data objects already have an objectID, but we're using our UUID
// }

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize a Color from a hex string
    /// -  Parameter hex: Hex color string (e.g., "#FF5733" or "#FF5733FF")
    /// - Returns: Color or nil if invalid hex
    
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int) else {
            return nil
        }
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (no alpha)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // RGBA
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert Color to hex string
    var hexString: String {
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Default Categories Helper

extension Category {
    /// Create default categories for new users
    ///  - Parameter context: The managed object context
    /// - Returns: Array of default categories
    static func createDefaultCategories(in context: NSManagedObjectContext) -> [Category] {
        let defaults: [(name: String, color: String, icon: String, budget: Double?)] = [
            ("Groceries", "#4CAF50", "cart.fill", 500),
            ("Dining Out", "#FF9800", "fork.knife", 200),
            ("Transportation", "#2196F3", "car.fill", 150),
            ("Entertainment", "#9C27B0", "film.fill", 100),
            ("Shopping", "#E91E63", "bag.fill", 200),
            ("Utilities", "#795548", "bolt.fill", 300),
            ("Healthcare", "#F44336", "cross.case.fill", nil),
            ("Income", "#8BC34A", "dollarsign.circle.fill", nil),
            ("Other", "#9E9E9E", "questionmark.circle.fill", nil),
            ("Housing", "#607D8B", "house.fill", 1500)
        ]
        return defaults.map { item in
            Category(
                context: context,
                name: item.name,
                colorHex: item.color,
                icon: item.icon,
                monthlyBudget: item.budget
            )
        }
    }
}

