# App Store Connect Setup

Use these values when creating the PulsePilot AI app record in App Store Connect.

## New App Modal

- Platforms: `iOS`
- Name: `PulsePilot AI`
- Primary Language: `English (U.K.)`
- Bundle ID: `com.pulsepilot.ai`
- SKU: `PULSEPILOTAI-IOS-2026`
- User Access: `Full Access`

If `com.pulsepilot.ai` is not available in the Bundle ID dropdown, register it first in Apple Developer Certificates, Identifiers & Profiles:

- Identifier type: `App IDs`
- Type: `App`
- Description: `PulsePilot AI`
- Bundle ID: `Explicit`
- Bundle ID value: `com.pulsepilot.ai`
- Capability: `HealthKit`

## Before Clicking Create

Confirm the form shows:

1. iOS selected.
2. App name exactly `PulsePilot AI`.
3. Bundle ID exactly `com.pulsepilot.ai`.
4. SKU exactly `PULSEPILOTAI-IOS-2026`.
5. Full Access selected.

Creating the app record changes the Apple Developer account, so verify the values before submitting.

## After App Record Creation

1. Set app category to Health & Fitness.
2. Fill version metadata using `docs/APP_STORE_METADATA.md`.
3. Add privacy policy URL before submission.
4. Add support URL before submission.
5. Complete App Privacy nutrition labels.
6. Upload screenshots after the app runs in Xcode.
7. Add build from Xcode/TestFlight after signing is configured.
8. Configure subscriptions only after StoreKit products are finalized.
