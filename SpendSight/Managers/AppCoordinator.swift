//
//  AppCoordinator.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/18/26.
//

import SwiftUI
import CoreData
import Combine

@MainActor
class AppCoordinator: ObservableObject {
    
    @Published var appState: AppState = .loading
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - App State Management
    
    func checkAppState() {
        // Check if onboarding is complete
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if !hasCompletedOnboarding {
            appState = .onboarding
            return
        }
        
        appState = .main
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
        
        do {
            try context.execute(deleteUsers)
            try context.execute(deleteTransactions)
            try context.execute(deleteCategories)
            try context.execute(deleteAccounts)
            try context.save()
            
            print("✅ All user data deleted")
        } catch {
            print("❌ Error deleting data: \(error)")
        }
    }
}

// MARK: - App State

enum AppState {
    case loading
    case onboarding
    case main
}
