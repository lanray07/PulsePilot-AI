import SwiftUI

struct MissionRow: View {
    var mission: Mission
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.color(for: mission.category).opacity(0.14))
                        .frame(width: 44, height: 44)

                    Image(systemName: mission.isCompleted ? "checkmark" : mission.category.systemImage)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(mission.isCompleted ? .white : AppTheme.color(for: mission.category))
                }
                .background(
                    Circle()
                        .fill(mission.isCompleted ? AppTheme.color(for: mission.category) : .clear)
                )

                VStack(alignment: .leading, spacing: 5) {
                    Text(mission.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText)
                        .strikethrough(mission.isCompleted, color: AppTheme.secondaryText)

                    Text(mission.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppTheme.elevatedBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(mission.isCompleted ? AppTheme.color(for: mission.category).opacity(0.35) : Color.white.opacity(0.07), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mission.accessibilityLabel)
        .accessibilityValue(mission.isCompleted ? "Completed" : "Not completed")
    }
}
