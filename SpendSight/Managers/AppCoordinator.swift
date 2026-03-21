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

        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        appState = hasCompletedOnboarding ? .main : .onboarding
    }
    
    // MARK: - Onboarding
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        appState = .main
    }
    
    // MARK: - Logout
    
    func logout() {
        // Clear onboarding flag
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        // Clear category seeding flag
        UserDefaults.standard.set(false, forKey: "hasSeededCategories")
        
        // Delete all user data
        deleteAllData()
        
        // Reset app state
        appState = .onboarding
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

// MARK: - App State

enum AppState {
    case loading
    case onboarding
    case main
    case failed(String)
}
