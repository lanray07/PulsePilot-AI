# Windows App Store Upload Path

This repo can upload PulsePilot AI to App Store Connect from GitHub Actions, so day-to-day development can stay on Windows.

## Why this path

Apple still requires iOS apps to be archived and signed with Apple's toolchain before App Store submission. GitHub Actions provides a hosted macOS runner that can run Xcode for us.

## One-time Apple setup

1. Confirm the Bundle ID `com.pulsepilot.ai` exists in Apple Developer.
2. Confirm the Bundle ID has the **HealthKit** capability enabled.
3. Confirm the App Store Connect app record exists for **PulsePilot AI**.
4. In App Store Connect, create an API key:
   - Go to **Users and Access**.
   - Open **Integrations** / **App Store Connect API**.
   - Create a key with access to manage builds.
   - Download the `.p8` key file immediately; Apple only allows downloading it once.
5. Find your Apple Developer **Team ID** in Apple Developer account membership details.

## GitHub secrets to add

Add these at:

`GitHub repo -> Settings -> Secrets and variables -> Actions -> New repository secret`

| Secret | Value |
| --- | --- |
| `APPLE_TEAM_ID` | Your Apple Developer Team ID |
| `APP_STORE_CONNECT_KEY_ID` | The API key ID from App Store Connect |
| `APP_STORE_CONNECT_ISSUER_ID` | The issuer ID from App Store Connect API page |
| `APP_STORE_CONNECT_API_KEY` | Full text contents of the downloaded `.p8` file |

## Run the upload

1. Go to **GitHub -> PulsePilot-AI -> Actions**.
2. Select **App Store Upload**.
3. Click **Run workflow**.
4. Leave `build_number` blank unless you need a specific number.
5. Wait for the workflow to finish.

If it succeeds, Apple still needs to process the uploaded build before it appears in App Store Connect. This can take a few minutes.

If it fails, open the run and download the `PulsePilotAI-xcode-logs` artifact. The `archive.log` file contains the real Xcode signing or archive error.

## After upload

1. Open **App Store Connect -> PulsePilot AI -> Distribution -> 1.0 Prepare for Submission**.
2. In the **Build** section, select the uploaded build.
3. Save the version page.
4. Submit only after screenshots, privacy, age rating, medical-device declaration, pricing, and review information are complete.

## Common failure

If signing fails with a HealthKit or provisioning-profile error, check that `com.pulsepilot.ai` has HealthKit enabled in Apple Developer and that the App Store Connect API key has enough access for signing and build upload.
