import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var isRefreshing = false

    func refresh(appState: AppState) async {
        isRefreshing = true
        await appState.refreshHealthData()
        isRefreshing = false
    }

    func energyForecast(from snapshot: HealthSnapshot, prediction: BurnoutPrediction) -> [EnergyForecastSegment] {
        let base = max(28, prediction.recoveryScore)
        let sleepDrag = Int(snapshot.sleepDebtHours * 7)
        return [
            EnergyForecastSegment(period: "Morning", score: min(100, base + 8), note: snapshot.sleepHours < 7 ? "Ease in" : "Best focus"),
            EnergyForecastSegment(period: "Afternoon", score: min(100, max(20, base - sleepDrag)), note: "Hydrate early"),
            EnergyForecastSegment(period: "Evening", score: min(100, max(18, base - 12 - sleepDrag)), note: "Wind down")
        ]
    }

    func healthPlan(snapshot: HealthSnapshot, prediction: BurnoutPrediction) -> [String] {
        var plan = [
            "Hydration target: \(Formatters.liters(snapshot.hydrationTargetLiters))",
            "Movement target: \(snapshot.steps < 5_000 ? "easy walk" : "steady steps")",
            "Sleep debt: \(Formatters.hours(snapshot.sleepDebtHours))"
        ]

        switch prediction.level {
        case .low:
            plan.append("Training: normal intensity if you feel good")
        case .medium:
            plan.append("Training: keep effort controlled")
        case .high:
            plan.append("Training: recovery or mobility only")
        }

        return plan
    }
}
