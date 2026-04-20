//
//  PlaidErrorView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 4/20/26.
//

import SwiftUI

enum PlaidConnectionError {
    case expiredToken
    case bankDisconnected
    case noInternet
    case syncFailed(String)

    var title: String {
        switch self {
        case .expiredToken:       return "Reconnection Required"
        case .bankDisconnected:   return "Bank Disconnected"
        case .noInternet:         return "No Internet Connection"
        case .syncFailed:         return "Sync Failed"
        }
    }

    var message: String {
        switch self {
        case .expiredToken:
            return "Your bank connection has expired. Please reconnect to continue syncing transactions."
        case .bankDisconnected:
            return "Your bank has disconnected from SpendSight. Please reconnect your account."
        case .noInternet:
            return "Please check your internet connection and try again."
        case .syncFailed(let reason):
            return "Failed to sync transactions: \(reason). Please try again."
        }
    }

    var icon: String {
        switch self {
        case .expiredToken:     return "clock.badge.exclamationmark"
        case .bankDisconnected: return "building.columns.badge.exclamationmark"
        case .noInternet:       return "wifi.slash"
        case .syncFailed:       return "arrow.triangle.2.circlepath.circle"
        }
    }

    var iconColor: Color {
        switch self {
        case .expiredToken:     return .orange
        case .bankDisconnected: return .red
        case .noInternet:       return .gray
        case .syncFailed:       return .yellow
        }
    }

    var actionLabel: String {
        switch self {
        case .expiredToken, .bankDisconnected: return "Reconnect Bank"
        case .noInternet:                      return "Try Again"
        case .syncFailed:                      return "Retry Sync"
        }
    }
}

struct PlaidErrorBanner: View {
    let error: PlaidConnectionError
    let onAction: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: error.icon)
                    .font(.title2)
                    .foregroundStyle(error.iconColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(error.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(error.message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()

            Divider()

            Button(action: onAction) {
                Text(error.actionLabel)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(error.iconColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(error.iconColor.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(error.iconColor.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}
