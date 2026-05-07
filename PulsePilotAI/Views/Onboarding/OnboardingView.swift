import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    pageContent
                }
                .padding(.horizontal, 22)
                .padding(.top, 28)
                .padding(.bottom, 32)
            }

            if viewModel.isLastStep == false {
                controls
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    withAnimation(.smooth) {
                        viewModel.back()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(AppTheme.elevatedBackground))
                }
                .opacity(viewModel.canGoBack ? 1 : 0)
                .disabled(viewModel.canGoBack == false)

                Spacer()

                Text("PulsePilot AI")
                    .font(.headline.weight(.bold))

                Spacer()

                Color.clear.frame(width: 42, height: 42)
            }

            ProgressView(value: Double(viewModel.step + 1), total: Double(viewModel.totalSteps))
                .tint(AppTheme.accent)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var pageContent: some View {
        switch viewModel.step {
        case 0:
            introBlock(title: "What are we optimizing?", subtitle: "Pick the outcome you want your daily plan to bias toward.")
            VStack(spacing: 12) {
                ForEach(HealthGoal.allCases) { goal in
                    OnboardingOptionCard(
                        title: goal.displayName,
                        subtitle: goal.subtitle,
                        systemImage: goal.systemImage,
                        isSelected: viewModel.goal == goal,
                        tint: tint(for: goal)
                    ) {
                        viewModel.goal = goal
                    }
                }
            }

        case 1:
            introBlock(title: "Fitness level", subtitle: "This sets sensible mission targets and training recovery assumptions.")
            VStack(spacing: 12) {
                ForEach(FitnessLevel.allCases) { level in
                    OnboardingOptionCard(
                        title: level.displayName,
                        subtitle: level.detail,
                        systemImage: level == .beginner ? "figure.walk" : level == .active ? "figure.run" : "bolt.fill",
                        isSelected: viewModel.fitnessLevel == level,
                        tint: AppTheme.sky
                    ) {
                        viewModel.fitnessLevel = level
                    }
                }
            }

        case 2:
            introBlock(title: "Workout days", subtitle: "Choose the days PulsePilot should expect planned training.")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                ForEach(Weekday.allCases) { day in
                    Button {
                        viewModel.toggleWorkoutDay(day)
                    } label: {
                        Text(day.shortName)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(viewModel.selectedWorkoutDays.contains(day) ? .white : AppTheme.primaryText)
                            .frame(maxWidth: .infinity, minHeight: 58)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(viewModel.selectedWorkoutDays.contains(day) ? AppTheme.accent : AppTheme.elevatedBackground)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

        case 3:
            introBlock(title: "Daily schedule", subtitle: "High mental load changes how aggressive recovery recommendations should be.")
            VStack(spacing: 12) {
                ForEach(ScheduleIntensity.allCases) { intensity in
                    OnboardingOptionCard(
                        title: intensity.displayName,
                        subtitle: intensity.detail,
                        systemImage: intensity == .light ? "sun.min.fill" : intensity == .moderate ? "calendar" : "briefcase.fill",
                        isSelected: viewModel.scheduleIntensity == intensity,
                        tint: AppTheme.amber
                    ) {
                        viewModel.scheduleIntensity = intensity
                    }
                }
            }

        default:
            introBlock(title: "Connect Apple Health", subtitle: "PulsePilot reads your core health signals and falls back to sample data whenever HealthKit has gaps.")
            GradientCard(colors: [AppTheme.accent, AppTheme.sky]) {
                VStack(alignment: .leading, spacing: 18) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(AppTheme.accent)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Health permissions")
                            .font(.title2.bold())

                        Text("Steps, heart rate, sleep, active energy, workouts, and HRV are used to calculate recovery and burnout risk.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: 12) {
                        Button {
                            Task { await finishOnboarding(requestHealth: true) }
                        } label: {
                            Label(viewModel.isRequestingHealth ? "Connecting..." : "Connect Apple Health", systemImage: "heart.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.accent)
                        .disabled(viewModel.isRequestingHealth)

                        Button {
                            Task { await finishOnboarding(requestHealth: false) }
                        } label: {
                            Text("Continue with Sample Data")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(viewModel.isRequestingHealth)
                    }
                }
            }
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.smooth) {
                    viewModel.next()
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .background(.ultraThinMaterial)
    }

    private func introBlock(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(AppTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func finishOnboarding(requestHealth: Bool) async {
        viewModel.isRequestingHealth = true
        let granted = requestHealth ? await appState.requestHealthAuthorization() : false
        await appState.setSampleDataMode(granted == false)
        let profile = viewModel.makeProfile(usesHealthKit: granted)
        await appState.completeOnboarding(profile: profile)
        viewModel.isRequestingHealth = false
    }

    private func tint(for goal: HealthGoal) -> Color {
        switch goal {
        case .loseWeight: AppTheme.coral
        case .improveEnergy: AppTheme.accent
        case .reduceStress: AppTheme.mint
        case .buildFitness: AppTheme.sky
        case .sleepBetter: AppTheme.violet
        }
    }
}

private struct OnboardingOptionCard: View {
    var title: String
    var subtitle: String
    var systemImage: String
    var isSelected: Bool
    var tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isSelected ? .white : tint)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(isSelected ? tint : tint.opacity(0.14)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isSelected ? tint : AppTheme.secondaryText.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppTheme.elevatedBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(isSelected ? tint.opacity(0.55) : Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
