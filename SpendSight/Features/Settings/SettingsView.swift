//
//  SettingsView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Settings")
                    .font(.largeTitle)
                
                Button("Run Debug Smoke Test") {
                    runDebugSmokeTest()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
    
    private func runDebugSmokeTest() {
        let stamp = Int(Date().timeIntervalSince1970)
        
        print("\n========== DEBUG SMOKE TEST START ==========")
        
        let account = Account(
            context: context,
            name: "Debug Checking \(stamp)",
            type: "Checking",
            institution: "Debug Bank",
            last4: "1234"
        )
        
        let category = Category(
            context: context,
            name: "Debug Food \(stamp)",
            colorHex: "#4CAF50",
            icon: "fork.knife",
            monthlyBudget: 300
        )
        
        let income = Income(
            context: context,
            amount: 2500,
            source: "Debug Salary \(stamp)",
            account: account
        )
        
        let transaction = Transaction(
            context: context,
            amount: -42.50,
            title: "Debug Lunch \(stamp)",
            merchant: "Debug Cafe",
            paymentMethod: "Card",
            category: category,
            account: account
        )
        
        let savings = SavingsPlan(
            context: context,
            targetAmount: 1000,
            currentAmount: 250,
            notes: "Debug Plan \(stamp)"
        )
        
        context.saveIfNeeded()
        
        do {
            try account.validate()
            try category.validate()
            try income.validate()
            try transaction.validate()
            try savings.validate()
            print("Validation: PASS")
        } catch {
            print("Validation: FAIL -> \(error.localizedDescription)")
        }
        
        print("Category formatted budget: \(category.formattedBudget)")
        print("Account display name: \(account.displayName)")
        print("Income formatted amount: \(income.formattedAmount)")
        print("Transaction formatted amount: \(transaction.formattedAmount)")
        print("Savings progress: \(savings.progressPercentage)")
        
        do {
            let accounts = try context.fetch(Account.fetchByName(account.name ?? ""))
            let categories = try context.fetch(Category.fetchByName(category.name ?? ""))
            let incomes = try context.fetch(Income.fetchBySource(income.source ?? ""))
            let transactions = try context.fetch(Transaction.fetchRequest(account: account))
            let activeSavings = try context.fetch(SavingsPlan.fetchActivePlans())
            
            print("Fetch Account by name: \(accounts.isEmpty ? "FAIL" : "PASS")")
            print("Fetch Category by name: \(categories.isEmpty ? "FAIL" : "PASS")")
            print("Fetch Income by source: \(incomes.isEmpty ? "FAIL" : "PASS")")
            print("Fetch Transaction by account: \(transactions.isEmpty ? "FAIL" : "PASS")")
            print("Fetch Active Savings: \(activeSavings.isEmpty ? "FAIL" : "PASS")")
        } catch {
            print("Fetch: FAIL -> \(error.localizedDescription)")
        }
        
        print("========== DEBUG SMOKE TEST END ==========\n")
    }
}

#Preview {
    SettingsView()
}
