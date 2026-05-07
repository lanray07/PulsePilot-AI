import SwiftUI

enum AppTab: Hashable, CaseIterable {
    case today
    case missions
    case coach
    case weekly
    case settings

    var title: String {
        switch self {
        case .today: "Today"
        case .missions: "Missions"
        case .coach: "Coach"
        case .weekly: "Weekly"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "heart.text.square.fill"
        case .missions: "checklist.checked"
        case .coach: "bubble.left.and.bubble.right.fill"
        case .weekly: "chart.xyaxis.line"
        case .settings: "gearshape.fill"
        }
    }
}
