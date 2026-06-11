import Foundation
import Combine
internal import Auth

@MainActor
class ProfileService: ObservableObject {
    static let shared = ProfileService()

    @Published var isPro = false

    private let supabaseURL = "https://awynihhwctqxvxhsbfxw.supabase.co"
    private let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3eW5paGh3Y3RxeHZ4aHNiZnh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxMTEyODYsImV4cCI6MjA5NTY4NzI4Nn0.8-x11Ptc8IVFl3vSHFl4K1nUiu5sD-v9DItZwb93nxs"

    private init() {}

    private struct ProfileRow: Decodable {
        let subscription_tier: String?
    }

    func fetchProfile() async {
        guard let token = AuthService.shared.accessToken,
              let userId = AuthService.shared.currentUser?.id.uuidString else { return }

        guard let url = URL(string: "\(supabaseURL)/rest/v1/profiles?id=eq.\(userId)&select=subscription_tier") else { return }

        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")

        guard let (data, _) = try? await URLSession.shared.data(for: req),
              let rows = try? JSONDecoder().decode([ProfileRow].self, from: data),
              let row = rows.first else { return }

        isPro = row.subscription_tier == "pro"
    }
}
