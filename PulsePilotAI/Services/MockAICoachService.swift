import Foundation

struct MockAICoachService {
    func response(
        to input: String,
        snapshot: HealthSnapshot,
        prediction: BurnoutPrediction,
        profile: OnboardingProfile?
    ) async -> String {
        try? await Task.sleep(nanoseconds: 450_000_000)

        let message = input.lowercased()

        // TODO: Replace this mock rule engine with an OpenAI API call.
        // Recommended shape: send the user's message plus a compact health context
        // payload, then stream the model response back into ChatMessage rows.
        if message.contains("tired") || message.contains("exhausted") || message.contains("low energy") {
            return "Let's lower the load today. Keep the walk target, skip hard intervals, drink 500ml in the next hour, and aim for a 20 minute wind-down tonight. Your current recovery score is \(prediction.recoveryScore), so the goal is steadiness."
        }

        if message.contains("slept") || message.contains("sleep") || message.contains("bad night") {
            return "Treat today like a recovery-preserving day. Avoid caffeine after 3 PM, keep training easy, and move bedtime 30 minutes earlier. Your sleep debt is \(Formatters.hours(snapshot.sleepDebtHours)), so small protection matters."
        }

        if message.contains("missed") || message.contains("workout") {
            return "No need to pay it back all at once. Replace the missed workout with a 20 minute brisk walk or mobility block, then continue your normal plan tomorrow."
        }

        if message.contains("stress") || message.contains("anxious") || message.contains("burnout") {
            return "Your burnout risk is \(prediction.level.displayName.lowercased()). Make the next mission tiny: five slow breaths, a short walk, and no extra training intensity today."
        }

        if message.contains("hydrate") || message.contains("water") {
            return "Today's hydration target is \(Formatters.liters(snapshot.hydrationTargetLiters)). Front-load 1L before lunch, then sip with meals so it does not become an evening chore."
        }

        return "For today, I would keep the plan simple: hit your movement mission, front-load hydration, and stop training intensity if your energy drops. Tell me what changed and I can adjust the plan again."
    }
}
