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
    @AppStorage("userName") private var userName: String = ""
    @State private var showDeleteConfirmation = false
    @State private var showMailComposer = false
    @State private var showAccountInfo = false
    @State private var showNotifications = false
    @State private var showCategoryManagement = false
    @State private var showAccountManagement = false
    @State private var showBackupSettings = false
    @State private var showHelpCenter = false
    @State private var showPrivacyPolicy = false
    @State private var showDatabaseInfo = false
    @State private var showConnectedAccounts = false

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
            .sheet(isPresented: $showCategoryManagement) {
                CategoryManagementView()
                    .environment(\.managedObjectContext, context)
            }
            .sheet(isPresented: $showAccountManagement) {
                AccountManagementView()
                    .environment(\.managedObjectContext, context)
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
            .sheet(isPresented: $showConnectedAccounts) {
                ConnectedAccountsView()
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
                    subtitle: userName.isEmpty ? "Set up your profile" : userName,
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
                    icon: "tag.fill",
                    title: "Manage Categories",
                    subtitle: "Add, edit, and organize categories",
                    iconColor: .blue
                ) {
                    showCategoryManagement = true
                }

                Divider()
                    .padding(.leading, 44)

                SettingsRow(
                    icon: "building.columns.fill",
                    title: "Manage Accounts",
                    subtitle: "Add, edit, and remove bank accounts",
                    iconColor: .green
                ) {
                    showAccountManagement = true
                }
                
                Divider()
                    .padding(.leading, 44)

                SettingsRow(
                    icon: "link.circle.fill",
                    title: "Connected Banks",
                    subtitle: "Link bank accounts via Plaid",
                    iconColor: .indigo
                ) {
                    showConnectedAccounts = true
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
        ExportService.shared.exportTransactionsToCSV(context: context) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    // Present share sheet
                    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.present(activityViewController, animated: true)
                    }
                case .failure(let error):
                    // Could show an alert here, but keeping it simple for now
                    print("Export failed: \(error.localizedDescription)")
                }
            }
        }
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

        // Validate entities
        do {
            try account.validate()
            try category.validate()
            try income.validate()
            try transaction.validate()
            try savings.validate()
        } catch {
            // Handle validation errors silently
        }

        // Test fetch operations
        do {
            let _ = try context.fetch(Account.fetchByName(account.name ?? ""))
            let _ = try context.fetch(Category.fetchByName(category.name ?? ""))
            let _ = try context.fetch(Income.fetchBySource(income.source ?? ""))
            let _ = try context.fetch(Transaction.fetchRequest(account: account))
            let _ = try context.fetch(SavingsPlan.fetchActivePlans())
        } catch {
            // Handle fetch errors silently
        }
    }
}

// MARK: - Placeholder Views

struct AccountInfoView: View {
    @Environment(\.managedObjectContext) private var context
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("userEmail") private var userEmail: String = ""
    @AppStorage("userPhone") private var userPhone: String = ""
    @AppStorage("defaultCurrency") private var defaultCurrency: String = "USD"
    @AppStorage("enableNotifications") private var enableNotifications: Bool = true
    @AppStorage("enableBiometric") private var enableBiometric: Bool = false
    @AppStorage("monthlyBudgetGoal") private var monthlyBudgetGoalString: String = ""

    @State private var isEditing: Bool = false
    @State private var showingImagePicker: Bool = false
    @State private var profileImage: UIImage?

    private let currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY", "INR", "CNY"]

    var monthlyBudgetGoal: Double {
        get { Double(monthlyBudgetGoalString) ?? 0.0 }
        set { monthlyBudgetGoalString = String(newValue) }
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Button {
                            showingImagePicker = true
                        } label: {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(.gray)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())

                        VStack(alignment: .leading, spacing: 4) {
                            if isEditing {
                                TextField("Your Name", text: $userName)
                                    .textFieldStyle(.roundedBorder)
                                    .textInputAutocapitalization(.words)
                            } else {
                                Text(userName.isEmpty ? "Tap to add name" : userName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(userName.isEmpty ? .secondary : .primary)
                            }

                            Text("SpendSight User")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Profile")
                }

                Section {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundStyle(.blue)
                            .frame(width: 24)

                        if isEditing {
                            TextField("Email Address", text: $userEmail)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                        } else {
                            VStack(alignment: .leading) {
                                Text("Email")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(userEmail.isEmpty ? "Not set" : userEmail)
                                    .foregroundStyle(userEmail.isEmpty ? .secondary : .primary)
                            }
                        }
                    }

                    HStack {
                        Image(systemName: "phone")
                            .foregroundStyle(.green)
                            .frame(width: 24)

                        if isEditing {
                            TextField("Phone Number", text: $userPhone)
                                .keyboardType(.phonePad)
                        } else {
                            VStack(alignment: .leading) {
                                Text("Phone")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(userPhone.isEmpty ? "Not set" : userPhone)
                                    .foregroundStyle(userPhone.isEmpty ? .secondary : .primary)
                            }
                        }
                    }
                } header: {
                    Text("Contact Information")
                }

                Section {
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundStyle(.orange)
                            .frame(width: 24)

                        Text("Default Currency")

                        Spacer()

                        if isEditing {
                            Picker("Currency", selection: $defaultCurrency) {
                                ForEach(currencies, id: \.self) { currency in
                                    Text(currency).tag(currency)
                                }
                            }
                            .pickerStyle(.menu)
                        } else {
                            Text(defaultCurrency)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        Image(systemName: "target")
                            .foregroundStyle(.purple)
                            .frame(width: 24)

                        if isEditing {
                            VStack(alignment: .leading) {
                                Text("Monthly Budget Goal")
                                TextField("0", text: $monthlyBudgetGoalString)
                                    .keyboardType(.decimalPad)
                            }
                        } else {
                            VStack(alignment: .leading) {
                                Text("Monthly Budget Goal")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(monthlyBudgetGoal > 0 ? formatCurrency(monthlyBudgetGoal) : "Not set")
                                    .foregroundStyle(monthlyBudgetGoal > 0 ? .primary : .secondary)
                            }
                        }

                        Spacer()
                    }
                } header: {
                    Text("Preferences")
                }

                Section {
                    Toggle(isOn: $enableNotifications) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundStyle(.red)
                                .frame(width: 24)
                            Text("Push Notifications")
                        }
                    }

                    Toggle(isOn: $enableBiometric) {
                        HStack {
                            Image(systemName: "faceid")
                                .foregroundStyle(.blue)
                                .frame(width: 24)
                            Text("Biometric Authentication")
                        }
                    }
                } header: {
                    Text("Security & Privacy")
                } footer: {
                    Text("Enable biometric authentication for secure app access")
                }

                Section {
                    Button {
                        exportUserData()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.blue)
                                .frame(width: 24)
                            Text("Export Account Data")
                            Spacer()
                        }
                    }

                    Button(role: .destructive) {
                        // Account deletion functionality - to be implemented
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .frame(width: 24)
                            Text("Delete Account")
                            Spacer()
                        }
                    }
                } header: {
                    Text("Data Management")
                } footer: {
                    Text("Export your data or permanently delete your account")
                }
            }
            .navigationTitle("Account Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation {
                            if isEditing {
                                // Save changes when exiting edit mode
                                syncWithUserProfile()
                            }
                            isEditing.toggle()
                        }
                    }
                }
            }
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        return CurrencyService.shared.formatAmountWithoutDecimals(amount)
    }

    private func syncWithUserProfile() {
        // Update UserProfile in Core Data when Account Info changes
        let request = UserProfile.fetchCurrentUser()

        do {
            let profiles = try context.fetch(request)
            let userProfile = profiles.first ?? UserProfile(
                context: context,
                fullName: userName,
                email: userEmail.isEmpty ? nil : userEmail,
                phone: userPhone.isEmpty ? nil : userPhone,
                currency: defaultCurrency
            )

            userProfile.updateProfile(
                fullName: userName,
                email: userEmail.isEmpty ? nil : userEmail,
                phone: userPhone.isEmpty ? nil : userPhone,
                currency: defaultCurrency
            )

            try context.save()

            // Update the currency service
            CurrencyService.shared.updateCurrency(defaultCurrency)
        } catch {
            // Handle sync errors silently
        }
    }

    private func exportUserData() {
        ExportService.shared.exportDataToJSON(context: context) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    // Present share sheet
                    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.present(activityViewController, animated: true)
                    }
                case .failure(let error):
                    print("Export failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct NotificationSettingsView: View {
    @StateObject private var notificationService = NotificationService.shared
    @AppStorage("enableBudgetNotifications") private var enableBudgetNotifications = true
    @AppStorage("enableDailyReminders") private var enableDailyReminders = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    if !notificationService.isAuthorized {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notifications Disabled")
                                .font(.headline)
                                .foregroundStyle(.red)

                            Text("To receive budget alerts and reminders, please allow notifications in your device settings.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Button("Open Settings") {
                                openAppSettings()
                            }
                            .foregroundStyle(.blue)
                        }
                        .padding(.vertical, 4)
                    } else {
                        Label("Notifications Enabled", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                } header: {
                    Text("Permission Status")
                }

                Section {
                    Toggle(isOn: $enableBudgetNotifications) {
                        VStack(alignment: .leading) {
                            Text("Budget Alerts")
                            Text("Get notified when you reach 80% and 100% of your budget")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(!notificationService.isAuthorized)

                    Toggle(isOn: $enableDailyReminders) {
                        VStack(alignment: .leading) {
                            Text("Daily Reminders")
                            Text("Daily reminder at 7 PM to log your expenses")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(!notificationService.isAuthorized)
                    .onChange(of: enableDailyReminders) { oldValue, newValue in
                        if newValue {
                            notificationService.scheduleRecurringReminder()
                        } else {
                            // Remove daily reminders
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
                        }
                    }
                } header: {
                    Text("Notification Types")
                } footer: {
                    Text("Budget notifications will be sent when you exceed spending thresholds for categories with budgets set.")
                }

                Section {
                    Button("Test Budget Notification") {
                        testBudgetNotification()
                    }
                    .disabled(!notificationService.isAuthorized)

                    Button("Clear All Notifications") {
                        notificationService.cancelAllNotifications()
                    }
                    .foregroundStyle(.red)
                } header: {
                    Text("Testing & Management")
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !notificationService.isAuthorized {
                    notificationService.requestPermission()
                }
            }
        }
    }

    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    private func testBudgetNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Budget Alert"
        content.body = "This is a test notification to verify budget alerts are working."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}



struct BackupSettingsView: View {
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button {
                        exportData()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.blue)
                                .frame(width: 24)
                            Text("Export All Data (JSON)")
                            Spacer()
                        }
                    }

                    Button {
                        exportTransactions()
                    } label: {
                        HStack {
                            Image(systemName: "tablecells")
                                .foregroundStyle(.green)
                                .frame(width: 24)
                            Text("Export Transactions (CSV)")
                            Spacer()
                        }
                    }
                } header: {
                    Text("Export Options")
                } footer: {
                    Text("Export your data for backup or use in other applications")
                }

                Section {
                    Text("iCloud synchronization will be available in a future update")
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Cloud Sync")
                }
            }
            .navigationTitle("Backup & Sync")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func exportData() {
        ExportService.shared.exportDataToJSON(context: context) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    presentShareSheet(with: url)
                case .failure(let error):
                    print("Export failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func exportTransactions() {
        ExportService.shared.exportTransactionsToCSV(context: context) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    presentShareSheet(with: url)
                case .failure(let error):
                    print("Export failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func presentShareSheet(with url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
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
