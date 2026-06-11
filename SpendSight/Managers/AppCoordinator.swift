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
import Supabase

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
            // Keychain data survives app deletion on iOS. On the very first launch
            // after a fresh install, UserDefaults is empty but a stale Keychain
            // session may exist, which would bypass auth entirely. Clear it so the
            // user always sees the sign-in screen after reinstalling.
            let freshInstall = !UserDefaults.standard.bool(forKey: "appHasLaunchedBefore")
            if freshInstall {
                UserDefaults.standard.set(true, forKey: "appHasLaunchedBefore")
                try? await supabase.auth.signOut()
            }

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
        deleteAllData()

        Task {
            try? await AuthService.shared.signOut()
            appState = .unauthenticated
        }
    }

    func authDidSignIn() {
        Task {
            await resolvePostAuthState()
            await syncPlaidAfterSignIn()
            await ProfileService.shared.fetchProfile()
            await ManualSyncService.shared.restoreManualData(context: context)
        }
    }

    private func syncPlaidAfterSignIn() async {
        do {
            let transactions = try await PlaidService.shared.syncTransactions()
            guard !transactions.isEmpty else { return }
            await PlaidImporter.shared.importTransactions(transactions, into: context)
            UserDefaults.standard.set(true, forKey: "hasConnectedBank")
        } catch {
            logger.error("Post-login Plaid sync failed: \(error.localizedDescription)")
        }
    }

    // Checks both a per-user UserDefaults key and Supabase user metadata.
    // Per-user key means logout never clears it, and a different user on same device
    // gets their own flag. Remote metadata handles new-device sign-ins.
    private func resolvePostAuthState() async {
        guard let userId = AuthService.shared.currentUser?.id.uuidString else {
            appState = .unauthenticated
            return
        }

        let userKey = "hasCompletedOnboarding_\(userId)"
        let localFlag = UserDefaults.standard.bool(forKey: userKey)

        let remoteFlag: Bool = {
            guard let user = AuthService.shared.currentUser,
                  case .bool(let v) = user.userMetadata["onboarding_completed"] else {
                return false
            }
            return v
        }()

        let hasOnboarded = localFlag || remoteFlag

        if remoteFlag && !localFlag {
            UserDefaults.standard.set(true, forKey: userKey)
        }

        if hasOnboarded {
            if remoteFlag && !localFlag {
                // New device for a returning user — restore their specific category
                // selection from Supabase instead of seeding all defaults.
                seedCategoriesFromMetadata()
            } else {
                CategorySeeder.seedIfNeeded(modelContext: context)
            }
            appState = .main
        } else {
            appState = .onboarding
        }
    }

    private func seedCategoriesFromMetadata() {
        if let user = AuthService.shared.currentUser,
           case .array(let arr) = user.userMetadata["selected_categories"] {
            let names = arr.compactMap { item -> String? in
                if case .string(let s) = item { return s }
                return nil
            }
            if !names.isEmpty {
                CategorySeeder.seedSpecific(names: names, modelContext: context)
                return
            }
        }
        CategorySeeder.seedIfNeeded(modelContext: context)
    }
    
    // MARK: - Data Management
    
    private func deleteAllData() {
        // Delete user profile
        let userRequest: NSFetchRequest<NSFetchRequestResult> = UserProfile.fetchRequest()
        let deleteUsers = NSBatchDeleteRequest(fetchRequest: userRequest)

        // Delete transactions
        let transactionRequest: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let deleteTransactions = NSBatchDeleteRequest(fetchRequest: transactionRequest)

        // Delete accounts
        let accountRequest: NSFetchRequest<NSFetchRequestResult> = Account.fetchRequest()
        let deleteAccounts = NSBatchDeleteRequest(fetchRequest: accountRequest)

        // Delete income records
        let incomeRequest: NSFetchRequest<NSFetchRequestResult> = Income.fetchRequest()
        let deleteIncome = NSBatchDeleteRequest(fetchRequest: incomeRequest)

        // Delete savings plans
        let savingsRequest: NSFetchRequest<NSFetchRequestResult> = SavingsPlan.fetchRequest()
        let deleteSavings = NSBatchDeleteRequest(fetchRequest: savingsRequest)

        // Categories are intentionally kept — they are user configuration (including
        // custom categories) and are re-seeded from defaults if missing on next sign-in.

        do {
            try context.execute(deleteUsers)
            try context.execute(deleteTransactions)
            try context.execute(deleteAccounts)
            try context.execute(deleteIncome)
            try context.execute(deleteSavings)
            try context.save()
        } catch {
            logger.error("Failed to delete user data during logout: \(error.localizedDescription)")
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
