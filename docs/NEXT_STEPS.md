# Next Steps

These are the remaining production steps after the local MVP scaffold.

## Xcode Validation

1. Open `PulsePilotAI.xcodeproj` on macOS with Xcode.
2. Select the `PulsePilotAI` scheme.
3. Set your Apple Developer Team under Signing & Capabilities.
4. Build on an iPhone simulator.
5. Run on a physical iPhone for HealthKit permission and real Apple Health data testing.

## GitHub Actions

The repository includes `.github/workflows/ios-ci.yml`, which builds the app on `macos-latest` for the iOS Simulator with code signing disabled.

If CI fails because the runner image changes its installed Xcode version, pin the workflow to the Xcode version you want by adding an `xcode-select` step.

## Apple Developer Setup

1. Register the app bundle identifier, currently `com.pulsepilot.ai`.
2. Enable HealthKit for the App ID.
3. Add the HealthKit capability in Xcode if your local signing settings require it.
4. Create development and distribution provisioning profiles.
5. Test HealthKit on a real device because simulator health data is limited.

## OpenAI Integration

Replace the mock coach rule engine in `PulsePilotAI/Services/MockAICoachService.swift`.

Recommended approach:

1. Create a dedicated `OpenAICoachService`.
2. Send a compact health context payload: recovery score, burnout level, sleep debt, steps, hydration target, missions, and the user's message.
3. Stream or append the response into `ChatMessage`.
4. Keep API keys out of the app binary. Use a backend proxy for production.

## StoreKit Subscriptions

Replace the premium preview toggle in `PulsePilotAI/Views/Premium/PremiumUpgradeView.swift`.

Recommended approach:

1. Add StoreKit products for monthly and yearly subscriptions.
2. Create a subscription service that loads products, purchases, restores, and verifies entitlements.
3. Move premium state out of `UserDefaults` preview logic and into verified StoreKit entitlement state.
4. Keep the existing UI as the upgrade surface.

## HealthKit Expansion

The MVP reads steps, heart rate, sleep, active energy, workouts, and HRV. Future versions can add resting heart rate, respiratory rate, wrist temperature, mindful minutes, hydration writes, and workout route summaries.
