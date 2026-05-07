import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var step = 0
    @Published var goal: HealthGoal = .improveEnergy
    @Published var fitnessLevel: FitnessLevel = .active
    @Published var selectedWorkoutDays: Set<Weekday> = [.monday, .wednesday, .friday]
    @Published var scheduleIntensity: ScheduleIntensity = .moderate
    @Published var isRequestingHealth = false

    let totalSteps = 5

    var canGoBack: Bool { step > 0 }
    var isLastStep: Bool { step == totalSteps - 1 }

    func next() {
        guard step < totalSteps - 1 else { return }
        step += 1
    }

    func back() {
        guard step > 0 else { return }
        step -= 1
    }

    func toggleWorkoutDay(_ day: Weekday) {
        if selectedWorkoutDays.contains(day), selectedWorkoutDays.count > 1 {
            selectedWorkoutDays.remove(day)
        } else {
            selectedWorkoutDays.insert(day)
        }
    }

    func makeProfile(usesHealthKit: Bool) -> OnboardingProfile {
        OnboardingProfile(
            goal: goal,
            fitnessLevel: fitnessLevel,
            preferredWorkoutDays: selectedWorkoutDays.sorted(),
            scheduleIntensity: scheduleIntensity,
            usesHealthKit: usesHealthKit,
            createdAt: Date()
        )
    }
}
