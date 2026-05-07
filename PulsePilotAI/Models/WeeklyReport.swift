import Foundation

struct EnergyForecastSegment: Identifiable, Hashable {
    var id: String { period }
    var period: String
    var score: Int
    var note: String
}

struct WeeklyReport: Equatable {
    var consistencyScore: Int
    var averageSleepHours: Double
    var averageSteps: Int
    var recoveryTrend: [Int]
    var completedMissions: Int
    var summary: String

    static let empty = WeeklyReport(
        consistencyScore: 0,
        averageSleepHours: 0,
        averageSteps: 0,
        recoveryTrend: [],
        completedMissions: 0,
        summary: "Your weekly report will fill in as PulsePilot collects more days."
    )
}
