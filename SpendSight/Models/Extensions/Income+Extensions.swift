//
//  Income+Extensions.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/11/26.
//

import Foundation
import CoreData

extension Income {
    
    // MARK: - Convenience Initializer
    
    /// Convenience initializer for creating a new Income with all required parameters
    /// - Parameters:
    ///   - context: The NSManagedObjectContext to insert the income into
    ///   - amount: The income amount (must be greater than zero)
    ///   - source: The source of income (e.g., "Salary", "Freelance")
    ///   - date: The date of the income entry (defaults to current date)
    ///   - notes: Optional notes about the income
    ///   - account: Optional account this income is associated with
    convenience init(
        context: NSManagedObjectContext,
        amount: Double,
        source: String,
        date: Date = Date(),
        notes: String? = nil,
        account: Account? = nil
    ) {
        // Call the designated initializer
        self.init(context: context)
        
        // Set the properties
        self.id = UUID()
        self.amount = amount
        self.source = source
        self.date = date
        self.notes = notes
        self.account = account
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = Locale.current.currencySymbol ?? "$"
        formatter.maximumFractionDigits = 2
        guard let amount = formatter.string(from: NSNumber(value: amount)) else {
            return "$0.00"
        }
        return amount
    }
    
    /// Returns account name or a fallback if account is nil
    var accountName: String {
        account?.name ?? "Unknown Account"
    }
    
    /// Returns source with fallback
    var displaySource: String {
        source ?? "Unknown Source"
    }
    
    // MARK: - Fetch Request Builder
    
    /// Creates a fetch request with optional filters
    /// - Parameters:
    ///   - startDate: Optional start date filter
    ///   - endDate: Optional end date filter
    ///   - account: Optional account filter
    ///   - source: Optional source filter
    ///   - sortDescriptors: Array of sort descriptors (defaults to date descending)
    /// - Returns: Configured NSFetchRequest
    static func fetchRequest(
        startDate: Date? = nil,
        endDate: Date? = nil,
        account: Account? = nil,
        source: String? = nil,
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \Income.date, ascending: false)]
    ) -> NSFetchRequest<Income> {
        let request = NSFetchRequest<Income>(entityName: "Income")
        
        var predicates: [NSPredicate] = []
        
        // Date range filter
        if let startDate = startDate, let endDate = endDate {
            predicates.append(NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate as NSDate, endDate as NSDate))
        }
        
        // Account filter
        if let account = account {
            predicates.append(NSPredicate(format: "account == %@", account))
        }
        
        // Source filter
        if let source = source {
            predicates.append(NSPredicate(format: "source ==[cd] %@", source))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    /// Fetch all income entries
    static func fetchAll() -> NSFetchRequest<Income> {
        return fetchRequest()
    }
    
    /// Fetch income entries for a specific month
    static func fetchForMonth(year: Int, month: Int) -> NSFetchRequest<Income> {
        let components = DateComponents(year: year, month: month, day: 1)
        
        guard let startDate = Calendar.current.date(from: components),
              let endDate = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) else {
            return fetchAll()
        }
        
        return fetchRequest(startDate: startDate, endDate: endDate)
    }
    
    /// Fetch income entries by source
    static func fetchBySource(_ source: String) -> NSFetchRequest<Income> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "source ==[cd] %@", source)
        return request
    }
    
    // MARK: - Sort Descriptors
    
    /// Sort by date (newest first)
    static var sortByDateDescending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \Income.date, ascending: false)
    }
    
    /// Sort by date (oldest first)
    static var sortByDateAscending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \Income.date, ascending: true)
    }
    
    /// Sort by amount (highest first)
    static var sortByAmountDescending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \Income.amount, ascending: false)
    }
    
    /// Sort by amount (lowest first)
    static var sortByAmountAscending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \Income.amount, ascending: true)
    }
    
    /// Sort by source (A-Z)
    static var sortBySourceAscending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \Income.source, ascending: true)
    }
    
    // MARK: - Validation Methods
    
    /// Validates the income before saving
    /// - Throws: IncomeValidationError if validation fails
    /// - Returns: True if valid
    @discardableResult
    func validate() throws -> Bool {
        guard amount > 0 else {
            throw IncomeValidationError.invalidAmount
        }
        
        guard let source = source?.trimmingCharacters(in: .whitespaces), !source.isEmpty else {
            throw IncomeValidationError.invalidSource
        }
        
        guard date != nil else {
            throw IncomeValidationError.missingDate
        }
        
        return true
    }
    
    // MARK: - Helper Methods
    
    /// Check if income falls within date range
    /// - Parameters:
    ///   - startDate: Start date
    ///   - endDate: End date
    /// - Returns: True if income date is in range
    func isInDateRange(from startDate: Date, to endDate: Date) -> Bool {
        guard let date = date else {
            return false
        }
        return date >= startDate && date <= endDate
    }
}

// MARK: - Validation Errors

enum IncomeValidationError: LocalizedError {
    case invalidAmount
    case invalidSource
    case missingDate
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Income amount must be greater than zero"
        case .invalidSource:
            return "Income must have a source"
        case .missingDate:
            return "Income must have a date"
        }
    }
}

// MARK: - Identifiable Conformance (for SwiftUI)

// extension Income: Identifiable {
//     // Core Data objects already have an objectID, but we're using our UUID
// }
