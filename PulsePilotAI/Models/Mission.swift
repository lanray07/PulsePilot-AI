import Foundation

enum MissionCategory: String, CaseIterable, Codable, Identifiable {
    case movement
    case hydration
    case recovery
    case sleep
    case nutrition
    case mindfulness

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .movement: "Movement"
        case .hydration: "Hydration"
        case .recovery: "Recovery"
        case .sleep: "Sleep"
        case .nutrition: "Nutrition"
        case .mindfulness: "Mindfulness"
        }
    }

    var systemImage: String {
        switch self {
        case .movement: "figure.walk"
        case .hydration: "drop.fill"
        case .recovery: "heart.fill"
        case .sleep: "bed.double.fill"
        case .nutrition: "cup.and.saucer.fill"
        case .mindfulness: "sparkles"
        }
    }
}

struct Mission: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var subtitle: String
    var category: MissionCategory
    var targetValue: Double?
    var unit: String?
    var isCompleted: Bool
    var createdAt: Date

    var accessibilityLabel: String {
        "\(title), \(subtitle)"
    }
}
