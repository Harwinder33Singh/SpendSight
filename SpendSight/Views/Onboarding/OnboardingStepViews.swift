//
//  OnboardingStepViews.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/18/26.
//

import SwiftUI

// MARK: - Welcome Step

struct WelcomeStepView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Hero
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.15), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)

                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(.top, 32)
                .padding(.bottom, 28)

                // Title
                VStack(spacing: 8) {
                    Text("Welcome to")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("SpendSight")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("Take control of your finances.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .padding(.bottom, 40)

                // Features
                VStack(spacing: 16) {
                    WelcomeFeatureCard(
                        icon: "chart.bar.fill",
                        color: .blue,
                        title: "Smart Tracking",
                        description: "Automatically categorize and track every transaction."
                    )
                    WelcomeFeatureCard(
                        icon: "building.columns.fill",
                        color: .green,
                        title: "Connect Your Banks",
                        description: "Link accounts via Plaid for real-time sync."
                    )
                    WelcomeFeatureCard(
                        icon: "target",
                        color: .orange,
                        title: "Budget Goals",
                        description: "Set limits per category and stay on track."
                    )
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct WelcomeFeatureCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Categories Step

struct CategoriesStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 6) {
                Text("Pick Your Categories")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text("Choose what you want to track")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)

            // Actions bar
            HStack {
                Button("All") { viewModel.selectAllCategories() }
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())

                Button("None") { viewModel.deselectAllCategories() }
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())

                Spacer()

                Text("\(viewModel.selectedCategories.count) selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Grid
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.defaultCategories, id: \.name) { cat in
                        let selected = viewModel.selectedCategories.contains(cat.name)
                        let catColor = color(from: cat.color)

                        Button {
                            withAnimation(.spring(response: 0.25)) {
                                viewModel.toggleCategory(cat.name)
                            }
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(selected ? catColor : Color(.systemGray5))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: cat.icon)
                                        .font(.system(size: 18))
                                        .foregroundStyle(selected ? .white : .secondary)
                                }
                                Text(cat.name)
                                    .font(.system(size: 11, weight: selected ? .semibold : .regular))
                                    .foregroundStyle(selected ? .primary : .secondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selected ? catColor.opacity(0.1) : Color(.secondarySystemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(selected ? catColor : .clear, lineWidth: 1.5)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Accounts Step

struct AccountsStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showAddAccount = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 6) {
                    Text("Add Your Accounts")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("You can also connect accounts later")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                // Empty state or account list
                if viewModel.accounts.isEmpty {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 72, height: 72)
                            Image(systemName: "building.columns")
                                .font(.system(size: 30))
                                .foregroundStyle(.secondary)
                        }
                        Text("No accounts yet")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 24)
                } else {
                    VStack(spacing: 10) {
                        ForEach(Array(viewModel.accounts.enumerated()), id: \.element.id) { index, account in
                            AccountRow(account: account)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.removeAccount(at: index)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // Add account button
                Button {
                    showAddAccount = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Add Account Manually")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.secondarySystemBackground))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
            }
        }
        .sheet(isPresented: $showAddAccount) {
            AddAccountSheet(viewModel: viewModel)
        }
    }
}

struct AccountRow: View {
    let account: AccountData

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: iconForAccountType(account.type))
                    .font(.title3)
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(account.displayName)
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 6) {
                    Text(account.type)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let last4 = account.last4 {
                        Text("•••• \(last4)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if account.initialBalance != 0 {
                Text(account.initialBalance >= 0 ? "+$\(String(format: "%.2f", account.initialBalance))" : "-$\(String(format: "%.2f", abs(account.initialBalance)))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(account.initialBalance >= 0 ? .green : .red)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func iconForAccountType(_ type: String) -> String {
        switch type.lowercased() {
        case "checking":    return "building.columns.fill"
        case "savings":     return "banknote.fill"
        case "credit card": return "creditcard.fill"
        case "cash":        return "dollarsign.circle.fill"
        default:            return "folder.fill"
        }
    }
}

// MARK: - Security / Done Step

struct SecurityStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.15), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                    Image(systemName: "checkmark.shield.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(.top, 32)

                VStack(spacing: 8) {
                    Text("You're All Set!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("Your account is ready. Here's what protects your data.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                // Security cards
                VStack(spacing: 12) {
                    SecurityCard(
                        icon: "lock.fill",
                        color: .blue,
                        title: "End-to-End Encryption",
                        description: "All your financial data is encrypted at rest and in transit."
                    )
                    SecurityCard(
                        icon: "eye.slash.fill",
                        color: .purple,
                        title: "Privacy First",
                        description: "We never sell or share your personal financial data."
                    )
                    SecurityCard(
                        icon: "faceid",
                        color: .green,
                        title: "Biometric Access",
                        description: "Enable Face ID in Settings for quick and secure access."
                    )
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct SecurityCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Helper

private func color(from hex: String) -> Color {
    let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    guard Scanner(string: cleaned).scanHexInt64(&int) else { return .blue }
    let a, r, g, b: UInt64
    switch cleaned.count {
    case 6: (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
    case 8: (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default: return .blue
    }
    return Color(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
}
