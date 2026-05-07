import SwiftUI

struct MissionsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = MissionsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                progressCard
                missionList
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .background(AppTheme.groupedBackground.ignoresSafeArea())
        .navigationTitle("Daily Missions")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.smooth) {
                        appState.regenerateMissions()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Regenerate missions")
            }
        }
    }

    private var progressCard: some View {
        let completed = appState.missions.filter(\.isCompleted).count
        let progress = viewModel.progress(for: appState.missions)

        return GradientCard(colors: [AppTheme.accent, AppTheme.coral]) {
            HStack(spacing: 18) {
                ScoreRingView(
                    score: Int((progress * 100).rounded()),
                    label: "Done",
                    size: 122,
                    tint: AppTheme.accent
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("\(completed) of \(appState.missions.count) complete")
                        .font(.title3.bold())

                    Text(viewModel.completedSummary)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 10) {
                        Label("\(appState.streakCount) day streak", systemImage: "flame.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.coral)

                        if appState.isPremiumPreview == false {
                            Label("Free: 3/day", systemImage: "lock.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    private var missionList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Focus")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    PremiumUpgradeView()
                } label: {
                    Text("Premium")
                }
                .font(.caption.weight(.bold))
            }

            ForEach(appState.missions) { mission in
                MissionRow(mission: mission) {
                    withAnimation(.smooth) {
                        appState.toggleMission(mission)
                    }
                }
            }
        }
    }
}
