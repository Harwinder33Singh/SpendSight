import Foundation

class AIAdvisorService {
    static let shared = AIAdvisorService()
    private let endpoint = "https://awynihhwctqxvxhsbfxw.supabase.co/functions/v1/ai-advisor"
    private init() {}

    private struct RequestBody: Encodable {
        let message: String
        let context: FinancialContext
    }
    private struct StreamChunk: Decodable {
        let text: String
    }

    /// Returns an AsyncThrowingStream that yields text tokens as they stream from Claude.
    func stream(message: String, context: FinancialContext) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let token = await AuthService.shared.accessToken else {
                        continuation.finish(throwing: URLError(.userAuthenticationRequired))
                        return
                    }

                    var req = URLRequest(url: URL(string: endpoint)!)
                    req.httpMethod = "POST"
                    req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.httpBody = try JSONEncoder().encode(RequestBody(message: message, context: context))
                    req.timeoutInterval = 60

                    let (bytes, response) = try await URLSession.shared.bytes(for: req)

                    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                        continuation.finish(throwing: URLError(.badServerResponse))
                        return
                    }

                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let payload = String(line.dropFirst(6))
                        if payload == "[DONE]" { break }
                        if let data = payload.data(using: .utf8),
                           let chunk = try? JSONDecoder().decode(StreamChunk.self, from: data) {
                            continuation.yield(chunk.text)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
