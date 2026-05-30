import SwiftUI

struct AuthView: View {
    @StateObject private var auth = AuthService.shared
    @State private var mode: Mode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var errorMessage: String?
    @State private var showForgotPassword = false
    @State private var resetEmailSent = false
    @FocusState private var focused: Field?

    enum Mode { case signIn, signUp }
    enum Field { case name, email, password }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue)

                        Text("SpendSight")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(mode == .signIn ? "Welcome back" : "Create your account")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)

                    // Form
                    VStack(spacing: 16) {
                        if mode == .signUp {
                            AuthTextField(
                                icon: "person",
                                placeholder: "Full Name",
                                text: $fullName
                            )
                            .focused($focused, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focused = .email }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        AuthTextField(
                            icon: "envelope",
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        .focused($focused, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focused = .password }

                        AuthSecureField(
                            icon: "lock",
                            placeholder: "Password",
                            text: $password
                        )
                        .focused($focused, equals: .password)
                        .submitLabel(.go)
                        .onSubmit { Task { await submit() } }

                        if let error = errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                        }

                        // Submit button
                        Button {
                            Task { await submit() }
                        } label: {
                            HStack {
                                if auth.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(mode == .signIn ? "Sign In" : "Create Account")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.blue : Color.gray.opacity(0.4))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!isFormValid || auth.isLoading)

                        // Forgot password (sign in only)
                        if mode == .signIn {
                            Button("Forgot password?") {
                                showForgotPassword = true
                            }
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                        }
                    }
                    .padding(.horizontal, 24)
                    .animation(.easeInOut(duration: 0.2), value: mode)

                    // Mode toggle
                    HStack(spacing: 4) {
                        Text(mode == .signIn ? "Don't have an account?" : "Already have an account?")
                            .foregroundStyle(.secondary)
                        Button(mode == .signIn ? "Sign Up" : "Sign In") {
                            withAnimation { mode = mode == .signIn ? .signUp : .signIn }
                            errorMessage = nil
                        }
                        .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.top, 24)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(resetEmailSent: $resetEmailSent)
        }
        .alert("Email Sent", isPresented: $resetEmailSent) {
            Button("OK") {}
        } message: {
            Text("Check your inbox for a password reset link.")
        }
    }

    // MARK: - Helpers

    private var isFormValid: Bool {
        let emailOK = email.contains("@") && email.contains(".")
        let passOK  = password.count >= 6
        if mode == .signUp { return !fullName.isEmpty && emailOK && passOK }
        return emailOK && passOK
    }

    private func submit() async {
        focused = nil
        errorMessage = nil
        do {
            if mode == .signIn {
                try await auth.signIn(email: email.trimmingCharacters(in: .whitespaces),
                                     password: password)
            } else {
                try await auth.signUp(email: email.trimmingCharacters(in: .whitespaces),
                                     password: password,
                                     fullName: fullName.trimmingCharacters(in: .whitespaces))
            }
        } catch {
            errorMessage = friendlyError(error)
        }
    }

    private func friendlyError(_ error: Error) -> String {
        let msg = error.localizedDescription.lowercased()
        if msg.contains("invalid login") || msg.contains("invalid credentials") {
            return "Incorrect email or password."
        }
        if msg.contains("already registered") || msg.contains("already exists") {
            return "An account with this email already exists."
        }
        if msg.contains("weak password") || msg.contains("at least 6") {
            return "Password must be at least 6 characters."
        }
        if msg.contains("network") || msg.contains("offline") {
            return "No internet connection."
        }
        return "Something went wrong. Please try again."
    }
}

// MARK: - Forgot Password Sheet

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var resetEmailSent: Bool
    @State private var email = ""
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter your email and we'll send you a reset link.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                AuthTextField(icon: "envelope", placeholder: "Email", text: $email, keyboardType: .emailAddress)

                if let error {
                    Text(error).font(.caption).foregroundStyle(.red)
                }

                Button {
                    Task {
                        isLoading = true
                        do {
                            try await AuthService.shared.resetPassword(email: email.trimmingCharacters(in: .whitespaces))
                            dismiss()
                            resetEmailSent = true
                        } catch {
                            self.error = "Couldn't send reset email. Check the address and try again."
                        }
                        isLoading = false
                    }
                } label: {
                    Group {
                        if isLoading { ProgressView().tint(.white) }
                        else { Text("Send Reset Link").fontWeight(.semibold) }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(email.contains("@") ? Color.blue : Color.gray.opacity(0.4))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!email.contains("@") || isLoading)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Reusable Text Field Components

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AuthSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
