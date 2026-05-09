import SwiftUI

extension DesignSystem {
    enum Typography {
        static func displayHeadline(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 40, weight: .semibold, design: .default))
                .lineSpacing(1.1 * 40 - 40)
                .tracking(-0.374)
        }

        static func tagline(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 21, weight: .semibold, design: .default))
                .lineSpacing(1.19 * 21 - 21)
                .tracking(0.231)
        }

        static func bodyStrong(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 17, weight: .semibold, design: .default))
                .lineSpacing(1.24 * 17 - 17)
                .tracking(-0.374)
        }

        static func body(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 17, weight: .regular, design: .default))
                .lineSpacing(1.47 * 17 - 17)
                .tracking(-0.374)
        }

        static func caption(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 14, weight: .regular, design: .default))
                .lineSpacing(1.43 * 14 - 14)
                .tracking(-0.224)
        }

        static func captionStrong(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .lineSpacing(1.29 * 14 - 14)
                .tracking(-0.224)
        }
    }
}
