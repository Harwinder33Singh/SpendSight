//
//  PlaidImporter.swift
//  SpendSight
//
//  Created by Harwinder Singh on 4/20/26.
//

import Foundation
import CoreData

class PlaidImporter {
    static let shared = PlaidImporter()
    private init() {}

    func importTransactions(_ plaidTransactions: [PlaidTransaction], into context: NSManagedObjectContext) async {
        await context.perform {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            for plaidTx in plaidTransactions {
                if plaidTx.pending == true { continue }
                guard let itemId = plaidTx.itemId, !itemId.isEmpty else { continue }

                // Skip duplicates
                let request = Transaction.fetchRequest()
                request.predicate = NSPredicate(
                    format: "plaidTransactionId == %@",
                    plaidTx.plaidTransactionId
                )
                request.fetchLimit = 1
                if let existing = try? context.fetch(request), !existing.isEmpty { continue }

                // Find or create account
                let accountRequest = Account.fetchRequest()
                accountRequest.predicate = NSPredicate(format: "plaidItemId == %@", itemId)
                accountRequest.fetchLimit = 1
                let account: Account
                if let existing = try? context.fetch(accountRequest).first {
                    account = existing
                } else {
                    let newAccount = Account(context: context)
                    newAccount.id = UUID()
                    newAccount.name = plaidTx.institutionName ?? "Connected Bank"
                    newAccount.type = "Checking"
                    newAccount.plaidItemId = itemId
                    newAccount.plaidInstitutionName = plaidTx.institutionName ?? "Connected Bank"
                    account = newAccount
                }

                // Find category
                let categoryName = PlaidCategoryMapper.mapToSpendSight(plaidTx.plaidCategory)
                let categoryRequest = Category.fetchRequest()
                categoryRequest.predicate = NSPredicate(format: "name ==[cd] %@", categoryName)
                categoryRequest.fetchLimit = 1
                var category = try? context.fetch(categoryRequest).first

                if category == nil {
                    let fallback = Category.fetchRequest()
                    fallback.predicate = NSPredicate(format: "name ==[cd] %@", "Other")
                    fallback.fetchLimit = 1
                    category = try? context.fetch(fallback).first
                }

                guard let category = category else { continue }

                let date = dateFormatter.date(from: plaidTx.date) ?? Date()
                let amount = -plaidTx.amount

                let transaction = Transaction(context: context)
                transaction.id = UUID()
                transaction.amount = amount
                transaction.title = plaidTx.merchantName ?? "Transaction"
                transaction.merchant = plaidTx.merchantName ?? ""
                transaction.date = date
                transaction.paymentMethod = "Bank"
                transaction.isRecurring = false
                transaction.category = category
                transaction.account = account
                transaction.plaidTransactionId = plaidTx.plaidTransactionId
                transaction.createdAt = Date()
                transaction.updatedAt = Date()
            }

            try? context.save()
        }
    }
}
