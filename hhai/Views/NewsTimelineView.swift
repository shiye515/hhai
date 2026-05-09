import SwiftUI

struct NewsTimelineView: View {
    let items: [NewsItem]
    let isLoadingNext: Bool
    let hasNext: Bool
    let onTap: (NewsItem) -> Void
    let onLoadMore: () -> Void

    private let bandWidth: CGFloat = 16

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                TimelineEntryView(
                    item: item,
                    bandWidth: bandWidth,
                    isFirst: index == 0,
                    isLast: index == items.count - 1 && !hasNext,
                    onTap: { onTap(item) }
                )
            }

            if hasNext {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Spacer()
                    ProgressView()
                    Text("加载中...")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(DesignSystem.Colors.inkMuted48)
                    Spacer()
                }
                .padding(.vertical, DesignSystem.Spacing.md)
                .onAppear { onLoadMore() }
            }

            if !hasNext && !items.isEmpty {
                HStack {
                    Spacer()
                    Text("已加载全部")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(DesignSystem.Colors.inkMuted48)
                        .padding(.vertical, DesignSystem.Spacing.lg)
                    Spacer()
                }
            }
        }
        .padding(.top, 12)
    }
}

// MARK: - Timeline Entry

private struct TimelineEntryView: View {
    let item: NewsItem
    let bandWidth: CGFloat
    let isFirst: Bool
    let isLast: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            TimelineBandView(date: item.publishedAt, width: bandWidth, isFirst: isFirst, isLast: isLast)
            FloatingCardView(item: item, onTap: onTap)
                .padding(.bottom, 12)
        }
    }
}

// MARK: - Timeline Band

private struct TimelineBandView: View {
    let date: Date?
    let width: CGFloat
    let isFirst: Bool
    let isLast: Bool

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private var cornerRadius: CGFloat { width / 2 }

    private var bandShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: isFirst ? cornerRadius : 0,
            bottomLeadingRadius: isLast ? cornerRadius : 0,
            bottomTrailingRadius: isLast ? cornerRadius : 0,
            topTrailingRadius: isFirst ? cornerRadius : 0
        )
    }

    var body: some View {
        if let date {
            let chars = Array(Self.formatter.string(from: date))
            ZStack {
                DesignSystem.Colors.primary
                VStack(spacing: 1) {
                    ForEach(chars.indices, id: \.self) { i in
                        Text(String(chars[i]))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(DesignSystem.Colors.canvas)
                    }
                }
                .padding(.top, 6)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(width: width)
            .clipShape(bandShape)
        }
    }
}

// MARK: - Floating Card

struct FloatingCardView: View {
    let item: NewsItem
    let onTap: () -> Void

    @State private var bookmarkManager = BookmarkManager.shared
    @State private var dragOffset: CGFloat = 0
    @State private var showBookmarkAction = false
    @State private var cardWidth: CGFloat = 0

    private var isBookmarked: Bool {
        bookmarkManager.isBookmarked(item.id)
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            // Bookmark action background
            if showBookmarkAction {
                HStack {
                    Spacer()
                    Image(systemName: isBookmarked ? "bookmark.slash.fill" : "bookmark.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(DesignSystem.Colors.canvas)
                        .frame(width: 56)
                        .frame(maxHeight: .infinity)
                        .background(DesignSystem.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Rounded.sm))
                }
            }

            // Card content
            Button(action: onTap) {
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(item.title)
                            .font(.system(size: 17, weight: .semibold))
                            .lineLimit(3)
                            .foregroundStyle(DesignSystem.Colors.ink)
                            .tracking(-0.374)
                            .padding(.trailing, DesignSystem.Spacing.md)

                        Text(item.source)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(DesignSystem.Colors.inkMuted48)
                            .tracking(-0.224)

                        if let summary = item.summary, !summary.isEmpty {
                            Text(summary)
                                .font(.system(size: 17, weight: .regular))
                                .lineLimit(3)
                                .foregroundStyle(DesignSystem.Colors.inkMuted80)
                                .tracking(-0.374)
                                .lineSpacing(1.47 * 17 - 17)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    ArticleCacheStatusIndicator(status: item.articleCacheStatus)
                        .padding(.top, 2)
                        .padding(.trailing, 2)
                    }
                .padding(DesignSystem.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignSystem.Colors.canvas)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Rounded.sm))
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Rounded.sm)
                        .strokeBorder(DesignSystem.Colors.primary, lineWidth: isBookmarked ? 1 : 0)
                )
                .background(
                    GeometryReader { geo in
                        Color.clear.onAppear { cardWidth = geo.size.width }
                    }
                )
                .offset(x: dragOffset)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 40)
                        .onChanged { value in
                            let translation = value.translation.width
                            if translation < 0 {
                                let threshold = cardWidth / 2
                                dragOffset = max(translation, -threshold)
                                showBookmarkAction = true
                            }
                        }
                        .onEnded { value in
                            let threshold = cardWidth / 2
                            if value.translation.width < -threshold {
                                bookmarkManager.toggle(item.id)
                            }
                            withAnimation(.spring(response: 0.3)) {
                                dragOffset = 0
                                showBookmarkAction = false
                            }
                        }
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ArticleCacheStatusIndicator: View {
    let status: ArticleCacheStatus

    var body: some View {
        Group {
            switch status {
            case .loading:
                ProgressView()
                    .controlSize(.mini)
                    .frame(width: 12, height: 12)

            case .success:
                statusDot(color: .green)

            case .failed:
                statusDot(color: .red)

            case .notStarted:
                statusDot(color: .yellow)
            }
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        switch status {
        case .notStarted: return "正文未开始缓存"
        case .loading: return "正文缓存中"
        case .success: return "正文已缓存"
        case .failed: return "正文缓存失败"
        }
    }

    private func statusDot(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
    }
}
