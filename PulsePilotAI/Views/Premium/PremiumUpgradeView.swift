import SwiftUI

struct PremiumUpgradeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedPlan: PremiumPlan = .yearly

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero
                planPicker
                featureList
                actionButton
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .background(AppTheme.groupedBackground.ignoresSafeArea())
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        GradientCard(colors: [AppTheme.accent, AppTheme.violet]) {
            VStack(alignment: .leading, spacing: 18) {
                ZStack {
                    Circle()
                        .fill(AppTheme.amber.opacity(0.16))
                        .frame(width: 68, height: 68)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(AppTheme.amber)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("PulsePilot AI Premium")
                        .font(.system(size: 28, weight: .bold, design: .rounded))

                    Text("Unlock adaptive coaching, burnout prediction, advanced recovery insights, weekly reports, and Apple Watch intelligence.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.top, 8)
    }

    private var planPicker: some View {
        HStack(spacing: 12) {
            ForEach(PremiumPlan.allCases) { plan in
                Button {
                    selectedPlan = plan
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(plan.title)
                            .font(.headline)
                        Text(plan.price)
                            .font(.title3.bold())
                        Text(plan.subtitle)
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(selectedPlan == plan ? AppTheme.accent.opacity(0.16) : AppTheme.elevatedBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(selectedPlan == plan ? AppTheme.accent : Color.white.opacity(0.06), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Included")
                .font(.headline)

            ForEach(PremiumFeature.allCases) { feature in
                HStack(spacing: 12) {
                    Image(systemName: feature.systemImage)
                        .font(.headline)
                        .foregroundStyle(feature.tint)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(feature.tint.opacity(0.14)))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(feature.title)
                            .font(.subheadline.weight(.bold))
                        Text(feature.subtitle)
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(AppTheme.elevatedBackground)
                )
            }
        }
    }

    private var actionButton: some View {
        Button {
            // TODO: Replace this with StoreKit subscription purchase and entitlement verification.
            appState.setPremiumPreview(true)
        } label: {
            Text(appState.isPremiumPreview ? "Premium Preview Active" : "Start Premium Preview")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.accent)
        .disabled(appState.isPremiumPreview)
    }
}

private enum PremiumPlan: String, CaseIterable, Identifiable {
    case monthly
    case yearly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        }
    }

    var price: String {
        switch self {
        case .monthly: "£9.99"
        case .yearly: "£99"
        }
    }

    var subtitle: String {
        switch self {
        case .monthly: "per month"
        case .yearly: "per year"
        }
    }
}

private enum PremiumFeature: String, CaseIterable, Identifiable {
    case coach
    case burnout
    case recovery
    case reports
    case watch

    var id: String { rawValue }

    var title: String {
        switch self {
        case .coach: "AI Coach"
        case .burnout: "Burnout prediction"
        case .recovery: "Advanced recovery"
        case .reports: "Weekly reports"
        case .watch: "Apple Watch intelligence"
        }
    }

    var subtitle: String {
        switch self {
        case .coach: "Adaptive guidance when your day changes"
        case .burnout: "Sleep, HRV, steps, and activity risk scoring"
        case .recovery: "Clear recovery drivers and next best actions"
        case .reports: "Consistency, trends, and mission history"
        case .watch: "Designed for richer watch signals later"
        }
    }

    var systemImage: String {
        switch self {
        case .coach: "bubble.left.and.bubble.right.fill"
        case .burnout: "flame.fill"
        case .recovery: "heart.fill"
        case .reports: "chart.xyaxis.line"
        case .watch: "applewatch"
        }
    }

    var tint: Color {
        switch self {
        case .coach: AppTheme.accent
        case .burnout: AppTheme.coral
        case .recovery: AppTheme.mint
        case .reports: AppTheme.sky
        case .watch: AppTheme.violet
        }
    }
}
