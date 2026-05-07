import Foundation

enum BurnoutLevel: String, Codable {
    case low
    case medium
    case high

    var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    var systemImage: String {
        switch self {
        case .low: "checkmark.seal.fill"
        case .medium: "exclamationmark.triangle.fill"
        case .high: "flame.fill"
        }
    }
}

struct BurnoutPrediction: Codable, Equatable {
    var level: BurnoutLevel
    var score: Int
    var recoveryScore: Int
    var explanation: String
    var factors: [String]

    static let preview = BurnoutPrediction(
        level: .medium,
        score: 48,
        recoveryScore: 72,
        explanation: "Your recovery is workable, but sleep debt and training load deserve a lighter plan today.",
        factors: ["Sleep debt is above 1 hour", "HRV is slightly below baseline"]
    )
}

struct BurnoutPredictor {
    func predict(from snapshot: HealthSnapshot, profile: OnboardingProfile?) -> BurnoutPrediction {
        let baselineHRV = baselineHRV(for: profile?.fitnessLevel ?? .active)
        var risk = 12
        var factors: [String] = []

        if snapshot.sleepHours < 6 {
            risk += 30
            factors.append("Sleep was under 6 hours")
        } else if snapshot.sleepHours < 7 {
            risk += 18
            factors.append("Sleep was below your recovery target")
        }

        if snapshot.hrv < baselineHRV * 0.72 {
            risk += 24
            factors.append("HRV is well below your usual baseline")
        } else if snapshot.hrv < baselineHRV * 0.9 {
            risk += 13
            factors.append("HRV is slightly suppressed")
        }

        if snapshot.workoutMinutes > 50 && snapshot.sleepHours < 7 {
            risk += 18
            factors.append("Recent activity is high while sleep is limited")
        }

        if snapshot.steps > 13_000 {
            risk += 8
            factors.append("Step load is elevated")
        } else if snapshot.steps < 3_500 {
            risk += 7
            factors.append("Low movement may affect energy")
        }

        if profile?.scheduleIntensity == .demanding {
            risk += 8
            factors.append("Your schedule intensity is demanding")
        }

        let boundedRisk = min(100, max(0, risk))
        let level: BurnoutLevel
        if boundedRisk >= 66 {
            level = .high
        } else if boundedRisk >= 38 {
            level = .medium
        } else {
            level = .low
        }

        let recoveryScore = min(100, max(1, 100 - boundedRisk + recoveryBonus(for: snapshot)))
        let explanation = explanation(for: level, snapshot: snapshot, factors: factors)

        return BurnoutPrediction(
            level: level,
            score: boundedRisk,
            recoveryScore: recoveryScore,
            explanation: explanation,
            factors: factors.isEmpty ? ["Sleep, HRV, and activity are in a stable range"] : factors
        )
    }

    private func baselineHRV(for level: FitnessLevel) -> Double {
        switch level {
        case .beginner: 42
        case .active: 52
        case .athlete: 62
        }
    }

    private func recoveryBonus(for snapshot: HealthSnapshot) -> Int {
        var bonus = 0
        if snapshot.sleepHours >= 7.5 { bonus += 6 }
        if snapshot.hrv >= 55 { bonus += 5 }
        if snapshot.hydrationLoggedLiters >= 1.8 { bonus += 3 }
        return bonus
    }

    private func explanation(for level: BurnoutLevel, snapshot: HealthSnapshot, factors: [String]) -> String {
        switch level {
        case .low:
            return "Your recovery markers look stable. A normal training day should be fine if energy feels good."
        case .medium:
            return "You have a few stress signals today. Keep intensity controlled and prioritize hydration and wind-down."
        case .high:
            return "Your body is showing strain. A recovery-first day is smarter than forcing a hard workout."
        }
    }
}
