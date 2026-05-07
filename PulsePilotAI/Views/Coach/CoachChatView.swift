import SwiftUI

struct CoachChatView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = CoachChatViewModel()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if appState.isPremiumPreview == false {
                premiumPreviewBanner
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
            }

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(appState.chatMessages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }

                        if viewModel.isSending {
                            TypingBubble()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 12)
                }
                .onChange(of: appState.chatMessages.count) {
                    if let last = appState.chatMessages.last {
                        withAnimation(.smooth) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            quickPrompts
            inputBar
        }
        .background(AppTheme.groupedBackground.ignoresSafeArea())
        .navigationTitle("AI Coach")
    }

    private var premiumPreviewBanner: some View {
        GradientCard(colors: [AppTheme.violet, AppTheme.accent], cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(AppTheme.amber)

                    Text("AI Coach Preview")
                        .font(.headline)
                }

                Text("Explore adaptive coaching suggestions for tired days, poor sleep, and missed workouts.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    appState.setPremiumPreview(true)
                } label: {
                    Text("Enable Coach Preview")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
            }
        }
    }

    private var quickPrompts: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.quickPrompts, id: \.self) { prompt in
                    Button {
                        Task { await viewModel.send(appState: appState, text: prompt) }
                    } label: {
                        Text(prompt)
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(AppTheme.elevatedBackground))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isSending || appState.isPremiumPreview == false)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Tell PulsePilot how you feel", text: $viewModel.draft, axis: .vertical)
                .lineLimit(1...4)
                .textFieldStyle(.plain)
                .focused($isInputFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.elevatedBackground)
                )
                .disabled(appState.isPremiumPreview == false)

            Button {
                Task {
                    await viewModel.send(appState: appState)
                    isInputFocused = false
                }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(canSend ? AppTheme.accent : AppTheme.secondaryText.opacity(0.35)))
            }
            .buttonStyle(.plain)
            .disabled(canSend == false)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var canSend: Bool {
        appState.isPremiumPreview && viewModel.isSending == false && viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}

private struct ChatBubble: View {
    var message: ChatMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 44) }

            Text(message.text)
                .font(.body)
                .foregroundStyle(isUser ? .white : AppTheme.primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(isUser ? AppTheme.accent : AppTheme.elevatedBackground)
                )

            if isUser == false { Spacer(minLength: 44) }
        }
    }
}

private struct TypingBubble: View {
    var body: some View {
        HStack {
            Text("PulsePilot is adjusting your plan...")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(AppTheme.elevatedBackground)
                )
            Spacer(minLength: 44)
        }
        .padding(.horizontal, 16)
    }
}
