import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var isShowingSplash = true
    @Published var isOnboarded: Bool
    @Published var profile: OnboardingProfile?
    @Published var healthSnapshot: HealthSnapshot
    @Published var burnoutPrediction: BurnoutPrediction
    @Published var missions: [Mission]
    @Published var chatMessages: [ChatMessage]
    @Published var weeklyReport: WeeklyReport
    @Published var streakCount: Int
    @Published var isPremiumPreview: Bool
    @Published var sampleDataMode: Bool
    @Published var healthAuthorizationMessage: String

    private let persistence: PersistenceService
    private let sampleDataProvider: SampleDataProvider
    private let healthKitManager: HealthKitManager
    private let burnoutPredictor: BurnoutPredictor
    private let missionService: MissionService
    private let weeklyReportService: WeeklyReportService
    private let aiCoachService: MockAICoachService

    init(persistence: PersistenceService = .shared) {
        let provider = SampleDataProvider()
        let predictor = BurnoutPredictor()
        let reportService = WeeklyReportService()
        let storedProfile = persistence.loadProfile()
        let snapshot = provider.today(profile: storedProfile)
        let prediction = predictor.predict(from: snapshot, profile: storedProfile)
        let storedMissions = persistence.loadMissions(for: Date())
        let recentMissions = persistence.loadRecentMissions(days: 7)

        self.persistence = persistence
        self.sampleDataProvider = provider
        self.healthKitManager = HealthKitManager(sampleDataProvider: provider)
        self.burnoutPredictor = predictor
        self.missionService = MissionService()
        self.weeklyReportService = reportService
        self.aiCoachService = MockAICoachService()
        self.profile = storedProfile
        self.isOnboarded = storedProfile != nil
        self.healthSnapshot = snapshot
        self.burnoutPrediction = prediction
        self.isPremiumPreview = persistence.loadPremiumPreview()
        self.sampleDataMode = persistence.loadSampleDataMode()
        self.missions = storedMissions ?? MissionService().missions(
            for: snapshot,
            prediction: prediction,
            profile: storedProfile,
            premium: persistence.loadPremiumPreview()
        )
        self.chatMessages = persistence.loadChatMessages()
        self.streakCount = persistence.loadStreakCount()
        self.healthAuthorizationMessage = "Not connected"
        self.weeklyReport = reportService.makeReport(
            snapshots: provider.weeklySnapshots(profile: storedProfile),
            missions: recentMissions,
            profile: storedProfile
        )

        if storedMissions == nil {
            persistence.saveMissions(self.missions, for: Date())
        }
    }

    func finishSplash() {
        isShowingSplash = false
    }

    func completeOnboarding(profile newProfile: OnboardingProfile) async {
        profile = newProfile
        isOnboarded = true
        persistence.saveProfile(newProfile)
        await refreshHealthData(forceMissionRefresh: true)
    }

    func requestHealthAuthorization() async -> Bool {
        let granted = await healthKitManager.requestAuthorization()
        healthAuthorizationMessage = healthKitManager.authorizationMessage
        return granted
    }

    func refreshHealthData(forceMissionRefresh: Bool = false) async {
        let snapshot = sampleDataMode
            ? sampleDataProvider.today(profile: profile)
            : await healthKitManager.fetchTodaySnapshot(profile: profile)

        healthSnapshot = snapshot
        burnoutPrediction = burnoutPredictor.predict(from: snapshot, profile: profile)
        loadOrGenerateMissions(force: forceMissionRefresh)
        weeklyReport = weeklyReportService.makeReport(
            snapshots: sampleDataProvider.weeklySnapshots(profile: profile),
            missions: persistence.loadRecentMissions(days: 7),
            profile: profile
        )
    }

    func loadOrGenerateMissions(force: Bool = false) {
        if force == false, let stored = persistence.loadMissions(for: Date()) {
            missions = stored
            return
        }

        missions = missionService.missions(
            for: healthSnapshot,
            prediction: burnoutPrediction,
            profile: profile,
            premium: isPremiumPreview
        )
        persistence.saveMissions(missions, for: Date())
    }

    func regenerateMissions() {
        loadOrGenerateMissions(force: true)
    }

    func toggleMission(_ mission: Mission) {
        guard let index = missions.firstIndex(where: { $0.id == mission.id }) else { return }
        missions[index].isCompleted.toggle()
        persistence.saveMissions(missions, for: Date())
        updateStreakIfNeeded()
        weeklyReport = weeklyReportService.makeReport(
            snapshots: sampleDataProvider.weeklySnapshots(profile: profile),
            missions: persistence.loadRecentMissions(days: 7),
            profile: profile
        )
    }

    func setPremiumPreview(_ enabled: Bool) {
        isPremiumPreview = enabled
        persistence.savePremiumPreview(enabled)
        loadOrGenerateMissions(force: true)
    }

    func setSampleDataMode(_ enabled: Bool) async {
        sampleDataMode = enabled
        persistence.saveSampleDataMode(enabled)
        await refreshHealthData(forceMissionRefresh: true)
    }

    func sendCoachMessage(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }

        let userMessage = ChatMessage(role: .user, text: trimmed, date: Date())
        chatMessages.append(userMessage)
        persistence.saveChatMessages(chatMessages)

        let reply = await aiCoachService.response(
            to: trimmed,
            snapshot: healthSnapshot,
            prediction: burnoutPrediction,
            profile: profile
        )

        chatMessages.append(ChatMessage(role: .coach, text: reply, date: Date()))
        persistence.saveChatMessages(chatMessages)
    }

    func resetOnboardingAndData() {
        persistence.resetAll()
        profile = nil
        isOnboarded = false
        isPremiumPreview = false
        sampleDataMode = false
        streakCount = 0
        healthSnapshot = sampleDataProvider.today(profile: nil)
        burnoutPrediction = burnoutPredictor.predict(from: healthSnapshot, profile: nil)
        missions = missionService.missions(for: healthSnapshot, prediction: burnoutPrediction, profile: nil, premium: false)
        chatMessages = persistence.loadChatMessages()
        weeklyReport = .empty
    }

    private func updateStreakIfNeeded() {
        let requiredCompletions = min(3, missions.count)
        guard missions.filter(\.isCompleted).count >= requiredCompletions else { return }

        let today = Calendar.current.startOfDay(for: Date())
        if let lastDate = persistence.loadLastStreakDate() {
            let last = Calendar.current.startOfDay(for: lastDate)
            guard last != today else { return }
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)
            streakCount = last == yesterday ? streakCount + 1 : 1
        } else {
            streakCount = 1
        }

        persistence.saveStreakCount(streakCount)
        persistence.saveLastStreakDate(today)
    }
}
