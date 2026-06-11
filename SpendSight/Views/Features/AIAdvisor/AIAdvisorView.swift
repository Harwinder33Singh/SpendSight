import SwiftUI
import CoreData

struct AIAdvisorView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm: AIAdvisorViewModel
    @StateObject private var profile = ProfileService.shared
    @FocusState private var inputFocused: Bool

    init(context: NSManagedObjectContext) {
        _vm = StateObject(wrappedValue: AIAdvisorViewModel(context: context))
    }

    var body: some View {
        NavigationStack {
            Group {
                if profile.isPro {
                    chatView
                } else {
                    paywallView
                }
            }
            .navigationTitle("AI Advisor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if profile.isPro {
                        Label("Pro", systemImage: "sparkles")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.purple)
                    }
                }
            }
        }
        .task { await profile.fetchProfile() }
    }

    // MARK: - Chat View

    private var chatView: some View {
        VStack(spacing: 0) {
            // Quick prompts
            quickPromptsBar

            Divider()

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.messages) { msg in
                            MessageBubble(message: msg)
                                .id(msg.id)
                        }
                        if vm.isStreaming && vm.messages.last?.role == .assistant && vm.messages.last?.text.isEmpty == true {
                            TypingIndicator()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .onChange(of: vm.messages.count) { _, _ in
                    if let last = vm.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                .onChange(of: vm.messages.last?.text) { _, _ in
                    if let last = vm.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            Divider()

            // Input bar
            inputBar
        }
    }

    // MARK: - Quick Prompts

    private var quickPromptsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(vm.quickPrompts, id: \.self) { prompt in
                    Button {
                        vm.sendQuickPrompt(prompt)
                    } label: {
                        Text(prompt)
                            .font(.caption.weight(.medium))
                            .lineLimit(1)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(Color(.systemGray4), lineWidth: 0.5))
                    }
                    .foregroundStyle(.primary)
                    .disabled(vm.isStreaming)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask about your finances…", text: $vm.inputText, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .focused($inputFocused)
                .onSubmit { vm.send() }
                .disabled(vm.isStreaming)

            Button {
                inputFocused = false
                vm.send()
            } label: {
                ZStack {
                    Circle()
                        .fill(vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isStreaming
                              ? Color(.systemGray4)
                              : Color.accentColor)
                        .frame(width: 36, height: 36)
                    Image(systemName: vm.isStreaming ? "stop.fill" : "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .disabled(vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isStreaming)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    // MARK: - Paywall

    private var paywallView: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.purple.opacity(0.15), .blue.opacity(0.1)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 120)
                Image(systemName: "sparkles")
                    .font(.system(size: 52))
                    .foregroundStyle(LinearGradient(colors: [.purple, .blue],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing))
            }

            VStack(spacing: 8) {
                Text("AI Advisor")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text("Personalized financial advice\nbased on your real spending data.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 14) {
                PaywallFeatureRow(icon: "chart.bar.fill",   color: .blue,   text: "Budget analysis with your actual numbers")
                PaywallFeatureRow(icon: "airplane",         color: .purple, text: "Trip & purchase affordability planning")
                PaywallFeatureRow(icon: "lightbulb.fill",   color: .orange, text: "Personalized savings recommendations")
                PaywallFeatureRow(icon: "bell.badge.fill",  color: .red,    text: "Proactive over-budget alerts")
            }
            .padding(.horizontal, 32)

            Button {
                // RevenueCat purchase flow — Phase 3
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Upgrade to Pro")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(LinearGradient(colors: [.purple, .blue],
                                          startPoint: .leading, endPoint: .trailing))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)

            Text("Cancel anytime · Billed monthly")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .assistant {
                // AI avatar
                ZStack {
                    Circle().fill(Color.accentColor.opacity(0.15)).frame(width: 28, height: 28)
                    Image(systemName: "sparkles").font(.system(size: 12)).foregroundStyle(Color.accentColor)
                }
                .alignmentGuide(.bottom) { d in d[.bottom] }
            }

            if message.role == .user { Spacer(minLength: 60) }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 2) {
                SimpleMarkdownText(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.role == .user
                                ? Color.accentColor
                                : Color(.secondarySystemBackground))
                    .foregroundStyle(message.role == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            if message.role == .assistant { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var phase = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color(.systemGray3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(phase == i ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15), value: phase)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onAppear { phase = 1 }
    }
}

// MARK: - Paywall Feature Row

struct PaywallFeatureRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            }
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
    }
}

// MARK: - Simple Markdown Renderer

struct SimpleMarkdownText: View {
    private let segments: [Segment]

    struct Segment: Identifiable {
        let id = UUID()
        let text: String
        let isBold: Bool
    }

    init(_ raw: String) {
        var segs: [Segment] = []
        var remaining = raw
        while !remaining.isEmpty {
            if let start = remaining.range(of: "**"),
               let end = remaining.range(of: "**", range: start.upperBound..<remaining.endIndex) {
                let before = String(remaining[..<start.lowerBound])
                if !before.isEmpty { segs.append(Segment(text: before, isBold: false)) }
                let bold = String(remaining[start.upperBound..<end.lowerBound])
                if !bold.isEmpty { segs.append(Segment(text: bold, isBold: true)) }
                remaining = String(remaining[end.upperBound...])
            } else {
                segs.append(Segment(text: remaining, isBold: false))
                break
            }
        }
        self.segments = segs
    }

    var body: some View {
        segments.reduce(Text("")) { result, seg in
            result + (seg.isBold
                      ? Text(seg.text).fontWeight(.bold)
                      : Text(seg.text))
        }
        .font(.subheadline)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    AIAdvisorView(context: PersistenceController.shared.container.viewContext)
}
