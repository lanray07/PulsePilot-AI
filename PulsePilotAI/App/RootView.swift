import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: AppTab = .today

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if appState.isShowingSplash {
                SplashView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else if appState.isOnboarded {
                mainTabs
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: 0.45), value: appState.isShowingSplash)
        .animation(.smooth(duration: 0.45), value: appState.isOnboarded)
        .task {
            try? await Task.sleep(nanoseconds: 950_000_000)
            appState.finishSplash()
            if appState.isOnboarded {
                await appState.refreshHealthData()
            }
        }
    }

    private var mainTabs: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem { Label(AppTab.today.title, systemImage: AppTab.today.systemImage) }
            .tag(AppTab.today)

            NavigationStack {
                MissionsView()
            }
            .tabItem { Label(AppTab.missions.title, systemImage: AppTab.missions.systemImage) }
            .tag(AppTab.missions)

            NavigationStack {
                CoachChatView()
            }
            .tabItem { Label(AppTab.coach.title, systemImage: AppTab.coach.systemImage) }
            .tag(AppTab.coach)

            NavigationStack {
                WeeklyReportView()
            }
            .tabItem { Label(AppTab.weekly.title, systemImage: AppTab.weekly.systemImage) }
            .tag(AppTab.weekly)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage) }
            .tag(AppTab.settings)
        }
        .tint(AppTheme.accent)
    }
}
