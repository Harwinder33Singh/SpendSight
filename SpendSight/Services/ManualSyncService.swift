import Foundation
import CoreData
import OSLog
internal import Auth

private let logger = Logger(subsystem: "com.harwinder.SpendSight", category: "ManualSyncService")

/// Syncs manually-entered accounts, transactions, and income to Supabase so data
/// survives app deletion and can be restored on any device the user signs in to.
@MainActor
class ManualSyncService {
    static let shared = ManualSyncService()

    private let supabaseURL = "https://awynihhwctqxvxhsbfxw.supabase.co"
    private let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3eW5paGh3Y3RxeHZ4aHNiZnh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxMTEyODYsImV4cCI6MjA5NTY4NzI4Nn0.8-x11Ptc8IVFl3vSHFl4K1nUiu5sD-v9DItZwb93nxs"
    private let iso = ISO8601DateFormatter()

    private init() {}

    // MARK: - Upload (fire-and-forget)

    func syncAccount(_ account: Account) {
        guard account.plaidItemId == nil,
              let id = account.id?.uuidString.lowercased(),
              let userId = AuthService.shared.currentUser?.id.uuidString.lowercased(),
              let token = AuthService.shared.accessToken else { return }

        var body: [String: Any] = [
            "id": id,
            "user_id": userId,
            "name": account.name ?? "",
            "type": account.type ?? ""
        ]
        if let v = account.institution { body["institution"] = v }
        if let v = account.last4       { body["last4"] = v }

        Task { await upsert(table: "manual_accounts", body: body, token: token) }
    }

    func syncTransaction(_ transaction: Transaction) {
        if transaction.plaidTransactionId != nil {
            logger.debug("syncTransaction skipped — plaid transaction, not manual")
            return
        }
        guard let id = transaction.id?.uuidString.lowercased() else {
            logger.error("syncTransaction failed — transaction has no id")
            return
        }
        guard let userId = AuthService.shared.currentUser?.id.uuidString.lowercased() else {
            logger.error("syncTransaction failed — no current user")
            return
        }
        guard let token = AuthService.shared.accessToken else {
            logger.error("syncTransaction failed — no access token")
            return
        }

        var body: [String: Any] = [
            "id": id,
            "user_id": userId,
            "amount": -transaction.amount,  // Store as Plaid convention: positive = expense
            "title": transaction.title ?? "",
            "merchant": transaction.merchant ?? "",
            "date": iso.string(from: transaction.date ?? Date()),
            "payment_method": transaction.paymentMethod ?? "",
            "is_recurring": transaction.isRecurring
        ]
        if let v = transaction.notes              { body["notes"] = v }
        if let v = transaction.category?.name    { body["category_name"] = v }

        // Capture account info before entering the Task (CoreData objects are not Sendable)
        var accountUpsertBody: [String: Any]? = nil
        if let account = transaction.account, account.plaidItemId == nil,
           let accountId = account.id?.uuidString.lowercased() {
            var ab: [String: Any] = [
                "id": accountId,
                "user_id": userId,
                "name": account.name ?? "",
                "type": account.type ?? ""
            ]
            if let v = account.institution { ab["institution"] = v }
            if let v = account.last4       { ab["last4"] = v }
            accountUpsertBody = ab
            body["account_id"] = accountId
        }

        logger.info("syncTransaction → upserting id=\(id) title=\(transaction.title ?? "")")
        Task {
            // Ensure the account exists in Supabase before the transaction references it
            if let ab = accountUpsertBody {
                await upsert(table: "manual_accounts", body: ab, token: token)
            }
            await upsert(table: "manual_transactions", body: body, token: token)
        }
    }

    func syncIncome(_ income: Income) {
        guard let id = income.id?.uuidString.lowercased(),
              let userId = AuthService.shared.currentUser?.id.uuidString.lowercased(),
              let token = AuthService.shared.accessToken else { return }

        var body: [String: Any] = [
            "id": id,
            "user_id": userId,
            "amount": -income.amount,  // Store as Plaid convention: positive income = negative in DB
            "source": income.source ?? "",
            "date": iso.string(from: income.date ?? Date())
        ]
        if let v = income.notes                           { body["notes"] = v }
        if let v = income.account?.id?.uuidString.lowercased() { body["account_id"] = v }

        Task { await upsert(table: "manual_income", body: body, token: token) }
    }

    // MARK: - Delete

    func deleteTransaction(_ transaction: Transaction) {
        guard transaction.plaidTransactionId == nil,
              let id = transaction.id?.uuidString.lowercased(),
              let token = AuthService.shared.accessToken else { return }
        Task { await delete(table: "manual_transactions", id: id, token: token) }
    }

    func deleteAccount(_ account: Account) {
        guard account.plaidItemId == nil,
              let id = account.id?.uuidString.lowercased(),
              let token = AuthService.shared.accessToken else { return }
        Task { await delete(table: "manual_accounts", id: id, token: token) }
    }

    // MARK: - Restore (called on every sign-in; idempotent)

    func restoreManualData(context: NSManagedObjectContext) async {
        guard let userId = AuthService.shared.currentUser?.id.uuidString.lowercased(),
              let token = AuthService.shared.accessToken else { return }

        await restoreAccounts(userId: userId, token: token, context: context)
        await restoreTransactions(userId: userId, token: token, context: context)
        await restoreIncome(userId: userId, token: token, context: context)

        try? context.save()
    }

    // MARK: - Private: REST helpers

    private func upsert(table: String, body: [String: Any], token: String) async {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/\(table)"),
              let data = try? JSONSerialization.data(withJSONObject: body) else {
            logger.error("upsert(\(table)) — failed to build URL or serialize body")
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue(anonKey,           forHTTPHeaderField: "apikey")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        req.httpBody = data
        do {
            let (respData, response) = try await URLSession.shared.data(for: req)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            if status < 200 || status >= 300 {
                let body = String(data: respData, encoding: .utf8) ?? "<binary>"
                logger.error("upsert(\(table)) HTTP \(status): \(body)")
            } else {
                logger.info("upsert(\(table)) succeeded — HTTP \(status)")
            }
        } catch {
            logger.error("upsert(\(table)) network error: \(error.localizedDescription)")
        }
    }

    private func delete(table: String, id: String, token: String) async {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/\(table)?id=eq.\(id)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue(anonKey,           forHTTPHeaderField: "apikey")
        do {
            let (respData, response) = try await URLSession.shared.data(for: req)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            if status < 200 || status >= 300 {
                let body = String(data: respData, encoding: .utf8) ?? "<binary>"
                logger.error("delete(\(table)) HTTP \(status): \(body)")
            }
        } catch {
            logger.error("delete(\(table)) network error: \(error.localizedDescription)")
        }
    }

    private func fetch<T: Decodable>(table: String, userId: String, token: String) async -> [T] {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/\(table)?user_id=eq.\(userId)&select=*") else { return [] }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue(anonKey,           forHTTPHeaderField: "apikey")
        guard let (data, _) = try? await URLSession.shared.data(for: req) else { return [] }
        return (try? JSONDecoder().decode([T].self, from: data)) ?? []
    }

    // MARK: - Private: restore helpers

    private func restoreAccounts(userId: String, token: String, context: NSManagedObjectContext) async {
        let rows: [SyncAccountRow] = await fetch(table: "manual_accounts", userId: userId, token: token)
        for row in rows {
            let req = Account.fetchRequest() as NSFetchRequest<Account>
            req.predicate = NSPredicate(format: "id == %@", row.id as CVarArg)
            req.fetchLimit = 1
            if (try? context.count(for: req)) ?? 0 > 0 { continue }

            let account = Account(context: context)
            account.id          = row.id
            account.name        = row.name
            account.type        = row.type
            account.institution = row.institution
            account.last4       = row.last4
        }
    }

    private func restoreTransactions(userId: String, token: String, context: NSManagedObjectContext) async {
        let rows: [SyncTransactionRow] = await fetch(table: "manual_transactions", userId: userId, token: token)
        for row in rows {
            let req = Transaction.fetchRequest() as NSFetchRequest<Transaction>
            req.predicate = NSPredicate(format: "id == %@", row.id as CVarArg)
            req.fetchLimit = 1
            if (try? context.count(for: req)) ?? 0 > 0 { continue }

            let catReq = Category.fetchRequest() as NSFetchRequest<Category>
            catReq.predicate = NSPredicate(format: "name == %@", row.category_name ?? "")
            catReq.fetchLimit = 1
            let category = (try? context.fetch(catReq))?.first

            var account: Account?
            if let accountId = row.account_id {
                let accReq = Account.fetchRequest() as NSFetchRequest<Account>
                accReq.predicate = NSPredicate(format: "id == %@", accountId as CVarArg)
                accReq.fetchLimit = 1
                account = (try? context.fetch(accReq))?.first
            }

            let t = Transaction(context: context)
            t.id            = row.id
            t.amount        = -row.amount  // Flip back: Supabase stores positive = expense, CoreData uses negative
            t.title         = row.title
            t.merchant      = row.merchant
            t.date          = iso.date(from: row.date)
            t.notes         = row.notes
            t.paymentMethod = row.payment_method
            t.isRecurring   = row.is_recurring
            t.category      = category
            t.account       = account
            t.createdAt     = Date()
            t.updatedAt     = Date()
        }
    }

    private func restoreIncome(userId: String, token: String, context: NSManagedObjectContext) async {
        let rows: [SyncIncomeRow] = await fetch(table: "manual_income", userId: userId, token: token)
        for row in rows {
            let req = Income.fetchRequest() as NSFetchRequest<Income>
            req.predicate = NSPredicate(format: "id == %@", row.id as CVarArg)
            req.fetchLimit = 1
            if (try? context.count(for: req)) ?? 0 > 0 { continue }

            var account: Account?
            if let accountId = row.account_id {
                let accReq = Account.fetchRequest() as NSFetchRequest<Account>
                accReq.predicate = NSPredicate(format: "id == %@", accountId as CVarArg)
                accReq.fetchLimit = 1
                account = (try? context.fetch(accReq))?.first
            }

            let income = Income(context: context)
            income.id      = row.id
            income.amount  = -row.amount  // Flip back: Supabase stores negated, CoreData uses positive for income
            income.source  = row.source
            income.date    = iso.date(from: row.date)
            income.notes   = row.notes
            income.account = account
        }
    }
}

// MARK: - Decodable row types

private struct SyncAccountRow: Decodable {
    let id: UUID
    let name: String
    let type: String
    let institution: String?
    let last4: String?
}

private struct SyncTransactionRow: Decodable {
    let id: UUID
    let amount: Double
    let title: String
    let merchant: String
    let date: String
    let notes: String?
    let payment_method: String
    let category_name: String?
    let account_id: UUID?
    let is_recurring: Bool
}

private struct SyncIncomeRow: Decodable {
    let id: UUID
    let amount: Double
    let source: String
    let date: String
    let notes: String?
    let account_id: UUID?
}
