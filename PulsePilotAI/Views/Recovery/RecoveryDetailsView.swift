import SwiftUI

struct RecoveryDetailsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero
                metrics
                factorList
                trend
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .background(AppTheme.groupedBackground.ignoresSafeArea())
        .navigationTitle("Recovery")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        GradientCard(colors: [AppTheme.color(for: appState.burnoutPrediction.level), AppTheme.sky]) {
            VStack(spacing: 18) {
                ScoreRingView(
                    score: appState.burnoutPrediction.recoveryScore,
                    label: "Recovery",
                    size: 178,
                    tint: AppTheme.color(for: appState.burnoutPrediction.level)
                )

                VStack(spacing: 8) {
                    Text("\(appState.burnoutPrediction.level.displayName) burnout risk")
                        .font(.title2.bold())

                    Text(appState.burnoutPrediction.explanation)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 8)
    }

    private var metrics: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            InsightPill(title: "Sleep", value: Formatters.hours(appState.healthSnapshot.sleepHours), tint: AppTheme.violet)
            InsightPill(title: "HRV", value: "\(Int(appState.healthSnapshot.hrv)) ms", tint: AppTheme.accent)
            InsightPill(title: "Steps", value: Formatters.number(appState.healthSnapshot.steps), tint: AppTheme.sky)
            InsightPill(title: "Workouts", value: "\(Int(appState.healthSnapshot.workoutMinutes)) min", tint: AppTheme.coral)
        }
    }

    private var factorList: some View {
        GradientCard(colors: [AppTheme.amber, AppTheme.accent]) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Why this score")
                    .font(.headline)

                ForEach(appState.burnoutPrediction.factors, id: \.self) { factor in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundStyle(AppTheme.color(for: appState.burnoutPrediction.level))
                        Text(factor)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var trend: some View {
        GradientCard(colors: [AppTheme.sky, AppTheme.violet]) {
            VStack(alignment: .leading, spacing: 16) {
                Text("7-day recovery trend")
                    .font(.headline)

                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(appState.weeklyReport.recoveryTrend.enumerated()), id: \.offset) { _, value in
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(value >= 70 ? AppTheme.accent : value >= 50 ? AppTheme.amber : AppTheme.coral)
                            .frame(height: CGFloat(max(24, value)))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 110)
            }
        }
    }
}
