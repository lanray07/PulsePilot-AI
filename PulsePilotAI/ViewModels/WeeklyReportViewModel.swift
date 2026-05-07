import Foundation

@MainActor
final class WeeklyReportViewModel: ObservableObject {
    @Published var isRefreshing = false

    func refresh(appState: AppState) async {
        isRefreshing = true
        await appState.refreshHealthData()
        isRefreshing = false
    }
}
