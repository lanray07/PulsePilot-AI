---
name: StoreKit subscriptions
about: Replace premium preview with real subscriptions
title: "Implement StoreKit subscriptions"
labels: monetization, storekit
assignees: ""
---

## Goal

Replace preview-only premium access with StoreKit subscriptions.

## Checklist

- [ ] Create monthly and yearly subscription products.
- [ ] Add product loading.
- [ ] Add purchase flow.
- [ ] Add restore purchases.
- [ ] Verify current entitlements.
- [ ] Replace `UserDefaults` premium preview state with entitlement state.
- [ ] Test sandbox purchases.

## Current files

- `PulsePilotAI/Views/Premium/PremiumUpgradeView.swift`
- `PulsePilotAI/App/AppState.swift`
- `PulsePilotAI/Services/PersistenceService.swift`
