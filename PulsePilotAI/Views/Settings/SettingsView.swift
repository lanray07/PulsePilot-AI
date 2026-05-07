import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingResetAlert = false
    @State private var isRequestingHealth = false

    var body: some View {
        List {
            profileSection
            dataSection
            premiumSection
            resetSection
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.groupedBackground.ignoresSafeArea())
        .navigationTitle("Settings")
        .alert("Reset PulsePilot AI?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                appState.resetOnboardingAndData()
            }
        } message: {
            Text("This clears onboarding, missions, streaks, chat history, and preview settings.")
        }
    }

    private var profileSection: some View {
        Section("Profile") {
            if let profile = appState.profile {
                SettingsRow(title: "Goal", value: profile.goal.displayName, systemImage: profile.goal.systemImage, tint: AppTheme.accent)
                SettingsRow(title: "Fitness", value: profile.fitnessLevel.displayName, systemImage: "figure.run", tint: AppTheme.sky)
                SettingsRow(title: "Schedule", value: profile.scheduleIntensity.displayName, systemImage: "calendar", tint: AppTheme.amber)
                SettingsRow(title: "Workout days", value: profile.preferredWorkoutDays.map(\.shortName).joined(separator: ", "), systemImage: "checklist", tint: AppTheme.mint)
            }
        }
    }

    private var dataSection: some View {
        Section("Health Data") {
            Toggle(isOn: Binding(
                get: { appState.sampleDataMode },
                set: { enabled in
                    Task { await appState.setSampleDataMode(enabled) }
                }
            )) {
                Label("Sample data mode", systemImage: "waveform.path.ecg")
            }

            Button {
                Task {
                    isRequestingHealth = true
                    let granted = await appState.requestHealthAuthorization()
                    await appState.setSampleDataMode(granted == false)
                    isRequestingHealth = false
                }
            } label: {
                HStack {
                    Label(isRequestingHealth ? "Requesting..." : "Request Apple Health", systemImage: "heart.fill")
                    Spacer()
                    Text(appState.healthAuthorizationMessage)
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .disabled(isRequestingHealth)
        }
    }

    private var premiumSection: some View {
        Section("Premium") {
            NavigationLink {
                PremiumUpgradeView()
            } label: {
                SettingsRow(
                    title: "Premium preview",
                    value: appState.isPremiumPreview ? "Active" : "Free tier",
                    systemImage: "crown.fill",
                    tint: AppTheme.amber
                )
            }

            Toggle(isOn: Binding(
                get: { appState.isPremiumPreview },
                set: { appState.setPremiumPreview($0) }
            )) {
                Label("Enable preview access", systemImage: "sparkles")
            }
        }
    }

    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                Label("Reset app data", systemImage: "trash")
            }
        }
    }
}

private struct SettingsRow: View {
    var title: String
    var value: String
    var systemImage: String
    var tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(Circle().fill(tint.opacity(0.14)))

            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
        }
    }
}
