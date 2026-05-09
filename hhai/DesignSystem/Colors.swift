import SwiftUI

enum DesignSystem {
    enum Colors {
        // Brand & Accent
        static let primary = Color(hex: 0x0066CC)
        static let primaryFocus = Color(hex: 0x0071E3)
        static let primaryOnDark = Color(hex: 0x2997FF)

        // Text
        static let ink = Color(hex: 0x1D1D1F)
        static let bodyOnDark = Color.white
        static let bodyMuted = Color(hex: 0xCCCCCC)
        static let inkMuted80 = Color(hex: 0x333333)
        static let inkMuted48 = Color(hex: 0x7A7A7A)

        // Surface
        static let canvas = Color.white
        static let canvasParchment = Color(hex: 0xF5F5F7)
        static let surfacePearl = Color(hex: 0xFAFAFC)
        static let surfaceBlack = Color.black

        // Hairlines
        static let dividerSoft = Color(hex: 0xF0F0F0)
        static let hairline = Color(hex: 0xE0E0E0)
    }
}

private extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
