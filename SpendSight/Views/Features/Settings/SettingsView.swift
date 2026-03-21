//
//  SettingsView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI
import CoreData
import MessageUI
import StoreKit

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.requestReview) private var requestReview
    @State private var showDeleteConfirmation = false
    @State private var showMailComposer = false
    @State private var showAccountInfo = false
    @State private var showNotifications = false
    @State private var showAppearance = false
    @State private var showCurrency = false
    @State private var showBudgetSettings = false
    @State private var showBackupSettings = false
    @State private var showHelpCenter = false
    @State private var showPrivacyPolicy = false
    @State private var showDatabaseInfo = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Section
                    profileSection

                    // App Settings Section
                    appSettingsSection

                    // Data Management Section
                    dataManagementSection

                    // Support Section
                    supportSection

                    // Debug Section (Development)
                    #if DEBUG
                    debugSection
                    #endif

                    // App Info Section
                    appInfoSection
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAccountInfo) {
                AccountInfoView()
            }
            .sheet(isPresented: $showNotifications) {
                NotificationSettingsView()
            }
            .sheet(isPresented: $showAppearance) {
                AppearanceSettingsView()
            }
            .sheet(isPresented: $showCurrency) {
                CurrencySettingsView()
            }
            .sheet(isPresented: $showBudgetSettings) {
                BudgetSettingsView()
            }
            .sheet(isPresented: $showBackupSettings) {
                BackupSettingsView()
            }
            .sheet(isPresented: $showHelpCenter) {
                HelpCenterView()
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showDatabaseInfo) {
                DatabaseInfoView()
                    .environment(\.managedObjectContext, context)
            }
            .alert("Delete All Data", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete All", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This action will permanently delete all your transactions, accounts, categories, and budgets. This cannot be undone.")
            }
        }
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile")
                .font(.title2)
                .fontWeight(.bold)

            VStack(spacing: 0) {
                SettingsRow(
                    icon: "person.circle",
                    title: "Account Info",
                    subtitle: "Manage your profile",
                    iconColor: .blue
                ) {
                    showAccountInfo = true
                }

                Divider()
                    .padding(.leading, 44)

                SettingsRow(
                    icon: "bell",
                    title: "Notifications",
                    subtitle: "Manage alerts and reminders",
                    iconColor: .orange
                ) {
                    showNotifications = true
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
    }

    // MARK: - App Settings Section

    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("App Settings")
                .font(.title2)
                .fontWeight(.bold)

            VStack(spacing: 0) {
                SettingsRow(
                    icon: "paintbrush",
                    title: "Appearance",
                    subtitle: "Theme and display options",
                    iconColor: .purple
                ) {
                    showAppearance = true
                }

                Divider()
                    .padding(.leading, 44)

                SettingsRow(
                    icon: "dollarsign.circle",
                    title: "Currency",
                    subtitle: "USD - United States Dollar",
                    iconColor: .green
                ) {
                    showCurrency = true
                }

                Divider()
                    .padding(.leading, 44)

                SettingsRow(
                    icon: "chart.bar",
                    title: "Budget Settings",
                    subtitle: "Default budgets and limits",
                    iconColor: .indigo
                ) {
                    showBudgetSettings = true
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
    }

    // MARK: - Data Management Section

    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Management")
                .font(.title2)
                .fontWeight(.bold)

            VStack(spacing: 0) {
                SettingsRow(
                    icon: "square.and.arrow.up",
                    title: "Export Data",
                    subtitle: "Export transactions to CSV",
                    iconColor: .teal
                ) {
                    exportData()
                }

                Divider()
                    .padding(.leading, 44)

                SettingsRow(
                    icon: "icloud",
                    title: "Backup & Sync",
                    subtitle: "iCloud synchronization",
                    iconColor: .cyan
                ) {
                    showBackupSettings = true
                }

                Divider()
                    .padding(.leading, 44)

                SettingsRow(
                    icon: "trash",
                    title: "Delete All Data",
                    subtitle: "Permanently remove all data",
                    iconColor: .red,
                    isDestructive: true
                ) {
                    showDeleteConfirmation = true
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Support")
                .font(.title2)
                .fontWeight(.bold)

            VStack(spacing: 0) {
                SettingsRow(
                    icon: "questionmark.circle",
                    title: "Help Center",
                    subtitle: "Get help and tutorials",
                    iconColor: .mint
                ) {
                    showHelpCenter = true
                }

                Divider()
                    .padding(.leading, 44)

                SettingsRow(
                    icon: "envelope",
                    title: "Contact Support",
                    subtitle: "Send feedback or report issues",
                    iconColor: .pink
                ) {
                    openContactSupport()
                }

                Divider()
                    .padding(.leading, 44)

                SettingsRow(
                    icon: "star",
                    title: "Rate SpendSight",
                    subtitle: "Leave a review on the App Store",
                    iconColor: .yellow
                ) {
                    requestReview()
                }

                Divider()
                    .padding(.leading, 44)

                SettingsRow(
                    icon: "doc.text",
                    title: "Privacy Policy",
                    subtitle: "How we protect your data",
                    iconColor: .secondary
                ) {
                    showPrivacyPolicy = true
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
    }

    // MARK: - Debug Section (Development Only)

    #if DEBUG
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Debug")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {

                SettingsRow(
                    icon: "externaldrive",
                    title: "Database Info",
                    subtitle: "View Core Data statistics",
                    iconColor: .purple
                ) {
                    showDatabaseInfo = true
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
    }
    #endif

    // MARK: - App Info Section

    private var appInfoSection: some View {
        VStack(spacing: 12) {
            Text("SpendSight")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Built with ❤️ for better financial health")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Helper Functions

    private func exportData() {
        // TODO: Implement CSV export functionality
        let transactions = try? context.fetch(Transaction.fetchRequest())
        print("Exporting \(transactions?.count ?? 0) transactions to CSV")
    }

    private func openContactSupport() {
        if let url = URL(string: "mailto:support@spendsight.app?subject=SpendSight Support") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

    private func deleteAllData() {
        // Delete all transactions
        let transactionRequest = Transaction.fetchRequest()
        if let transactions = try? context.fetch(transactionRequest) {
            transactions.forEach { context.delete($0) }
        }

        // Delete all accounts
        let accountRequest = Account.fetchRequest()
        if let accounts = try? context.fetch(accountRequest) {
            accounts.forEach { context.delete($0) }
        }

        // Delete all categories (keep defaults)
        let categoryRequest = Category.fetchRequest()
        if let categories = try? context.fetch(categoryRequest) {
            categories.forEach { context.delete($0) }
        }

        // Delete all income records
        let incomeRequest = Income.fetchRequest()
        if let incomes = try? context.fetch(incomeRequest) {
            incomes.forEach { context.delete($0) }
        }

        // Delete all savings plans
        let savingsRequest = SavingsPlan.fetchRequest()
        if let savings = try? context.fetch(savingsRequest) {
            savings.forEach { context.delete($0) }
        }

        // Save changes
        context.saveIfNeeded()
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

// MARK: - Placeholder Views

struct AccountInfoView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Account Information")
                    .font(.title)
                Text("Profile management coming soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Account Info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NotificationSettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Notification Settings")
                    .font(.title)
                Text("Notification preferences coming soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AppearanceSettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Appearance Settings")
                    .font(.title)
                Text("Theme options coming soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CurrencySettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Currency Settings")
                    .font(.title)
                Text("Currency selection coming soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Currency")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BudgetSettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Budget Settings")
                    .font(.title)
                Text("Budget configuration coming soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Budget Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BackupSettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Backup & Sync")
                    .font(.title)
                Text("iCloud sync coming soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Backup & Sync")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HelpCenterView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Help Center")
                    .font(.title)
                Text("Help documentation coming soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Help Center")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("SpendSight Privacy Policy")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Your privacy is important to us. SpendSight is designed to keep your financial data secure and private.")

                    Text("Data Collection")
                        .font(.headline)

                    Text("• All financial data is stored locally on your device")
                    Text("• No personal financial information is transmitted to external servers")
                    Text("• Optional analytics data may be collected to improve the app experience")

                    Text("Data Security")
                        .font(.headline)

                    Text("• All data is encrypted and secured using industry-standard practices")
                    Text("• Your financial data never leaves your device unless you explicitly choose to export it")

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DatabaseInfoView: View {
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        NavigationView {
            List {
                Section("Database Statistics") {
                    DatabaseStatRow(title: "Transactions", count: getCount(for: Transaction.fetchRequest()))
                    DatabaseStatRow(title: "Accounts", count: getCount(for: Account.fetchRequest()))
                    DatabaseStatRow(title: "Categories", count: getCount(for: Category.fetchRequest()))
                    DatabaseStatRow(title: "Income Records", count: getCount(for: Income.fetchRequest()))
                    DatabaseStatRow(title: "Savings Plans", count: getCount(for: SavingsPlan.fetchRequest()))
                }
            }
            .navigationTitle("Database Info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func getCount<T: NSFetchRequestResult>(for request: NSFetchRequest<T>) -> Int {
        do {
            return try context.count(for: request)
        } catch {
            return 0
        }
    }
}

struct DatabaseStatRow: View {
    let title: String
    let count: Int

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(count)")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - SettingsRow Component

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isDestructive ? .red : iconColor)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(isDestructive ? .red : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
