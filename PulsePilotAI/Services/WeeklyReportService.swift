import Foundation

struct WeeklyReportService {
    func makeReport(
        snapshots: [HealthSnapshot],
        missions: [Mission],
        profile: OnboardingProfile?
    ) -> WeeklyReport {
        guard snapshots.isEmpty == false else { return .empty }

        let predictor = BurnoutPredictor()
        let averageSleep = snapshots.map(\.sleepHours).reduce(0, +) / Double(snapshots.count)
        let averageSteps = Int(Double(snapshots.map(\.steps).reduce(0, +)) / Double(snapshots.count))
        let trend = snapshots.map { predictor.predict(from: $0, profile: profile).recoveryScore }
        let completed = missions.filter(\.isCompleted).count
        let daysWithMissions = Dictionary(grouping: missions, by: { Calendar.current.startOfDay(for: $0.createdAt) })
        let daysCompleted = daysWithMissions.values.filter { dayMissions in
            dayMissions.filter(\.isCompleted).count >= min(3, dayMissions.count)
        }.count
        let consistency = min(100, Int((Double(max(daysCompleted, completed > 0 ? 1 : 0)) / 7.0) * 100))

        let summary: String
        if averageSleep < 6.6 {
            summary = "Sleep is the biggest opportunity this week. Pulling bedtime earlier should improve recovery fastest."
        } else if completed >= 12 {
            summary = "Great consistency. Your movement and recovery habits are stacking into a stable rhythm."
        } else if averageSteps < 5_500 {
            summary = "Movement consistency is the next lever. Short walks will lift energy without adding much strain."
        } else {
            summary = "Your week is trending steady. Keep the plan simple and protect the routines already working."
        }

        return WeeklyReport(
            consistencyScore: consistency,
            averageSleepHours: averageSleep,
            averageSteps: averageSteps,
            recoveryTrend: trend,
            completedMissions: completed,
            summary: summary
        )
    }
}
