# Privacy and Safety

PulsePilot AI is an MVP health coaching app. It is not a medical device and does not provide medical diagnosis, treatment, or emergency guidance.

## Health Data

The MVP reads Apple Health data through HealthKit:

- Steps
- Heart rate
- Sleep analysis
- Active energy
- Workouts
- Heart rate variability

If HealthKit data is unavailable, the app uses local sample data so the interface remains functional.

## Local Storage

The MVP stores onboarding selections, mission completion, streaks, premium preview state, sample data mode, and chat messages using `UserDefaults` through `PulsePilotAI/Services/PersistenceService.swift`.

## AI Coach

The current AI coach is a local mock rule engine in `PulsePilotAI/Services/MockAICoachService.swift`. No messages are sent to OpenAI or any external AI service in the MVP.

Before adding a real AI provider:

1. Add a backend proxy so API keys are not embedded in the app.
2. Send the smallest useful health context.
3. Avoid sending directly identifying health data unless the user clearly opts in.
4. Add clear in-app privacy language before networked AI coaching goes live.

## App Store Safety Copy

Recommended in-app copy before production:

> PulsePilot AI provides wellness and fitness recommendations for general informational purposes. It is not medical advice. If you have a medical condition, symptoms, or concerns, speak with a qualified healthcare professional.

## Subscription State

Premium access is currently preview-only. Real subscriptions should use StoreKit entitlement verification before any premium gate is considered production-ready.
