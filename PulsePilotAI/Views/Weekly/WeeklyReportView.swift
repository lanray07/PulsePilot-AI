import SwiftUI

struct WeeklyReportView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = WeeklyReportViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                summary
                statsGrid
                recoveryTrend
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .background(AppTheme.groupedBackground.ignoresSafeArea())
        .navigationTitle("Weekly Report")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if appState.isPremiumPreview == false {
                    NavigationLink {
                        PremiumUpgradeView()
                    } label: {
                        Image(systemName: "lock.fill")
                    }
                    .accessibilityLabel("Unlock weekly reports")
                }
            }
        }
        .refreshable {
            await viewModel.refresh(appState: appState)
        }
    }

    private var summary: some View {
        GradientCard(colors: [AppTheme.accent, AppTheme.sky]) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center, spacing: 16) {
                    ScoreRingView(
                        score: appState.weeklyReport.consistencyScore,
                        label: "Consistency",
                        size: 124,
                        tint: AppTheme.accent
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weekly Summary")
                            .font(.title3.bold())

                        Text(appState.weeklyReport.summary)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if appState.isPremiumPreview == false {
                    Button {
                        appState.setPremiumPreview(true)
                    } label: {
                        Label("Preview Premium Report", systemImage: "crown.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                }
            }
        }
        .padding(.top, 8)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            InsightPill(title: "Avg Sleep", value: Formatters.hours(appState.weeklyReport.averageSleepHours), tint: AppTheme.violet)
            InsightPill(title: "Avg Steps", value: Formatters.number(appState.weeklyReport.averageSteps), tint: AppTheme.sky)
            InsightPill(title: "Completed", value: "\(appState.weeklyReport.completedMissions)", tint: AppTheme.accent)
            InsightPill(title: "Recovery", value: trendDirection, tint: AppTheme.amber)
        }
    }

    private var recoveryTrend: some View {
        GradientCard(colors: [AppTheme.violet, AppTheme.mint]) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Recovery Trend")
                    .font(.headline)

                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(appState.weeklyReport.recoveryTrend.enumerated()), id: \.offset) { index, value in
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(value >= 70 ? AppTheme.accent : value >= 50 ? AppTheme.amber : AppTheme.coral)
                                .frame(height: CGFloat(max(24, value)))
                                .frame(maxWidth: .infinity)

                            Text(dayLabel(for: index))
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                }
                .frame(height: 136)
            }
        }
    }

    private var trendDirection: String {
        guard let first = appState.weeklyReport.recoveryTrend.first,
              let last = appState.weeklyReport.recoveryTrend.last else {
            return "Collecting"
        }

        if last > first + 4 { return "Improving" }
        if last < first - 4 { return "Down" }
        return "Stable"
    }

    private func dayLabel(for index: Int) -> String {
        let labels = ["M", "T", "W", "T", "F", "S", "S"]
        guard labels.indices.contains(index) else { return "" }
        return labels[index]
    }
}
