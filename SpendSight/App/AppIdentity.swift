import Foundation

/// Provides a stable, anonymous user ID that persists for the lifetime of the app install.
/// This is completely separate from the user's display name.
enum AppIdentity {
    private static let key = "appUserId"

    static var userId: String {
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let new = UUID().uuidString
        UserDefaults.standard.set(new, forKey: key)
        return new
    }
}
