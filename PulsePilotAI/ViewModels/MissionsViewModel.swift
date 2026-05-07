import Foundation

@MainActor
final class MissionsViewModel: ObservableObject {
    var completedSummary: String {
        "Complete 3 missions to protect your streak."
    }

    func progress(for missions: [Mission]) -> Double {
        guard missions.isEmpty == false else { return 0 }
        return Double(missions.filter(\.isCompleted).count) / Double(missions.count)
    }
}
