import SwiftUI
import UIKit

enum DesignSystem {
    enum Colors {
        // Brand & Accent
        static let primary = Color(hex: 0x0066CC)
        static let primaryFocus = Color(hex: 0x0071E3)
        static let primaryOnDark = Color(hex: 0x2997FF)

        // Text — adapts to light / dark
        static let ink = adaptiveText(light: 0x1D1D1F, dark: 0xF5F5F7)
        static let bodyOnDark = Color.white
        static let bodyMuted = Color(hex: 0xCCCCCC)
        static let inkMuted80 = adaptiveText(light: 0x333333, dark: 0xA8A8A8)
        static let inkMuted48 = adaptiveText(light: 0x7A7A7A, dark: 0x8E8E93)

        // Surface — adapts to light / dark
        static let canvas = adaptiveSurface(light: 0xFFFFFF, dark: 0x1C1C1E)
        static let canvasParchment = adaptiveSurface(light: 0xF5F5F7, dark: 0x2C2C2E)
        static let surfacePearl = Color(hex: 0xFAFAFC)
        static let surfaceBlack = Color.black

        // Hairlines — adapts to light / dark
        static let dividerSoft = adaptiveBorder(light: 0xF0F0F0, dark: 0x38383A)
        static let hairline = adaptiveBorder(light: 0xE0E0E0, dark: 0x38383A)
    }
}

// MARK: - Dark mode helpers

private func hex(_ value: UInt) -> UIColor {
    UIColor(red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            alpha: 1)
}

private func adaptiveText(light: UInt, dark: UInt) -> Color {
    Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? hex(dark) : hex(light)
    })
}

private func adaptiveSurface(light: UInt, dark: UInt) -> Color {
    Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? hex(dark) : hex(light)
    })
}

private func adaptiveBorder(light: UInt, dark: UInt) -> Color {
    Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? hex(dark) : hex(light)
    })
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
