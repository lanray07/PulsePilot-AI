---
name: iOS Xcode validation
about: Track first real Xcode/device validation
title: "Validate PulsePilot AI in Xcode"
labels: ios, validation
assignees: ""
---

## Goal

Validate the app on macOS with Xcode and confirm it builds and runs on simulator and device.

## Checklist

- [ ] Open `PulsePilotAI.xcodeproj` in Xcode.
- [ ] Select the `PulsePilotAI` scheme.
- [ ] Set Apple Developer Team.
- [ ] Confirm HealthKit capability is present.
- [ ] Build on iPhone simulator.
- [ ] Run on physical iPhone.
- [ ] Verify HealthKit permission prompt.
- [ ] Confirm sample data fallback still works.

## Notes

CI builds with code signing disabled. Device validation requires Apple Developer signing.
