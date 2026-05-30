//
//  AppCoordinator.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/18/26.
//

import SwiftUI
import CoreData
import Combine
import OSLog
internal import Auth

private let logger = Logger(subsystem: "com.harwinder.SpendSight", category: "AppCoordinator")

@MainActor
class AppCoordinator: ObservableObject {
    
    @Published var appState: AppState = .loading
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - App State Management

    func checkAppState(coreDataError: Error? = nil) {
        if let error = coreDataError {
            logger.critical("Core Data failed to load: \(error.localizedDescription)")
            appState = .failed(error.localizedDescription)
            return
        }

        _ = CurrencyService.shared
        _ = BudgetMonitorService.shared
        CategorySeeder.fixIncomeTypeMigration(modelContext: context)

        Task {
            await AuthService.shared.initialize()

            if !AuthService.shared.isAuthenticated {
                appState = .unauthenticated
            } else {
                await resolvePostAuthState()
            }

            // React to future auth changes (sign in / sign out)
            for await _ in NotificationCenter.default.notifications(named: .authStateDidChange) {
                if !AuthService.shared.isAuthenticated {
                    appState = .unauthenticated
                }
            }
        }
    }
    
    // MARK: - Onboarding
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        appState = .main
    }
    
    // MARK: - Logout
    
    func logout() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(false, forKey: "hasSeededCategories")
        deleteAllData()

        Task {
            try? await AuthService.shared.signOut()
            appState = .unauthenticated
        }
    }

    func authDidSignIn() {
        Task { await resolvePostAuthState() }
    }

    // Checks Supabase user metadata first, then falls back to UserDefaults.
    // This means a returning user on a new device goes straight to main.
    private func resolvePostAuthState() async {
        let localFlag = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        // Check the flag stored in Supabase user metadata
        let remoteFlag: Bool = {
            guard let user = AuthService.shared.currentUser,
                  case .bool(let v) = user.userMetadata["onboarding_completed"] else {
                return false
            }
            return v
        }()

        let hasOnboarded = localFlag || remoteFlag

        // Sync back to UserDefaults so future launches are instant
        if remoteFlag && !localFlag {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }

        appState = hasOnboarded ? .main : .onboarding
    }
    
    // MARK: - Data Management
    
    private func deleteAllData() {
        // Delete user profile
        let userRequest: NSFetchRequest<NSFetchRequestResult> = UserProfile.fetchRequest()
        let deleteUsers = NSBatchDeleteRequest(fetchRequest: userRequest)

        // Delete transactions
        let transactionRequest: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let deleteTransactions = NSBatchDeleteRequest(fetchRequest: transactionRequest)

        // Delete categories
        let categoryRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let deleteCategories = NSBatchDeleteRequest(fetchRequest: categoryRequest)

        // Delete accounts
        let accountRequest: NSFetchRequest<NSFetchRequestResult> = Account.fetchRequest()
        let deleteAccounts = NSBatchDeleteRequest(fetchRequest: accountRequest)

        // Delete income records
        let incomeRequest: NSFetchRequest<NSFetchRequestResult> = Income.fetchRequest()
        let deleteIncome = NSBatchDeleteRequest(fetchRequest: incomeRequest)

        // Delete savings plans
        let savingsRequest: NSFetchRequest<NSFetchRequestResult> = SavingsPlan.fetchRequest()
        let deleteSavings = NSBatchDeleteRequest(fetchRequest: savingsRequest)

        do {
            try context.execute(deleteUsers)
            try context.execute(deleteTransactions)
            try context.execute(deleteCategories)
            try context.execute(deleteAccounts)
            try context.execute(deleteIncome)
            try context.execute(deleteSavings)
            try context.save()
        } catch {
            logger.error("Failed to delete all user data during logout: \(error.localizedDescription)")
        }
    }
}

// MARK: - Notification

extension Notification.Name {
    static let authStateDidChange = Notification.Name("authStateDidChange")
}

// MARK: - App State

enum AppState {
    case loading
    case unauthenticated
    case onboarding
    case main
    case failed(String)
}
