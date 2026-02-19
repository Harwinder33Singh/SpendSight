//
//  OnboardingViewModel.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/18/26.
//

import SwiftUI
import CoreData
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentStep: OnboardingStep = .welcome
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var selectedCurrency: String = "USD"
    
    @Published var selectedCategories: Set<String> = []
    @Published var accounts: [AccountData] = []
    
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var didCompleteOnboarding: Bool = false
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    let availableCurrencies = ["USD", "EUR", "GBP", "INR", "CAD", "AUD"]
    
    // Default categories (user can select which ones they want)
    let defaultCategories: [(name: String, color: String, icon: String, budget: Double?)] = [
        ("Groceries", "#4CAF50", "cart.fill", 500),
        ("Dining Out", "#FF9800", "fork.knife", 200),
        ("Transportation", "#2196F3", "car.fill", 150),
        ("Entertainment", "#9C27B0", "film.fill", 100),
        ("Shopping", "#E91E63", "bag.fill", 200),
        ("Utilities", "#795548", "bolt.fill", 300),
        ("Healthcare", "#F44336", "cross.case.fill", nil),
        ("Credit Card Payment", "#FF5722", "creditcard.and.123", nil),
        ("Income", "#8BC34A", "dollarsign.circle.fill", nil),
        ("Other", "#9E9E9E", "questionmark.circle.fill", nil),
        ("Housing", "#607D8B", "house.fill", 1500)
    ]
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        self.context = context
        // Pre-select all categories by default
        self.selectedCategories = Set(defaultCategories.map { $0.name })
    }
    
    // MARK: - Navigation
    
    func nextStep() {
        switch currentStep {
        case .welcome:
            currentStep = .personalInfo
        case .personalInfo:
            if validatePersonalInfo() {
                currentStep = .categories
            }
        case .categories:
            if validateCategories() {
                currentStep = .accounts
            }
        case .accounts:
            currentStep = .security
        case .security:
            completeOnboarding()
        }
    }
    
    func previousStep() {
        switch currentStep {
        case .welcome:
            break
        case .personalInfo:
            currentStep = .welcome
        case .categories:
            currentStep = .personalInfo
        case .accounts:
            currentStep = .categories
        case .security:
            currentStep = .accounts
        }
    }
    
    func skipToStep(_ step: OnboardingStep) {
        currentStep = step
    }
    
    // MARK: - Validation
    
    private func validatePersonalInfo() -> Bool {
        let trimmedName = fullName.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedName.isEmpty else {
            showError(message: "Please enter your name")
            return false
        }
        
        if !email.isEmpty {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            guard emailPredicate.evaluate(with: email) else {
                showError(message: "Please enter a valid email address")
                return false
            }
        }
        
        return true
    }
    
    private func validateCategories() -> Bool {
        guard !selectedCategories.isEmpty else {
            showError(message: "Please select at least one category")
            return false
        }
        return true
    }
    
    // MARK: - Category Management
    
    func toggleCategory(_ categoryName: String) {
        if selectedCategories.contains(categoryName) {
            selectedCategories.remove(categoryName)
        } else {
            selectedCategories.insert(categoryName)
        }
    }
    
    func selectAllCategories() {
        selectedCategories = Set(defaultCategories.map { $0.name })
    }
    
    func deselectAllCategories() {
        selectedCategories.removeAll()
    }
    
    // MARK: - Account Management
    
    func addAccount(_ account: AccountData) {
        accounts.append(account)
    }
    
    func removeAccount(at index: Int) {
        accounts.remove(at: index)
    }
    
    func updateAccount(at index: Int, with account: AccountData) {
        accounts[index] = account
    }
    
    // MARK: - Onboarding Completion
    
    func completeOnboarding() {
        isLoading = true
        
        // Create user profile
        let userProfile = UserProfile(
            context: context,
            fullName: fullName,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone,
            currency: selectedCurrency
        )
        
        // Create selected categories
        for categoryName in selectedCategories {
            if let categoryData = defaultCategories.first(where: { $0.name == categoryName }) {
                let category = Category(
                    context: context,
                    name: categoryData.name,
                    colorHex: categoryData.color,
                    icon: categoryData.icon,
                    monthlyBudget: categoryData.budget
                )
            }
        }
        
        // Create accounts
        for accountData in accounts {
            let account = Account(
                context: context,
                name: accountData.name,
                type: accountData.type,
                institution: accountData.institution,
                last4: accountData.last4
            )
        }
        
        // Mark onboarding as complete
        userProfile.completeOnboarding()
        
        // Mark categories as seeded
        CategorySeeder.markAsSeeded()
        
        // Save everything
        do {
            try context.save()
            
            // Store onboarding completion in UserDefaults
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            
            isLoading = false
            didCompleteOnboarding = true
            print("✅ Onboarding completed successfully!")
            
        } catch {
            isLoading = false
            showError(message: "Failed to complete onboarding: \(error.localizedDescription)")
            print("❌ Onboarding error: \(error)")
        }
    }
    
    // MARK: - Error Handling
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Supporting Types

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case personalInfo = 1
    case categories = 2
    case accounts = 3
    case security = 4
    
    var title: String {
        switch self {
        case .welcome: return "Welcome to SpendSight"
        case .personalInfo: return "Personal Information"
        case .categories: return "Choose Categories"
        case .accounts: return "Add Your Accounts"
        case .security: return "Security Settings"
        }
    }
    
    var description: String {
        switch self {
        case .welcome:
            return "Let's get you set up to start tracking your spending"
        case .personalInfo:
            return "Tell us a bit about yourself"
        case .categories:
            return "Select the expense categories you want to track"
        case .accounts:
            return "Add your bank accounts, credit cards, and payment methods"
        case .security:
            return "Secure your financial data"
        }
    }
}

struct AccountData: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var type: String
    var institution: String?
    var last4: String?
    var initialBalance: Double = 0.0
    
    var displayName: String {
        if let institution = institution, !institution.isEmpty {
            return "\(institution) \(name)"
        }
        return name
    }
}

// MARK: - CategorySeeder Extension

extension CategorySeeder {
    static func markAsSeeded() {
        UserDefaults.standard.set(true, forKey: "hasSeededCategories")
    }
}
