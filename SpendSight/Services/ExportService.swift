//
//  ExportService.swift
//  SpendSight
//
//  Created by Harwinder Singh on 3/20/26.
//

import Foundation
import CoreData

class ExportService {
    static let shared = ExportService()

    private init() {}

    // MARK: - CSV Export

    func exportTransactionsToCSV(context: NSManagedObjectContext, completion: @escaping (Result<URL, Error>) -> Void) {
        context.perform {
            do {
                let transactions = try context.fetch(Transaction.fetchAll())
                let csvContent = self.generateCSVContent(transactions: transactions)
                let fileURL = try self.saveCSVFile(content: csvContent, filename: "SpendSight_Transactions_\(Date().timeIntervalSince1970)")

                DispatchQueue.main.async {
                    completion(.success(fileURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    private func generateCSVContent(transactions: [Transaction]) -> String {
        var csvContent = "Date,Title,Merchant,Amount,Currency,Category,Account,Payment Method,Notes\n"

        for transaction in transactions {
            let date = DateFormatter.csvFormatter.string(from: transaction.date ?? Date())
            let title = escapeCSVField(transaction.title ?? "")
            let merchant = escapeCSVField(transaction.merchant ?? "")
            let amount = String(transaction.amount)
            let currency = CurrencyService.shared.currentCurrency
            let category = escapeCSVField(transaction.categoryName)
            let account = escapeCSVField(transaction.accountName)
            let paymentMethod = escapeCSVField(transaction.paymentMethod ?? "")
            let notes = escapeCSVField(transaction.notes ?? "")

            csvContent += "\(date),\(title),\(merchant),\(amount),\(currency),\(category),\(account),\(paymentMethod),\(notes)\n"
        }

        return csvContent
    }

    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }

    private func saveCSVFile(content: String, filename: String) throws -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("\(filename).csv")

        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    // MARK: - JSON Backup

    func exportDataToJSON(context: NSManagedObjectContext, completion: @escaping (Result<URL, Error>) -> Void) {
        context.perform {
            do {
                let backupData = try self.generateBackupData(context: context)
                let jsonData = try JSONEncoder().encode(backupData)
                let fileURL = try self.saveJSONFile(data: jsonData, filename: "SpendSight_Backup_\(Date().timeIntervalSince1970)")

                DispatchQueue.main.async {
                    completion(.success(fileURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    private func generateBackupData(context: NSManagedObjectContext) throws -> BackupData {
        let transactions = try context.fetch(Transaction.fetchAll())
        let accounts = try context.fetch(Account.fetchRequest())
        let categories = try context.fetch(Category.fetchRequest())
        let income = try context.fetch(Income.fetchRequest())
        let savingsPlans = try context.fetch(SavingsPlan.fetchRequest())
        let userProfiles = try context.fetch(UserProfile.fetchRequest())

        return BackupData(
            transactions: transactions.map(TransactionBackup.init),
            accounts: accounts.map(AccountBackup.init),
            categories: categories.map(CategoryBackup.init),
            income: income.map(IncomeBackup.init),
            savingsPlans: savingsPlans.map(SavingsPlanBackup.init),
            userProfile: userProfiles.first.map(UserProfileBackup.init),
            exportDate: Date(),
            appVersion: "1.0.0"
        )
    }

    private func saveJSONFile(data: Data, filename: String) throws -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("\(filename).json")

        try data.write(to: fileURL)
        return fileURL
    }
}

// MARK: - Date Formatter Extension

extension DateFormatter {
    static let csvFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}

// MARK: - Backup Data Models

struct BackupData: Codable {
    let transactions: [TransactionBackup]
    let accounts: [AccountBackup]
    let categories: [CategoryBackup]
    let income: [IncomeBackup]
    let savingsPlans: [SavingsPlanBackup]
    let userProfile: UserProfileBackup?
    let exportDate: Date
    let appVersion: String
}

struct TransactionBackup: Codable {
    let id: UUID
    let amount: Double
    let title: String?
    let merchant: String?
    let date: Date?
    let notes: String?
    let paymentMethod: String?
    let isRecurring: Bool
    let categoryName: String?
    let accountName: String?
    let createdAt: Date?
    let updatedAt: Date?

    init(from transaction: Transaction) {
        self.id = transaction.id ?? UUID()
        self.amount = transaction.amount
        self.title = transaction.title
        self.merchant = transaction.merchant
        self.date = transaction.date
        self.notes = transaction.notes
        self.paymentMethod = transaction.paymentMethod
        self.isRecurring = transaction.isRecurring
        self.categoryName = transaction.category?.name
        self.accountName = transaction.account?.name
        self.createdAt = transaction.createdAt
        self.updatedAt = transaction.updatedAt
    }
}

struct AccountBackup: Codable {
    let id: UUID
    let name: String?
    let type: String?
    let institution: String?
    let last4: String?

    init(from account: Account) {
        self.id = account.id ?? UUID()
        self.name = account.name
        self.type = account.type
        self.institution = account.institution
        self.last4 = account.last4
    }
}

struct CategoryBackup: Codable {
    let id: UUID
    let name: String?
    let colorHex: String?
    let icon: String?
    let monthlyBudget: Double?

    init(from category: Category) {
        self.id = category.id ?? UUID()
        self.name = category.name
        self.colorHex = category.colorHex
        self.icon = category.icon
        self.monthlyBudget = category.monthlyBudget
    }
}

struct IncomeBackup: Codable {
    let id: UUID
    let amount: Double
    let source: String?
    let date: Date?
    let notes: String?
    let accountName: String?

    init(from income: Income) {
        self.id = income.id ?? UUID()
        self.amount = income.amount
        self.source = income.source
        self.date = income.date
        self.notes = income.notes
        self.accountName = income.account?.name
    }
}

struct SavingsPlanBackup: Codable {
    let id: UUID
    let targetAmount: Double
    let currentAmount: Double
    let month: Date?
    let notes: String?

    init(from savingsPlan: SavingsPlan) {
        self.id = savingsPlan.id ?? UUID()
        self.targetAmount = savingsPlan.targetAmount
        self.currentAmount = savingsPlan.currentAmount
        self.month = savingsPlan.month
        self.notes = savingsPlan.notes
    }
}

struct UserProfileBackup: Codable {
    let id: UUID
    let fullName: String?
    let email: String?
    let phone: String?
    let currency: String?
    let hasCompletedOnboarding: Bool
    let createdAt: Date?
    let updatedAt: Date?

    init(from userProfile: UserProfile) {
        self.id = userProfile.id ?? UUID()
        self.fullName = userProfile.fullName
        self.email = userProfile.email
        self.phone = userProfile.phone
        self.currency = userProfile.currency
        self.hasCompletedOnboarding = userProfile.hasCompletedOnboarding
        self.createdAt = userProfile.createdAt
        self.updatedAt = userProfile.updatedAt
    }
}
