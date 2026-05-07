import Foundation

enum ChatRole: String, Codable {
    case user
    case coach
}

struct ChatMessage: Identifiable, Codable, Equatable {
    var id = UUID()
    var role: ChatRole
    var text: String
    var date: Date
}
