import Foundation

@MainActor
final class CoachChatViewModel: ObservableObject {
    @Published var draft = ""
    @Published var isSending = false

    let quickPrompts = [
        "I'm tired today",
        "I slept badly",
        "I missed my workout",
        "How much water today?"
    ]

    func send(appState: AppState, text: String? = nil) async {
        let outgoing = text ?? draft
        draft = ""
        isSending = true
        await appState.sendCoachMessage(outgoing)
        isSending = false
    }
}
