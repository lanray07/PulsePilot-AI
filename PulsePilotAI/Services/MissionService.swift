import Foundation

struct MissionService {
    func missions(
        for snapshot: HealthSnapshot,
        prediction: BurnoutPrediction,
        profile: OnboardingProfile?,
        premium: Bool
    ) -> [Mission] {
        var missions: [Mission] = []
        let today = Date()
        let stepTarget = stepTarget(for: snapshot, prediction: prediction, profile: profile)

        missions.append(Mission(
            title: "Walk \(stepTarget.formatted()) steps",
            subtitle: prediction.level == .high ? "Keep it gentle and split it into short walks." : "A steady movement target for better energy.",
            category: .movement,
            targetValue: Double(stepTarget),
            unit: "steps",
            isCompleted: false,
            createdAt: today
        ))

        missions.append(Mission(
            title: "Drink 1L before lunch",
            subtitle: "Aim for \(Formatters.liters(snapshot.hydrationTargetLiters)) today.",
            category: .hydration,
            targetValue: 1.0,
            unit: "L",
            isCompleted: false,
            createdAt: today
        ))

        if snapshot.sleepDebtHours > 1 {
            missions.append(Mission(
                title: "Protect a 30 min wind-down",
                subtitle: "Your sleep debt is \(Formatters.hours(snapshot.sleepDebtHours)). Keep the evening simple.",
                category: .sleep,
                targetValue: 30,
                unit: "min",
                isCompleted: false,
                createdAt: today
            ))
        } else {
            missions.append(Mission(
                title: "Stretch for 8 minutes",
                subtitle: "Open hips, back, and calves to lower recovery load.",
                category: .recovery,
                targetValue: 8,
                unit: "min",
                isCompleted: false,
                createdAt: today
            ))
        }

        if prediction.level != .low {
            missions.append(Mission(
                title: "Avoid caffeine after 3 PM",
                subtitle: "Give tonight's sleep pressure a clean runway.",
                category: .nutrition,
                targetValue: nil,
                unit: nil,
                isCompleted: false,
                createdAt: today
            ))
        } else if isWorkoutDay(profile: profile, date: today) {
            missions.append(Mission(
                title: workoutMissionTitle(for: profile),
                subtitle: "Keep effort at a level you could repeat tomorrow.",
                category: .movement,
                targetValue: 30,
                unit: "min",
                isCompleted: false,
                createdAt: today
            ))
        }

        missions.append(Mission(
            title: "Take 5 calm breaths",
            subtitle: "Use this as a reset before the busiest part of your day.",
            category: .mindfulness,
            targetValue: 5,
            unit: "breaths",
            isCompleted: false,
            createdAt: today
        ))

        let limit = premium ? 5 : 3
        return Array(missions.prefix(limit))
    }

    private func stepTarget(for snapshot: HealthSnapshot, prediction: BurnoutPrediction, profile: OnboardingProfile?) -> Int {
        let base: Int
        switch profile?.fitnessLevel ?? .active {
        case .beginner:
            base = 5_500
        case .active:
            base = 7_500
        case .athlete:
            base = 9_500
        }

        let adjusted: Int
        switch prediction.level {
        case .low:
            adjusted = base + 700
        case .medium:
            adjusted = base
        case .high:
            adjusted = max(4_000, base - 1_800)
        }

        return min(12_000, max(4_000, adjusted))
    }

    private func workoutMissionTitle(for profile: OnboardingProfile?) -> String {
        switch profile?.goal ?? .improveEnergy {
        case .loseWeight: "Do 30 minutes zone 2"
        case .improveEnergy: "Do a 25 minute energizer"
        case .reduceStress: "Do a light mobility session"
        case .buildFitness: "Complete today's workout"
        case .sleepBetter: "Finish movement before dinner"
        }
    }

    private func isWorkoutDay(profile: OnboardingProfile?, date: Date) -> Bool {
        let calendarWeekday = Calendar.current.component(.weekday, from: date)
        let mondayBased = calendarWeekday == 1 ? 7 : calendarWeekday - 1
        let weekday = Weekday(rawValue: mondayBased) ?? .monday
        return profile?.preferredWorkoutDays.contains(weekday) ?? true
    }
}
