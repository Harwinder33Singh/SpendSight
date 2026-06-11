import SwiftUI
import Supabase
import Combine

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var needsEmailConfirmation = false

    private init() {}

    // MARK: - Access token for Plaid API calls

    var accessToken: String? {
        supabase.auth.currentSession?.accessToken
    }

    // MARK: - Session restore on launch

    func initialize() async {
        // Check for an existing persisted session
        if let session = supabase.auth.currentSession {
            currentUser = session.user
            isAuthenticated = true
        } else {
            // Try to refresh — handles app restarts where session may still be valid
            if let session = try? await supabase.auth.session {
                currentUser = session.user
                isAuthenticated = true
            }
        }

        // Listen for future auth state changes
        Task {
            for await (event, session) in supabase.auth.authStateChanges {
                switch event {
                case .signedIn, .tokenRefreshed, .userUpdated:
                    currentUser = session?.user
                    isAuthenticated = session != nil
                case .signedOut, .userDeleted:
                    currentUser = nil
                    isAuthenticated = false
                default:
                    break
                }
                NotificationCenter.default.post(name: .authStateDidChange, object: nil)
            }
        }
    }

    // MARK: - Email Sign Up

    func signUp(email: String, password: String, fullName: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let response = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": AnyJSON.string(fullName)]
        )
        currentUser = response.user

        if response.session != nil {
            // Auto-confirm enabled in Supabase — proceed directly
            isAuthenticated = true
            needsEmailConfirmation = false
        } else {
            // Confirmation email sent — user must confirm then sign in
            needsEmailConfirmation = true
        }
    }

    // MARK: - Email Sign In

    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let session = try await supabase.auth.signIn(email: email, password: password)
        currentUser = session.user
        isAuthenticated = true
    }

    // MARK: - Sign Out

    func signOut() async throws {
        try await supabase.auth.signOut()
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Password Reset

    func resetPassword(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
    }
}
