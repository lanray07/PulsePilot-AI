import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = DashboardViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                recoveryHero
                metricGrid
                energyForecast
                aiPlan
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .background(AppTheme.groupedBackground.ignoresSafeArea())
        .navigationTitle("Today")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    PremiumUpgradeView()
                } label: {
                    Image(systemName: appState.isPremiumPreview ? "crown.fill" : "crown")
                }
                .accessibilityLabel("Premium")
            }
        }
        .refreshable {
            await viewModel.refresh(appState: appState)
        }
        .task {
            await viewModel.refresh(appState: appState)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Formatters.shortDate(Date()))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.secondaryText)

            Text("Your adaptive health plan is ready.")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 8)
    }

    private var recoveryHero: some View {
        NavigationLink {
            RecoveryDetailsView()
        } label: {
            GradientCard(colors: [AppTheme.accent, AppTheme.sky]) {
                HStack(spacing: 18) {
                    ScoreRingView(
                        score: appState.burnoutPrediction.recoveryScore,
                        label: "Recovery",
                        size: 142,
                        tint: AppTheme.color(for: appState.burnoutPrediction.level)
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Recovery Score")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                                .foregroundStyle(AppTheme.secondaryText)
                        }

                        Text(appState.burnoutPrediction.explanation)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        Label("\(appState.burnoutPrediction.level.displayName) burnout risk", systemImage: appState.burnoutPrediction.level.systemImage)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.color(for: appState.burnoutPrediction.level))
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var metricGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            MetricCard(
                title: "Burnout Risk",
                value: appState.burnoutPrediction.level.displayName,
                subtitle: "Score \(appState.burnoutPrediction.score)/100",
                systemImage: "flame.fill",
                tint: AppTheme.color(for: appState.burnoutPrediction.level)
            )

            MetricCard(
                title: "Sleep Debt",
                value: Formatters.hours(appState.healthSnapshot.sleepDebtHours),
                subtitle: "\(Formatters.hours(appState.healthSnapshot.sleepHours)) slept",
                systemImage: "moon.zzz.fill",
                tint: AppTheme.violet
            )

            MetricCard(
                title: "Hydration Target",
                value: Formatters.liters(appState.healthSnapshot.hydrationTargetLiters),
                subtitle: "\(Formatters.liters(appState.healthSnapshot.hydrationLoggedLiters)) logged",
                systemImage: "drop.fill",
                tint: AppTheme.mint
            )

            MetricCard(
                title: "Active Energy",
                value: appState.healthSnapshot.activeEnergyDisplay,
                subtitle: "\(Formatters.number(appState.healthSnapshot.steps)) steps",
                systemImage: "bolt.fill",
                tint: AppTheme.amber
            )
        }
    }

    private var energyForecast: some View {
        let forecast = viewModel.energyForecast(from: appState.healthSnapshot, prediction: appState.burnoutPrediction)

        return GradientCard(colors: [AppTheme.sky, AppTheme.mint]) {
            VStack(alignment: .leading, spacing: 16) {
                Label("Energy Forecast", systemImage: "waveform.path.ecg")
                    .font(.headline)

                HStack(spacing: 12) {
                    ForEach(forecast) { segment in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(segment.period)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.secondaryText)

                            GeometryReader { proxy in
                                VStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(AppTheme.sky.gradient)
                                        .frame(height: max(16, proxy.size.height * CGFloat(segment.score) / 100))
                                }
                            }
                            .frame(height: 76)

                            Text("\(segment.score)")
                                .font(.title3.bold())
                                .monospacedDigit()

                            Text(segment.note)
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private var aiPlan: some View {
        GradientCard(colors: [AppTheme.accent, AppTheme.amber]) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Today's AI Health Plan", systemImage: "sparkles")
                        .font(.headline)
                    Spacer()
                    NavigationLink {
                        CoachChatView()
                    } label: {
                        Text("Coach")
                    }
                    .font(.caption.weight(.bold))
                }

                ForEach(viewModel.healthPlan(snapshot: appState.healthSnapshot, prediction: appState.burnoutPrediction), id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppTheme.accent)
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
