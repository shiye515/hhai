import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "newspaper")
                .font(.system(size: 48))
                .foregroundStyle(DesignSystem.Colors.inkMuted48)

            Text("暂无新闻")
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(DesignSystem.Colors.ink)
                .tracking(0.231)

            Text("下拉刷新获取最新资讯")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(DesignSystem.Colors.inkMuted48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
