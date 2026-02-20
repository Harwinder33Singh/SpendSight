//
//  UserProfile+Extensions.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/18/26.
//

import Foundation
import CoreData

extension UserProfile {
    
    // MARK: - Convenience Initializer
    
    convenience init(
        context: NSManagedObjectContext,
        fullName: String,
        email: String? = nil,
        phone: String? = nil,
        currency: String = "USD",
        profileImageData: Data? = nil
    ) {
        self.init(context: context)
        
        self.id = UUID()
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.currency = currency
        self.profileImageData = profileImageData
        self.hasCompletedOnboarding = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    var displayName: String {
        fullName ?? "User"
    }
    
    var initials: String {
        let components = (fullName ?? "").components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
    
    var currencySymbol: String {
        let locale = Locale(identifier: "en_US_POSIX")
        let symbol = locale.currencySymbol ?? "$"
        
        switch currency {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "INR": return "₹"
        case "CAD": return "C$"
        case "AUD": return "A$"
        default: return symbol
        }
    }
    
    // MARK: - Fetch Requests
    
    static func defaultFetchRequest() -> NSFetchRequest<UserProfile> {
        let request = NSFetchRequest<UserProfile>(entityName: "UserProfile")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserProfile.createdAt, ascending: true)]
        return request
    }
    
    static func fetchCurrentUser() -> NSFetchRequest<UserProfile> {
        let request = defaultFetchRequest()
        request.fetchLimit = 1
        return request
    }
    
    // MARK: - Helper Methods
    
    func completeOnboarding() {
        self.hasCompletedOnboarding = true
        self.updatedAt = Date()
    }
    
    func updateProfile(
        fullName: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        currency: String? = nil
    ) {
        if let fullName = fullName { self.fullName = fullName }
        if let email = email { self.email = email }
        if let phone = phone { self.phone = phone }
        if let currency = currency { self.currency = currency }
        self.updatedAt = Date()
    }
}

// MARK: - Validation

extension UserProfile {
    func validate() throws {
        guard let name = fullName?.trimmingCharacters(in: .whitespaces), !name.isEmpty else {
            throw ValidationError.invalidName
        }
        
        if let email = email, !email.isEmpty {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            guard emailPredicate.evaluate(with: email) else {
                throw ValidationError.invalidEmail
            }
        }
    }
    
    enum ValidationError: LocalizedError {
        case invalidName
        case invalidEmail
        
        var errorDescription: String? {
            switch self {
            case .invalidName:
                return "Please enter a valid name"
            case .invalidEmail:
                return "Please enter a valid email address"
            }
        }
    }
}

