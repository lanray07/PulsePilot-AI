import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    @Published private(set) var authorizationMessage = "Not connected"
    @Published private(set) var isHealthDataAvailable: Bool

    private let healthStore: HKHealthStore?
    private let sampleDataProvider: SampleDataProvider

    init(sampleDataProvider: SampleDataProvider) {
        self.sampleDataProvider = sampleDataProvider
        self.isHealthDataAvailable = HKHealthStore.isHealthDataAvailable()
        self.healthStore = HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
    }

    func requestAuthorization() async -> Bool {
        guard isHealthDataAvailable, let healthStore else {
            authorizationMessage = "HealthKit unavailable, using sample data"
            return false
        }

        do {
            let success: Bool = try await withCheckedThrowingContinuation { continuation in
                healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: success)
                    }
                }
            }

            authorizationMessage = success ? "Apple Health connected" : "Permission not granted"
            return success
        } catch {
            authorizationMessage = "Permission failed, using sample data"
            return false
        }
    }

    func fetchTodaySnapshot(profile: OnboardingProfile?) async -> HealthSnapshot {
        guard isHealthDataAvailable, healthStore != nil else {
            return sampleDataProvider.today(profile: profile)
        }

        let sample = sampleDataProvider.today(profile: profile)
        let endDate = Date()
        let startDate = Calendar.current.startOfDay(for: endDate)

        async let steps = quantitySum(.stepCount, unit: .count(), from: startDate, to: endDate)
        async let activeEnergy = quantitySum(.activeEnergyBurned, unit: .kilocalorie(), from: startDate, to: endDate)
        async let heartRate = quantityAverage(.heartRate, unit: HKUnit.count().unitDivided(by: .minute()), from: startDate, to: endDate)
        async let hrv = quantityAverage(.heartRateVariabilitySDNN, unit: HKUnit.secondUnit(with: .milli), from: startDate, to: endDate)
        async let sleep = sleepHours(from: startDate, to: endDate)
        async let workoutSummary = workoutMinutes(from: startDate, to: endDate)

        let values = await (
            steps,
            activeEnergy,
            heartRate,
            hrv,
            sleep,
            workoutSummary
        )

        return HealthSnapshot(
            date: endDate,
            steps: values.0 > 0 ? Int(values.0.rounded()) : sample.steps,
            averageHeartRate: values.2 > 0 ? values.2 : sample.averageHeartRate,
            sleepHours: values.4 > 0 ? values.4 : sample.sleepHours,
            activeEnergyCalories: values.1 > 0 ? values.1 : sample.activeEnergyCalories,
            workoutMinutes: values.5.minutes > 0 ? values.5.minutes : sample.workoutMinutes,
            workoutsCount: values.5.count > 0 ? values.5.count : sample.workoutsCount,
            hrv: values.3 > 0 ? values.3 : sample.hrv,
            hydrationLoggedLiters: sample.hydrationLoggedLiters
        )
    }

    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        [
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis),
            HKObjectType.workoutType()
        ].compactMap { $0 }.forEach { types.insert($0) }
        return types
    }

    private func quantitySum(
        _ identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        from startDate: Date,
        to endDate: Date
    ) async -> Double {
        guard let healthStore, let type = HKQuantityType.quantityType(forIdentifier: identifier) else {
            return 0
        }

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, _ in
                continuation.resume(returning: statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            healthStore.execute(query)
        }
    }

    private func quantityAverage(
        _ identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        from startDate: Date,
        to endDate: Date
    ) async -> Double {
        guard let healthStore, let type = HKQuantityType.quantityType(forIdentifier: identifier) else {
            return 0
        }

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage) { _, statistics, _ in
                continuation.resume(returning: statistics?.averageQuantity()?.doubleValue(for: unit) ?? 0)
            }
            healthStore.execute(query)
        }
    }

    private func sleepHours(from startDate: Date, to endDate: Date) async -> Double {
        guard let healthStore, let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            return 0
        }

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            let asleepValues: Set<Int> = [
                HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                HKCategoryValueSleepAnalysis.asleepREM.rawValue
            ]

            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                let hours = (samples as? [HKCategorySample] ?? [])
                    .filter { asleepValues.contains($0.value) }
                    .reduce(0.0) { total, sample in
                        total + sample.endDate.timeIntervalSince(sample.startDate) / 3_600
                    }
                continuation.resume(returning: hours)
            }
            healthStore.execute(query)
        }
    }

    private func workoutMinutes(from startDate: Date, to endDate: Date) async -> (minutes: Double, count: Int) {
        guard let healthStore else { return (0, 0) }

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                let workouts = samples as? [HKWorkout] ?? []
                let minutes = workouts.reduce(0.0) { $0 + $1.duration / 60 }
                continuation.resume(returning: (minutes, workouts.count))
            }
            healthStore.execute(query)
        }
    }
}
