import Foundation

struct SampleDataProvider {
    func today(profile: OnboardingProfile?) -> HealthSnapshot {
        snapshot(for: Date(), profile: profile)
    }

    func weeklySnapshots(profile: OnboardingProfile?) -> [HealthSnapshot] {
        (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -6 + offset, to: Date())
        }
        .map { snapshot(for: $0, profile: profile) }
    }

    func snapshot(for date: Date, profile: OnboardingProfile?) -> HealthSnapshot {
        let seed = daySeed(for: date)
        let wave = Double((seed % 9) - 4)
        let level = profile?.fitnessLevel ?? .active
        let intensity = profile?.scheduleIntensity ?? .moderate
        let goal = profile?.goal ?? .improveEnergy

        let baseSteps: Int
        switch level {
        case .beginner:
            baseSteps = 5_800
        case .active:
            baseSteps = 8_200
        case .athlete:
            baseSteps = 10_800
        }

        let goalStepAdjustment: Int
        switch goal {
        case .loseWeight, .buildFitness:
            goalStepAdjustment = 900
        case .reduceStress, .sleepBetter:
            goalStepAdjustment = -350
        case .improveEnergy:
            goalStepAdjustment = 250
        }

        let sleepPressure: Double
        switch intensity {
        case .light:
            sleepPressure = 0.15
        case .moderate:
            sleepPressure = -0.05
        case .demanding:
            sleepPressure = -0.45
        }

        let steps = max(2_800, baseSteps + goalStepAdjustment + Int(wave * 420))
        let sleep = max(5.4, min(8.8, 7.25 + sleepPressure + wave * 0.13))
        let activeEnergy = max(180, Double(steps) * 0.045 + Double(level.rawValue.count * 16) + wave * 18)
        let workoutMinutes = workoutMinutes(for: date, profile: profile, seed: seed)
        let hrv = max(24, min(82, 49 + wave * 2.4 + sleepPressure * 12 - (workoutMinutes > 45 ? 4 : 0)))
        let heartRate = max(58, min(86, 70 - (hrv - 45) * 0.12 + (sleep < 6.5 ? 4 : 0)))

        return HealthSnapshot(
            date: date,
            steps: steps,
            averageHeartRate: heartRate,
            sleepHours: sleep,
            activeEnergyCalories: activeEnergy,
            workoutMinutes: workoutMinutes,
            workoutsCount: workoutMinutes > 0 ? 1 : 0,
            hrv: hrv,
            hydrationLoggedLiters: max(0.4, min(2.7, 1.4 + wave * 0.12))
        )
    }

    private func workoutMinutes(for date: Date, profile: OnboardingProfile?, seed: Int) -> Double {
        let weekday = weekday(for: date)
        guard profile?.preferredWorkoutDays.contains(weekday) ?? [Weekday.monday, .wednesday, .friday].contains(weekday) else {
            return seed.isMultiple(of: 5) ? 18 : 0
        }

        switch profile?.fitnessLevel ?? .active {
        case .beginner:
            return 24 + Double(seed % 9)
        case .active:
            return 36 + Double(seed % 16)
        case .athlete:
            return 52 + Double(seed % 22)
        }
    }

    private func weekday(for date: Date) -> Weekday {
        let calendarWeekday = Calendar.current.component(.weekday, from: date)
        let mondayBased = calendarWeekday == 1 ? 7 : calendarWeekday - 1
        return Weekday(rawValue: mondayBased) ?? .monday
    }

    private func daySeed(for date: Date) -> Int {
        Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 1
    }
}
