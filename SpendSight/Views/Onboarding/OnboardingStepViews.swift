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
        VStack(spacing: 30) {
            Spacer()
            
            // App icon/logo
            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 12) {
                Text("Welcome to SpendSight")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your personal finance tracker")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "chart.bar.fill",
                    title: "Track Spending",
                    description: "Monitor your expenses across categories"
                )
                
                FeatureRow(
                    icon: "creditcard.fill",
                    title: "Multiple Accounts",
                    description: "Manage all your accounts in one place"
                )
                
                FeatureRow(
                    icon: "lock.shield.fill",
                    title: "Secure & Private",
                    description: "Your data stays on your device"
                )
            }
            .padding()
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Personal Info Step

struct PersonalInfoStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var focusedField: FocusedField?

    enum FocusedField {
        case name, email, phone
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero section with gradient background
                VStack(spacing: 16) {
                    // Animated profile icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.2), .purple.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)

                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .padding(.top, 20)

                    VStack(spacing: 8) {
                        Text("Personal Information")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("Tell us a bit about yourself")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)

                // Form section
                VStack(spacing: 24) {
                    // Name field
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.blue)
                                .frame(width: 20)

                            Text("Full Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)

                            Text("*")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.red)

                            Spacer()
                        }

                        TextField("Enter your name", text: $viewModel.fullName)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                focusedField == .name ? Color.blue : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            )
                            .textInputAutocapitalization(.words)
                            .focused($focusedField, equals: .name)
                    }

                    // Email field
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.green)
                                .frame(width: 20)

                            Text("Email")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)

                            Text("optional")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray5))
                                )

                            Spacer()
                        }

                        TextField("Enter your email", text: $viewModel.email)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                focusedField == .email ? Color.green : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            )
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .focused($focusedField, equals: .email)
                    }

                    // Phone field
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.orange)
                                .frame(width: 20)

                            Text("Phone")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)

                            Text("optional")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray5))
                                )

                            Spacer()
                        }

                        TextField("Enter your phone number", text: $viewModel.phone)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                focusedField == .phone ? Color.orange : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            )
                            .keyboardType(.phonePad)
                            .focused($focusedField, equals: .phone)
                    }

                    // Currency selection with enhanced design
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.purple)
                                .frame(width: 20)

                            Text("Preferred Currency")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)

                            Text("*")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.red)

                            Spacer()
                        }

                        // Custom currency picker with enhanced styling
                        HStack(spacing: 0) {
                            ForEach(Array(viewModel.availableCurrencies.enumerated()), id: \.element) { index, currency in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.selectedCurrency = currency
                                    }
                                } label: {
                                    Text(currency)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(
                                            viewModel.selectedCurrency == currency ? .white : .primary
                                        )
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    viewModel.selectedCurrency == currency
                                                    ? LinearGradient(
                                                        colors: [.blue, .purple],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                    : LinearGradient(
                                                        colors: [Color(.systemGray6)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .shadow(
                                                    color: viewModel.selectedCurrency == currency
                                                    ? .blue.opacity(0.3) : .clear,
                                                    radius: viewModel.selectedCurrency == currency ? 4 : 0,
                                                    x: 0,
                                                    y: 2
                                                )
                                        )
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray5))
                        )
                        .padding(2)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.8),
                    Color(.systemGray6).opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onTapGesture {
            focusedField = nil
        }
    }
}

// MARK: - Categories Step

struct CategoriesStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Choose Categories")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Select expense categories you want to track")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Quick actions
            HStack {
                Button("Select All") {
                    viewModel.selectAllCategories()
                }
                .buttonStyle(.bordered)
                
                Button("Deselect All") {
                    viewModel.deselectAllCategories()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text("\(viewModel.selectedCategories.count) selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            // Category grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.defaultCategories, id: \.name) { category in
                    CategorySelectionCard(
                        name: category.name,
                        icon: category.icon,
                        color: color(from: category.color),
                        isSelected: viewModel.selectedCategories.contains(category.name)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleCategory(category.name)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategorySelectionCard: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(isSelected ? color : .gray)
            
            Text(name)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? color.opacity(0.1) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? color : Color.clear, lineWidth: 2)
        )
        .overlay(alignment: .topTrailing) {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(color)
                    .padding(6)
            }
        }
    }
}

// MARK: - Accounts Step

struct AccountsStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showAddAccount = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Add Your Accounts")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Add bank accounts, credit cards, and payment methods")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Account list
            if viewModel.accounts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "building.columns.circle")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text("No accounts added yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Add at least one account to get started")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.accounts.enumerated()), id: \.element.id) { index, account in
                        AccountRow(account: account)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.removeAccount(at: index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            
            // Add account button
            Button {
                showAddAccount = true
            } label: {
                Label("Add Account", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundColor(.accentColor)
                    .cornerRadius(12)
            }
            
            // Skip option
            if viewModel.accounts.isEmpty {
                Button("Skip for now") {
                    withAnimation {
                        viewModel.nextStep()
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .sheet(isPresented: $showAddAccount) {
            AddAccountSheet(viewModel: viewModel)
        }
    }
}

struct AccountRow: View {
    let account: AccountData
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconForAccountType(account.type))
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(account.displayName)
                    .font(.headline)
                
                HStack {
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
                Text("$\(String(format: "%.2f", account.initialBalance))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(account.initialBalance >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func iconForAccountType(_ type: String) -> String {
        switch type.lowercased() {
        case "checking": return "building.columns.fill"
        case "savings": return "banknote.fill"
        case "credit card": return "creditcard.fill"
        case "cash": return "dollarsign.circle.fill"
        default: return "folder.fill"
        }
    }
}

// MARK: - Security Step

struct SecurityStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Security Settings")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Secure your financial data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom)
            
            // Security icon
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding()
            
            // Security features
            VStack(spacing: 16) {
                SecurityFeatureRow(
                    icon: "iphone.and.arrow.right.outward",
                    title: "Local Storage",
                    description: "Your data stays on your device"
                )
                
                SecurityFeatureRow(
                    icon: "lock.rotation",
                    title: "Encrypted Data",
                    description: "All sensitive data is encrypted"
                )
                
                SecurityFeatureRow(
                    icon: "eye.slash.fill",
                    title: "Privacy First",
                    description: "We never share your financial data"
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
        }
    }
}

struct SecurityFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Helper Function

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
    
    return Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
}
