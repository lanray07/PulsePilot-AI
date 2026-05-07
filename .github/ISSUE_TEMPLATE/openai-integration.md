---
name: OpenAI integration
about: Replace the mock coach with a production AI service
title: "Add OpenAI-backed AI Coach"
labels: ai, backend
assignees: ""
---

## Goal

Replace `MockAICoachService` with a production-ready AI coach integration.

## Checklist

- [ ] Add backend proxy for OpenAI calls.
- [ ] Define compact health context payload.
- [ ] Keep API keys out of the iOS app.
- [ ] Add loading, error, and retry states.
- [ ] Add user-facing privacy copy for networked AI coaching.
- [ ] Consider streaming responses into `ChatMessage`.

## Current file

`PulsePilotAI/Services/MockAICoachService.swift`
