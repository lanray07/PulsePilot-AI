import Foundation

struct HealthSnapshot: Identifiable, Codable, Equatable {
    var id = UUID()
    var date: Date
    var steps: Int
    var averageHeartRate: Double
    var sleepHours: Double
    var activeEnergyCalories: Double
    var workoutMinutes: Double
    var workoutsCount: Int
    var hrv: Double
    var hydrationLoggedLiters: Double

    var sleepDebtHours: Double {
        max(0, 8.0 - sleepHours)
    }

    var hydrationTargetLiters: Double {
        let activityAdjustment = min(0.9, activeEnergyCalories / 1_000 * 0.45)
        return max(2.0, 2.2 + activityAdjustment)
    }

    var activeEnergyDisplay: String {
        "\(Int(activeEnergyCalories.rounded())) kcal"
    }
}
