import SwiftUI

struct SplashView: View {
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGradient)
                    .frame(width: 118, height: 118)
                    .shadow(color: AppTheme.accent.opacity(0.35), radius: 32, y: 16)

                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(pulse ? 1.04 : 0.96)

            VStack(spacing: 8) {
                Text("PulsePilot AI")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)

                Text("Adaptive health coaching")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding()
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
