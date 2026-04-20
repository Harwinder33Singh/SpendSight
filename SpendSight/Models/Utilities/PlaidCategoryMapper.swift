//
//  PlaidCategoryMapper.swift
//  SpendSight
//
//  Created by Harwinder Singh on 4/15/26.
//

import Foundation

struct PlaidCategoryMapper {
    static func mapToSpendSight(_ plaidCategory: String?) -> String {
        guard let category = plaidCategory?.lowercased() else { return "Other" }

        switch category {
        case let c where c.contains("food") || c.contains("restaurant") || c.contains("dining"):
            return "Dining Out"
        case let c where c.contains("groceries") || c.contains("supermarket"):
            return "Groceries"
        case let c where c.contains("travel") || c.contains("airline") || c.contains("flight"):
            return "Travel"
        case let c where c.contains("transport") || c.contains("taxi") || c.contains("uber") || c.contains("lyft"):
            return "Transportation"
        case let c where c.contains("entertainment") || c.contains("recreation"):
            return "Entertainment"
        case let c where c.contains("shop") || c.contains("retail") || c.contains("store"):
            return "Shopping"
        case let c where c.contains("health") || c.contains("medical") || c.contains("pharmacy"):
            return "Healthcare"
        case let c where c.contains("utilities") || c.contains("electric") || c.contains("water") || c.contains("gas"):
            return "Utilities"
        case let c where c.contains("subscription") || c.contains("streaming"):
            return "Subscriptions"
        case let c where c.contains("coffee") || c.contains("cafe"):
            return "Coffee"
        case let c where c.contains("fuel") || c.contains("gas station"):
            return "Fuel"
        case let c where c.contains("hotel") || c.contains("lodging"):
            return "Hotel"
        case let c where c.contains("transfer") || c.contains("payment") || c.contains("credit card"):
            return "Credit Card Payment"
        case let c where c.contains("income") || c.contains("payroll") || c.contains("deposit"):
            return "Income"
        default:
            return "Other"
        }
    }
}
