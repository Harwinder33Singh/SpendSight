import SwiftUI
import CoreData
import Combine

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    var text: String
    let timestamp = Date()

    enum Role { case user, assistant }
}

@MainActor
class AIAdvisorViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isStreaming = false
    @Published var errorMessage: String?

    private let context: NSManagedObjectContext

    let quickPrompts = [
        "Can I afford a trip to New York next month?",
        "How am I doing on my budget this month?",
        "Where am I overspending and how do I fix it?",
        "How long to save $2,000 at my current rate?",
        "What's my biggest financial risk right now?",
    ]

    init(context: NSManagedObjectContext) {
        self.context = context
        messages.append(ChatMessage(
            role: .assistant,
            text: "Hi! I'm your AI financial advisor. I have real-time access to your spending, budgets, and account data.\n\nAsk me anything — trip planning, budget analysis, savings goals, or just \"how am I doing?\""
        ))
    }

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isStreaming else { return }

        inputText = ""
        errorMessage = nil

        messages.append(ChatMessage(role: .user, text: text))

        var aiMsg = ChatMessage(role: .assistant, text: "")
        messages.append(aiMsg)
        let aiIndex = messages.count - 1

        isStreaming = true

        Task {
            let financialContext = AIContextBuilder.build(context: context)

            do {
                for try await token in AIAdvisorService.shared.stream(message: text, context: financialContext) {
                    messages[aiIndex].text += token
                }
            } catch {
                if messages[aiIndex].text.isEmpty {
                    messages[aiIndex].text = "Sorry, I couldn't connect right now. Please check your connection and try again."
                }
                errorMessage = error.localizedDescription
            }

            isStreaming = false
        }
    }

    func sendQuickPrompt(_ prompt: String) {
        inputText = prompt
        send()
    }
}
