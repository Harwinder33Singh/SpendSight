//
//  OnboardingViewModel.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/18/26.
//

import SwiftUI
import CoreData
import Combine
internal import Auth
import Supabase

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
    let defaultCategories: [(name: String, color: String, icon: String, budget: Double?, type: Category.CategoryType)] = [
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
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.selectedCategories = Set(defaultCategories.map { $0.name })

        // Pre-fill from Supabase auth — no need to ask again
        if let user = AuthService.shared.currentUser {
            if case .string(let name) = user.userMetadata["full_name"] {
                self.fullName = name
            }
            self.email = user.email ?? ""
        }
    }
    
    // MARK: - Navigation
    
    func nextStep() {
        switch currentStep {
        case .welcome:
            currentStep = .categories
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
        case .categories:
            currentStep = .welcome
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

        // Sync data with Account Info settings (AppStorage)
        syncWithAccountInfo()

        // Create user profile in Core Data (for potential future features)
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
                _ = Category(
                    context: context,
                    name: categoryData.name,
                    colorHex: categoryData.color,
                    icon: categoryData.icon,
                    monthlyBudget: categoryData.budget,
                    categoryType: categoryData.type
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

            // Add initial balance as income if provided
            if accountData.initialBalance > 0 {
                let _ = Income(
                    context: context,
                    amount: accountData.initialBalance,
                    source: "Initial Balance",
                    date: Date(),
                    account: account
                )
            }
        }

        // Mark onboarding as complete
        userProfile.completeOnboarding()

        // Mark categories as seeded
        CategorySeeder.markAsSeeded()

        // Save everything
        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

            // Persist onboarding flag to Supabase so returning users on new devices skip it
            Task {
                try? await supabase.auth.update(
                    user: UserAttributes(data: ["onboarding_completed": AnyJSON.bool(true)])
                )
            }

            isLoading = false
            didCompleteOnboarding = true

        } catch {
            isLoading = false
            showError(message: "Failed to complete onboarding: \(error.localizedDescription)")
        }
    }

    // MARK: - Account Info Sync

    private func syncWithAccountInfo() {
        // Sync personal information with Account Info settings
        UserDefaults.standard.set(fullName, forKey: "userName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(phone, forKey: "userPhone")
        UserDefaults.standard.set(selectedCurrency, forKey: "defaultCurrency")

        // Set default preferences
        UserDefaults.standard.set(true, forKey: "enableNotifications")
        UserDefaults.standard.set(false, forKey: "enableBiometric")
        UserDefaults.standard.set("", forKey: "monthlyBudgetGoal")

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
    case categories = 1
    case accounts = 2
    case security = 3

    var title: String {
        switch self {
        case .welcome:    return "Welcome to SpendSight"
        case .categories: return "Choose Categories"
        case .accounts:   return "Add Your Accounts"
        case .security:   return "Security Settings"
        }
    }

    var description: String {
        switch self {
        case .welcome:    return "Let's get you set up to start tracking your spending"
        case .categories: return "Select the expense categories you want to track"
        case .accounts:   return "Add your bank accounts, credit cards, and payment methods"
        case .security:   return "Secure your financial data"
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
