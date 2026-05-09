import SwiftUI

struct NewsCardView: View {
    let item: NewsItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                // Title
                Text(item.title)
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(3)
                    .foregroundStyle(DesignSystem.Colors.ink)
                    .tracking(-0.374)

                // Source + Time
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text(item.source)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(DesignSystem.Colors.inkMuted48)
                        .tracking(-0.224)

                    if let date = item.publishedAt {
                        Text("·")
                            .foregroundStyle(DesignSystem.Colors.inkMuted48)
                        Text(date, style: .relative)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(DesignSystem.Colors.inkMuted48)
                            .tracking(-0.224)
                    }
                }

                // Summary
                if let summary = item.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.system(size: 17, weight: .regular))
                        .lineLimit(3)
                        .foregroundStyle(DesignSystem.Colors.inkMuted80)
                        .tracking(-0.374)
                        .lineSpacing(1.47 * 17 - 17)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
