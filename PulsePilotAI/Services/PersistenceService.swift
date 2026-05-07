import Foundation

final class PersistenceService {
    static let shared = PersistenceService()

    private let defaults: UserDefaults

    private enum Keys {
        static let profile = "pulsepilot.profile"
        static let premiumPreview = "pulsepilot.premiumPreview"
        static let sampleDataMode = "pulsepilot.sampleDataMode"
        static let streakCount = "pulsepilot.streakCount"
        static let lastStreakDate = "pulsepilot.lastStreakDate"
        static let chatMessages = "pulsepilot.chatMessages"
        static let missionPrefix = "pulsepilot.missions."
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadProfile() -> OnboardingProfile? {
        load(OnboardingProfile.self, key: Keys.profile)
    }

    func saveProfile(_ profile: OnboardingProfile) {
        save(profile, key: Keys.profile)
    }

    func clearProfile() {
        defaults.removeObject(forKey: Keys.profile)
    }

    func loadPremiumPreview() -> Bool {
        defaults.bool(forKey: Keys.premiumPreview)
    }

    func savePremiumPreview(_ enabled: Bool) {
        defaults.set(enabled, forKey: Keys.premiumPreview)
    }

    func loadSampleDataMode() -> Bool {
        if defaults.object(forKey: Keys.sampleDataMode) == nil {
            return false
        }
        return defaults.bool(forKey: Keys.sampleDataMode)
    }

    func saveSampleDataMode(_ enabled: Bool) {
        defaults.set(enabled, forKey: Keys.sampleDataMode)
    }

    func loadMissions(for date: Date) -> [Mission]? {
        load([Mission].self, key: missionKey(for: date))
    }

    func saveMissions(_ missions: [Mission], for date: Date) {
        save(missions, key: missionKey(for: date))
    }

    func loadRecentMissions(days: Int) -> [Mission] {
        (0..<days).flatMap { offset -> [Mission] in
            guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) else {
                return []
            }
            return loadMissions(for: date) ?? []
        }
    }

    func loadStreakCount() -> Int {
        defaults.integer(forKey: Keys.streakCount)
    }

    func saveStreakCount(_ count: Int) {
        defaults.set(count, forKey: Keys.streakCount)
    }

    func loadLastStreakDate() -> Date? {
        defaults.object(forKey: Keys.lastStreakDate) as? Date
    }

    func saveLastStreakDate(_ date: Date) {
        defaults.set(date, forKey: Keys.lastStreakDate)
    }

    func loadChatMessages() -> [ChatMessage] {
        load([ChatMessage].self, key: Keys.chatMessages) ?? [
            ChatMessage(
                role: .coach,
                text: "Good morning. Tell me how you feel and I will adapt today's plan.",
                date: Date()
            )
        ]
    }

    func saveChatMessages(_ messages: [ChatMessage]) {
        save(messages, key: Keys.chatMessages)
    }

    func resetAll() {
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix("pulsepilot.") {
            defaults.removeObject(forKey: key)
        }
    }

    private func missionKey(for date: Date) -> String {
        Keys.missionPrefix + Formatters.dateKey(date)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
