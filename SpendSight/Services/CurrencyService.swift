//
//  CurrencyService.swift
//  SpendSight
//
//  Created by Harwinder Singh on 3/20/26.
//

import Foundation
import CoreData
import Combine

class CurrencyService: ObservableObject {
    static let shared = CurrencyService()

    @Published var currentCurrency: String = "USD"
    private let context: NSManagedObjectContext

    private init() {
        self.context = PersistenceController.shared.container.viewContext
        loadCurrentCurrency()
    }

    // MARK: - Currency Loading

    private func loadCurrentCurrency() {
        let request = UserProfile.fetchCurrentUser()

        do {
            let profiles = try context.fetch(request)
            if let userProfile = profiles.first {
                currentCurrency = userProfile.currency ?? "USD"
            } else {
                currentCurrency = "USD"
            }
        } catch {
            currentCurrency = "USD"
        }
    }

    // MARK: - Currency Formatting

    func formatAmount(_ amount: Double, showSymbol: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2

        if showSymbol {
            formatter.currencySymbol = currencySymbol
        } else {
            formatter.currencySymbol = ""
        }

        return formatter.string(from: NSNumber(value: amount)) ?? "0.00"
    }

    func formatAmountWithoutDecimals(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencySymbol
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }

    // MARK: - Currency Symbol

    var currencySymbol: String {
        switch currentCurrency {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "INR": return "₹"
        case "CAD": return "C$"
        case "AUD": return "A$"
        case "JPY": return "¥"
        case "CNY": return "¥"
        default: return "$"
        }
    }

    // MARK: - Currency Update

    func updateCurrency(_ newCurrency: String) {
        currentCurrency = newCurrency

        let request = UserProfile.fetchCurrentUser()
        do {
            let profiles = try context.fetch(request)
            if let userProfile = profiles.first {
                userProfile.currency = newCurrency
                try context.save()
            }
        } catch {
            // Handle error silently
        }
    }

    // MARK: - Supported Currencies

    static let supportedCurrencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY", "INR", "CNY"]
}
