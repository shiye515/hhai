import Markdown
import SwiftUI

struct ArticleMarkdownView: View {
    let item: NewsItem

    @Environment(\.dismiss) private var dismiss
    @State private var document: Document?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    header

                    if hasCachedMarkdown {
                        if let document {
                            MarkdownDocumentView(document: document)
                        } else if let markdown = item.articleMarkdown {
                            Text(markdown)
                                .font(.system(size: 17, weight: .regular))
                                .lineSpacing(7)
                                .foregroundStyle(DesignSystem.Colors.ink)
                                .textSelection(.enabled)
                        }
                    } else {
                        unavailableState
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(DesignSystem.Colors.canvas.ignoresSafeArea())
            .navigationTitle("正文")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear(perform: renderMarkdown)
        .onChange(of: item.articleMarkdown) {
            renderMarkdown()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(displayTitle)
                .font(.system(size: 28, weight: .semibold))
                .lineSpacing(4)
                .foregroundStyle(DesignSystem.Colors.ink)

            Text(metadataText)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(DesignSystem.Colors.inkMuted48)

            if let description = item.articleDescription, !description.isEmpty {
                Text(description)
                    .font(.system(size: 17, weight: .regular))
                    .lineSpacing(4)
                    .foregroundStyle(DesignSystem.Colors.inkMuted80)
                    .padding(.top, DesignSystem.Spacing.xxs)
            }
        }
        .padding(.bottom, DesignSystem.Spacing.sm)
    }

    private var unavailableState: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            if item.articleError == nil {
                ProgressView()
            }

            Text(item.articleError == nil ? "正文正在缓存" : "正文缓存失败")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(DesignSystem.Colors.ink)

            Text(item.articleError ?? "feed 返回后会按顺序缓存网页正文，完成后这里会显示本地 Markdown。")
                .font(.system(size: 14, weight: .regular))
                .lineSpacing(4)
                .foregroundStyle(DesignSystem.Colors.inkMuted48)
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Colors.canvasParchment)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Rounded.sm))
    }

    private var hasCachedMarkdown: Bool {
        guard let markdown = item.articleMarkdown else { return false }
        return !markdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var displayTitle: String {
        guard let articleTitle = item.articleTitle, !articleTitle.isEmpty else {
            return item.title
        }
        return articleTitle
    }

    private var metadataText: String {
        var parts = [item.source]
        if let publishedAt = item.publishedAt {
            parts.append(Self.dateFormatter.string(from: publishedAt))
        }
        if let cachedAt = item.articleCachedAt, hasCachedMarkdown {
            parts.append("已离线缓存 \(Self.dateFormatter.string(from: cachedAt))")
        }
        return parts.joined(separator: " · ")
    }

    private func renderMarkdown() {
        guard hasCachedMarkdown, let markdown = item.articleMarkdown else {
            document = nil
            return
        }

        document = Document(parsing: markdown, options: [.disableSmartOpts])
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "MM月dd日 HH:mm"
        return formatter
    }()
}

private struct MarkdownDocumentView: View {
    let document: Document

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            ForEach(Array(document.children.enumerated()), id: \.offset) { _, child in
                MarkdownBlockView(markup: child)
            }
        }
        .textSelection(.enabled)
    }
}

private struct MarkdownBlockView: View {
    let markup: Markup

    var body: some View {
        Group {
            if let heading = markup as? Heading {
                Text(inlineText(for: heading))
                    .font(headingFont(for: heading.level))
                    .lineSpacing(3)
                    .foregroundStyle(DesignSystem.Colors.ink)
                    .padding(.top, heading.level <= 2 ? DesignSystem.Spacing.sm : DesignSystem.Spacing.xs)

            } else if let paragraph = markup as? Paragraph {
                Text(inlineText(for: paragraph))
                    .font(.system(size: 17, weight: .regular))
                    .lineSpacing(7)
                    .foregroundStyle(DesignSystem.Colors.ink)

            } else if let codeBlock = markup as? CodeBlock {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(codeBlock.code)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundStyle(DesignSystem.Colors.ink)
                        .padding(DesignSystem.Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(DesignSystem.Colors.canvasParchment)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Rounded.sm))

            } else if markup is ThematicBreak {
                Rectangle()
                    .fill(DesignSystem.Colors.hairline)
                    .frame(height: 1)
                    .padding(.vertical, DesignSystem.Spacing.xs)

            } else if let unorderedList = markup as? UnorderedList {
                MarkdownListView(list: unorderedList, ordered: false)

            } else if let orderedList = markup as? OrderedList {
                MarkdownListView(list: orderedList, ordered: true)

            } else if let blockQuote = markup as? BlockQuote {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    ForEach(Array(blockQuote.children.enumerated()), id: \.offset) { _, child in
                        MarkdownBlockView(markup: child)
                    }
                }
                .padding(.leading, DesignSystem.Spacing.md)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(DesignSystem.Colors.hairline)
                        .frame(width: 3)
                }

            } else if let table = markup as? Markdown.Table {
                MarkdownTableView(table: table)

            } else if let html = markup as? HTMLBlock {
                Text(html.rawHTML)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundStyle(DesignSystem.Colors.inkMuted48)

            } else {
                Text(markup.plainTextContent)
                    .font(.system(size: 17, weight: .regular))
                    .lineSpacing(7)
                    .foregroundStyle(DesignSystem.Colors.ink)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func headingFont(for level: Int) -> Font {
        switch level {
        case 1:
            return .system(size: 26, weight: .semibold)
        case 2:
            return .system(size: 23, weight: .semibold)
        case 3:
            return .system(size: 20, weight: .semibold)
        default:
            return .system(size: 18, weight: .semibold)
        }
    }

    private func inlineText(for container: InlineContainer) -> AttributedString {
        InlineAttributedStringRenderer().render(container.inlineChildren)
    }
}

private struct MarkdownListView<List: Markup>: View {
    let list: List
    let ordered: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            ForEach(Array(list.children.enumerated()), id: \.offset) { index, child in
                if let item = child as? ListItem {
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
                        Text(ordered ? "\(index + 1)." : "•")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(DesignSystem.Colors.inkMuted80)
                            .frame(width: 24, alignment: .trailing)

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            ForEach(Array(item.children.enumerated()), id: \.offset) { _, itemChild in
                                MarkdownBlockView(markup: itemChild)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct MarkdownTableView: View {
    let table: Markdown.Table

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                    GridRow {
                        ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                            Text(InlineAttributedStringRenderer().render(cell.inlineChildren))
                                .font(.system(size: 15, weight: rowIndex == 0 ? .semibold : .regular))
                                .foregroundStyle(DesignSystem.Colors.ink)
                                .padding(.vertical, DesignSystem.Spacing.xs)
                                .padding(.horizontal, DesignSystem.Spacing.sm)
                                .frame(minWidth: 96, alignment: .leading)
                                .background(rowIndex == 0 ? DesignSystem.Colors.canvasParchment : DesignSystem.Colors.canvas)
                                .overlay {
                                    Rectangle()
                                        .stroke(DesignSystem.Colors.hairline, lineWidth: 1)
                                }
                        }
                    }
                }
            }
        }
    }

    private var rows: [[Markdown.Table.Cell]] {
        [Array(table.head.cells)] + table.body.rows.map { Array($0.cells) }
    }
}

private struct InlineAttributedStringRenderer {
    func render(_ children: some Sequence<InlineMarkup>) -> AttributedString {
        children.reduce(into: AttributedString()) { result, child in
            result += render(child)
        }
    }

    private func render(_ markup: InlineMarkup) -> AttributedString {
        if let text = markup as? Markdown.Text {
            return AttributedString(text.string)

        } else if let code = markup as? InlineCode {
            var attributed = AttributedString(code.code)
            attributed.font = .system(size: 16, design: .monospaced)
            attributed.backgroundColor = UIColor.systemGray6
            return attributed

        } else if let strong = markup as? Strong {
            var attributed = render(strong.inlineChildren)
            attributed.font = .system(size: 17, weight: .semibold)
            return attributed

        } else if let emphasis = markup as? Emphasis {
            var attributed = render(emphasis.inlineChildren)
            attributed.inlinePresentationIntent = .emphasized
            return attributed

        } else if let strike = markup as? Strikethrough {
            var attributed = render(strike.inlineChildren)
            attributed.strikethroughStyle = .single
            return attributed

        } else if let link = markup as? Markdown.Link {
            var attributed = render(link.inlineChildren)
            if let destination = link.destination, let url = URL(string: destination) {
                attributed.link = url
            }
            attributed.foregroundColor = UIColor.systemBlue
            return attributed

        } else if markup is LineBreak {
            return AttributedString("\n")

        } else if markup is SoftBreak {
            return AttributedString(" ")

        } else if let html = markup as? InlineHTML {
            return AttributedString(html.rawHTML)

        } else {
            return AttributedString(markup.plainText)
        }
    }
}

private extension Markup {
    var plainTextContent: String {
        if let inline = self as? InlineMarkup {
            return inline.plainText
        }
        return children.map(\.plainTextContent).joined(separator: "\n")
    }
}
