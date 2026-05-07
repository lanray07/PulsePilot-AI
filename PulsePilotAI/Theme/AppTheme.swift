import SwiftUI

enum AppTheme {
    static let accent = Color(hex: 0x5BE38A)
    static let mint = Color(hex: 0x61E7C0)
    static let coral = Color(hex: 0xFF7A66)
    static let amber = Color(hex: 0xF5C85B)
    static let sky = Color(hex: 0x63A7FF)
    static let violet = Color(hex: 0x9B8CFF)

    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let background = Color(uiColor: .systemBackground)
    static let elevatedBackground = Color(uiColor: .secondarySystemBackground)
    static let groupedBackground = Color(uiColor: .systemGroupedBackground)

    static let primaryGradient = LinearGradient(
        colors: [accent, mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let recoveryGradient = LinearGradient(
        colors: [accent, sky],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func color(for level: BurnoutLevel) -> Color {
        switch level {
        case .low: accent
        case .medium: amber
        case .high: coral
        }
    }

    static func color(for category: MissionCategory) -> Color {
        switch category {
        case .movement: sky
        case .hydration: mint
        case .recovery: accent
        case .sleep: violet
        case .nutrition: amber
        case .mindfulness: coral
        }
    }
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

extension View {
    func premiumCardStyle(cornerRadius: CGFloat = 24) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.elevatedBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
            )
    }
}
