# PulsePilot AI

[![iOS CI](https://github.com/lanray07/PulsePilot-AI/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/lanray07/PulsePilot-AI/actions/workflows/ios-ci.yml)

PulsePilot AI is an adaptive SwiftUI health coach MVP for iPhone. It uses Apple Health and Apple Watch-style signals to generate daily recovery, fitness, sleep, hydration, energy, burnout, and mission recommendations.

## MVP Features

- Onboarding for health goal, fitness level, workout days, schedule intensity, and Apple Health permissions.
- Dashboard with recovery score, energy forecast, burnout risk, sleep debt, hydration target, and today's AI health plan.
- Daily missions with completion tracking and persisted streaks.
- AI coach chat with a mock response system ready for OpenAI integration.
- HealthKit manager reading steps, heart rate, sleep, active energy, workouts, and HRV.
- Sample data fallback so the app works in simulator or without HealthKit data.
- Burnout predictor using sleep, HRV, steps, and activity load.
- Weekly report with consistency, average sleep, average steps, recovery trend, and completed missions.
- Premium upgrade screen with placeholder pricing and StoreKit integration comments.
- Settings screen for profile, HealthKit/sample data, premium preview, and reset controls.

## Run In Xcode

1. Open `PulsePilotAI.xcodeproj` on a Mac with Xcode.
2. Select the `PulsePilotAI` scheme.
3. Choose an iPhone simulator or a physical iPhone.
4. For real HealthKit testing, set your Apple Developer Team in Signing & Capabilities.
5. Run the app. If HealthKit data is unavailable, PulsePilot AI automatically uses sample data.

## Key Files

- HealthKit: `PulsePilotAI/Services/HealthKitManager.swift`
- Sample data: `PulsePilotAI/Services/SampleDataProvider.swift`
- Burnout scoring: `PulsePilotAI/Services/BurnoutPredictor.swift`
- Mission generation: `PulsePilotAI/Services/MissionService.swift`
- Persistence: `PulsePilotAI/Services/PersistenceService.swift`
- Mock AI coach: `PulsePilotAI/Services/MockAICoachService.swift`
- Premium placeholder: `PulsePilotAI/Views/Premium/PremiumUpgradeView.swift`

## Future Integrations

Add OpenAI API integration in `MockAICoachService.swift`, replacing the local rule-based response code with a request that sends the user message and compact health context.

Add StoreKit subscriptions in `PremiumUpgradeView.swift` and centralize entitlement state in `AppState.swift` or a dedicated subscription service.

## Validation Notes

This workspace is Windows-based. Swift 6.3.1 and the Visual Studio/MSVC dependencies are installed, but iOS SwiftUI and HealthKit builds require Xcode on macOS. Local validation performed here checks project membership and plist/asset/scheme parsing.

See `docs/NEXT_STEPS.md` for the remaining Xcode, Apple Developer, OpenAI, StoreKit, and HealthKit production steps.
