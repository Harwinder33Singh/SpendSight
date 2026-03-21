//
//  SavingsPlan+Extensions.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/11/26.
//

import Foundation
import CoreData

extension SavingsPlan {
    
    // MARK: - Convenience Initializer
    
    /// Convenience initializer for creating a new SavingsPlan with all required parameters
    /// - Parameters:
    ///   - context: The NSManagedObjectContext to insert the savings plan into
    ///   - targetAmount: The target savings amount (must be greater than zero)
    ///   - currentAmount: The current saved amount (defaults to 0)
    ///   - month: The month this plan belongs to (defaults to current date)
    ///   - notes: Optional notes for this plan
    convenience init(
        context: NSManagedObjectContext,
        targetAmount: Double,
        currentAmount: Double = 0,
        month: Date = Date(),
        notes: String? = nil
    ) {
        // Call the designated initializer
        self.init(context: context)
        
        // Set the properties
        self.id = UUID()
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.month = month
        self.notes = notes
    }
    
    // MARK: - Computed Properties
    
    /// Returns the remaining amount needed to reach the target (never below 0)
    var remainingAmount: Double {
        max((targetAmount) - (currentAmount), 0)
    }
    
    /// Returns the progress percentage from 0.0 to 1.0+
    var progressPercentage: Double {
        guard targetAmount > 0 else {
            return 0
        }
        return currentAmount / targetAmount
    }
    
    /// Returns true if the savings goal has been completed
    var isComplete: Bool {
        targetAmount > 0 && currentAmount >= targetAmount
    }
    
    /// Returns a formatted target amount string with currency symbol
    var formattedTargetAmount: String {
        return CurrencyService.shared.formatAmount(targetAmount)
    }
    
    /// Returns a formatted current amount string with currency symbol
    var formattedCurrentAmount: String {
        return CurrencyService.shared.formatAmount(currentAmount)
    }
    
    /// Returns a formatted remaining amount string with currency symbol
    var formattedRemainingAmount: String {
        return CurrencyService.shared.formatAmount(remainingAmount)
    }
    
    /// Returns a display month string (e.g., "February 2026")
    var displayMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month ?? Date())
    }
    
    // MARK: - Fetch Request Builder
    
    /// Creates a fetch request with optional filters
    /// - Parameters:
    ///   - month: Optional month filter
    ///   - isComplete: Optional completion status filter
    ///   - sortDescriptors: Array of sort descriptors (defaults to month descending)
    /// - Returns: Configured NSFetchRequest
    static func fetchRequest(
        month: Date? = nil,
        isComplete: Bool? = nil,
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \SavingsPlan.month, ascending: false)]
    ) -> NSFetchRequest<SavingsPlan> {
        let request = NSFetchRequest<SavingsPlan>(entityName: "SavingsPlan")
        
        var predicates: [NSPredicate] = []
        
        // Month filter (same calendar month)
        if let month = month {
            let calendar = Calendar.current
            if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
               let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) {
                predicates.append(NSPredicate(format: "(month >= %@) AND (month <= %@)", startOfMonth as NSDate, endOfMonth as NSDate))
            }
        }
        
        // Completion filter
        if let isComplete = isComplete {
            if isComplete {
                predicates.append(NSPredicate(format: "currentAmount >= targetAmount"))
            } else {
                predicates.append(NSPredicate(format: "currentAmount < targetAmount"))
            }
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    /// Fetch all savings plans
    static func fetchAll() -> NSFetchRequest<SavingsPlan> {
        return fetchRequest()
    }
    
    /// Fetch active savings plans (not yet complete)
    static func fetchActivePlans() -> NSFetchRequest<SavingsPlan> {
        return fetchRequest(isComplete: false)
    }
    
    /// Fetch completed savings plans
    static func fetchCompletedPlans() -> NSFetchRequest<SavingsPlan> {
        return fetchRequest(isComplete: true)
    }
    
    /// Fetch plan for a specific month
    static func fetchForMonth(_ month: Date) -> NSFetchRequest<SavingsPlan> {
        let request = fetchRequest(month: month)
        request.fetchLimit = 1
        return request
    }
    
    // MARK: - Sort Descriptors
    
    /// Sort by month (newest first)
    static var sortByMonthDescending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \SavingsPlan.month, ascending: false)
    }
    
    /// Sort by month (oldest first)
    static var sortByMonthAscending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \SavingsPlan.month, ascending: true)
    }
    
    /// Sort by target amount (highest first)
    static var sortByTargetAmountDescending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \SavingsPlan.targetAmount, ascending: false)
    }
    
    /// Sort by current amount (highest first), as proxy for progress
    static var sortByProgressDescending: NSSortDescriptor {
        NSSortDescriptor(keyPath: \SavingsPlan.currentAmount, ascending: false)
    }
    
    // MARK: - Validation Methods
    
    /// Validates the savings plan before saving
    /// - Throws: SavingsPlanValidationError if validation fails
    /// - Returns: True if valid
    @discardableResult
    func validate() throws -> Bool {
        guard targetAmount > 0 else {
            throw SavingsPlanValidationError.invalidTargetAmount
        }
        
        guard currentAmount >= 0 else {
            throw SavingsPlanValidationError.invalidCurrentAmount
        }
        
        guard month != nil else {
            throw SavingsPlanValidationError.missingMonth
        }
        
        return true
    }
    
    // MARK: - Helper Methods
    
    /// Add to the current savings amount
    /// - Parameter amount: Amount to add (must be positive)
    func addContribution(_ amount: Double) throws {
        guard amount > 0 else {
            throw SavingsPlanValidationError.invalidContribution
        }
        self.currentAmount += amount
    }
}

// MARK: - Validation Errors

enum SavingsPlanValidationError: LocalizedError {
    case invalidTargetAmount
    case invalidCurrentAmount
    case missingMonth
    case invalidContribution
    
    var errorDescription: String? {
        switch self {
        case .invalidTargetAmount:
            return "Target amount must be greater than zero"
        case .invalidCurrentAmount:
            return "Current amount cannot be negative"
        case .missingMonth:
            return "Savings plan must have a month"
        case .invalidContribution:
            return "Contribution amount must be greater than zero"
        }
    }
}

// MARK: - Identifiable Conformance (for SwiftUI)

// extension SavingsPlan: Identifiable {
//     // Core Data objects already have an objectID, but we're using our UUID
// }
