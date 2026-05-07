import Foundation

enum HealthGoal: String, CaseIterable, Codable, Identifiable {
    case loseWeight
    case improveEnergy
    case reduceStress
    case buildFitness
    case sleepBetter

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .loseWeight: "Lose weight"
        case .improveEnergy: "Improve energy"
        case .reduceStress: "Reduce stress"
        case .buildFitness: "Build fitness"
        case .sleepBetter: "Sleep better"
        }
    }

    var subtitle: String {
        switch self {
        case .loseWeight: "Gentle calorie burn, movement, and consistency."
        case .improveEnergy: "Balance sleep, recovery, hydration, and movement."
        case .reduceStress: "Protect recovery and build calmer routines."
        case .buildFitness: "Progress workouts without overreaching."
        case .sleepBetter: "Improve sleep timing, debt, and wind-down habits."
        }
    }

    var systemImage: String {
        switch self {
        case .loseWeight: "flame.fill"
        case .improveEnergy: "bolt.heart.fill"
        case .reduceStress: "wind"
        case .buildFitness: "figure.run"
        case .sleepBetter: "moon.stars.fill"
        }
    }
}

enum FitnessLevel: String, CaseIterable, Codable, Identifiable {
    case beginner
    case active
    case athlete

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beginner: "Beginner"
        case .active: "Active"
        case .athlete: "Athlete"
        }
    }

    var detail: String {
        switch self {
        case .beginner: "Building a steady routine"
        case .active: "Training a few days each week"
        case .athlete: "High training load or performance goals"
        }
    }
}

enum ScheduleIntensity: String, CaseIterable, Codable, Identifiable {
    case light
    case moderate
    case demanding

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .light: "Light"
        case .moderate: "Moderate"
        case .demanding: "Demanding"
        }
    }

    var detail: String {
        switch self {
        case .light: "Plenty of recovery windows"
        case .moderate: "Some busy patches"
        case .demanding: "Long days and high mental load"
        }
    }
}

enum Weekday: Int, CaseIterable, Codable, Identifiable, Comparable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .monday: "Mon"
        case .tuesday: "Tue"
        case .wednesday: "Wed"
        case .thursday: "Thu"
        case .friday: "Fri"
        case .saturday: "Sat"
        case .sunday: "Sun"
        }
    }

    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct OnboardingProfile: Codable, Equatable {
    var goal: HealthGoal
    var fitnessLevel: FitnessLevel
    var preferredWorkoutDays: [Weekday]
    var scheduleIntensity: ScheduleIntensity
    var usesHealthKit: Bool
    var createdAt: Date

    static let preview = OnboardingProfile(
        goal: .improveEnergy,
        fitnessLevel: .active,
        preferredWorkoutDays: [.monday, .wednesday, .friday],
        scheduleIntensity: .moderate,
        usesHealthKit: false,
        createdAt: Date()
    )
}
