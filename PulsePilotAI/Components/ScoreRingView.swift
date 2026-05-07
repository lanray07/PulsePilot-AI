import SwiftUI

struct ScoreRingView: View {
    var score: Int
    var label: String
    var size: CGFloat = 156
    var tint: Color = AppTheme.accent

    private var progress: Double {
        min(1, max(0, Double(score) / 100))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.14), lineWidth: size * 0.08)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(colors: [tint, AppTheme.mint, tint], center: .center),
                    style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.primaryText)

                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) \(score)")
    }
}
