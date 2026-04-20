//
//  PlaidService.swift
//  SpendSight
//
//  Created by Harwinder Singh on 4/15/26.
//

import Foundation

// MARK: - Response Models

struct LinkTokenResponse: Codable {
    let linkToken: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case linkToken = "link_token"
        case error
    }
}

struct ExchangeTokenResponse: Codable {
    let success: Bool?
    let institutionName: String?
    let itemId: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case success
        case institutionName = "institution_name"
        case itemId = "item_id"
        case error
    }
}

struct PlaidTransaction: Codable {
    let plaidTransactionId: String
    let amount: Double
    let date: String
    let merchantName: String?
    let plaidCategory: String?
    let institutionName: String?
    let itemId: String?
    let pending: Bool?

    enum CodingKeys: String, CodingKey {
        case plaidTransactionId = "plaid_transaction_id"
        case amount
        case date
        case merchantName = "merchant_name"
        case plaidCategory = "plaid_category"
        case institutionName = "institution_name"
        case itemId = "item_id"
        case pending
    }
}

struct SyncTransactionsResponse: Codable {
    let transactions: [PlaidTransaction]?
    let error: String?
    let message: String?
}

// MARK: - PlaidService

class PlaidService {
    static let shared = PlaidService()

    // Replace with your actual values
    private let supabaseURL = "https://njkhiuxeaxgnuitagrat.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qa2hpdXhlYXhnbnVpdGFncmF0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyMzM1NzAsImV4cCI6MjA5MTgwOTU3MH0.xdygYr9cmNrid7IU24eh4w09AoXMd5_rL0Cn7uyFJlU"
    private init() {}

    // MARK: - Create Link Token

    func createLinkToken(userId: String) async throws -> String {
        let url = URL(string: "\(supabaseURL)/functions/v1/plaid-create-link-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["user_id": userId])

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(LinkTokenResponse.self, from: data)

        if let error = response.error {
            throw PlaidError.serverError(error)
        }

        guard let linkToken = response.linkToken else {
            throw PlaidError.missingLinkToken
        }

        return linkToken
    }

    // MARK: - Exchange Public Token

    func exchangePublicToken(publicToken: String, userId: String) async throws -> ExchangeTokenResponse {
        let url = URL(string: "\(supabaseURL)/functions/v1/plaid-exchange-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["public_token": publicToken, "user_id": userId]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(ExchangeTokenResponse.self, from: data)

        if let error = response.error {
            throw PlaidError.serverError(error)
        }

        return response
    }

    // MARK: - Sync Transactions

    func syncTransactions(userId: String) async throws -> [PlaidTransaction] {
        let url = URL(string: "\(supabaseURL)/functions/v1/plaid-sync-transactions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["user_id": userId])

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(SyncTransactionsResponse.self, from: data)

        if let error = response.error {
            throw PlaidError.serverError(error)
        }
        
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastPlaidSync")
        
        return response.transactions ?? []
    }
    
    func detectError(from error: Error) -> PlaidConnectionError {
        let message = error.localizedDescription.lowercased()

        if message.contains("offline") || message.contains("network") ||
           message.contains("internet") || message.contains("connection") {
            return .noInternet
        }

        if message.contains("expired") || message.contains("token") {
            return .expiredToken
        }

        if message.contains("disconnected") || message.contains("revoked") {
            return .bankDisconnected
        }

        return .syncFailed(error.localizedDescription)
    }
}

// MARK: - Errors

enum PlaidError: LocalizedError {
    case serverError(String)
    case missingLinkToken
    case syncFailed

    var errorDescription: String? {
        switch self {
        case .serverError(let message): return message
        case .missingLinkToken: return "Failed to get link token from server"
        case .syncFailed: return "Failed to sync transactions"
        }
    }
}
