import Markdown
import Photos
import SwiftUI

struct ArticleMarkdownView: View {
    let item: NewsItem

    @Environment(\.dismiss) private var dismiss
    @State private var document: Document?
    @State private var isShowingShareSheet = false
    @State private var saveImageStatus: SaveImageStatus?
    @State private var errorMessage: String?

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
            .safeAreaInset(edge: .bottom) {
                bottomToolbar
            }
            .overlay(alignment: .bottom) {
                if saveImageStatus == .success {
                    Text("已保存到相册")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(DesignSystem.Colors.ink.clipShape(Capsule()))
                        .clipShape(Capsule())
                        .padding(.bottom, 60)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: saveImageStatus)
                }
            }
            .navigationTitle("正文")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingShareSheet) {
                ActivityViewController(activityItems: [shareText])
            }
            .alert("保存失败", isPresented: Binding(
                get: { saveImageStatus == .failed },
                set: { if !$0 { saveImageStatus = nil } }
            )) {
                Button("好的", role: .cancel) {}
            } message: {
                Text(saveImageStatus == .failed ? (errorMessage ?? "未知错误") : "")
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

    private var bottomToolbar: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "xmark")
                    Text("关闭")
                }
                .foregroundStyle(DesignSystem.Colors.primary)
            }

            Button {
                isShowingShareSheet = true
            } label: {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "square.and.arrow.up")
                    Text("分享")
                }
                .foregroundStyle(DesignSystem.Colors.primary)
            }

            Button {
                Task { await saveAsLongImage() }
            } label: {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "arrow.down.doc")
                    Text("长图")
                }
                .foregroundStyle(DesignSystem.Colors.primary)
            }
            .disabled(!hasCachedMarkdown)

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.canvas)
    }

    private var shareText: String {
        var parts = [displayTitle]
        if let markdown = item.articleMarkdown {
            parts.append(markdown)
        }
        return parts.joined(separator: "\n\n")
    }

    @MainActor
    private func saveAsLongImage() async {
        guard hasCachedMarkdown else { return }

        do {
            let image = try await renderLongImage()
            try await saveImageToPhotoLibrary(image)
            saveImageStatus = .success
            try await Task.sleep(for: .seconds(1.5))
            if saveImageStatus == .success {
                saveImageStatus = nil
            }
        } catch {
            errorMessage = error.localizedDescription
            saveImageStatus = .failed
        }
    }

    @MainActor
    private func renderLongImage() async throws -> UIImage {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else {
            throw ImageRenderError.noKeyWindow
        }
        let screen = scene.screen

        let content = LongImageContentView(item: item, document: document)
        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = .init(
            width: screen.bounds.width,
            height: .infinity
        )
        renderer.scale = screen.scale

        guard let image = renderer.uiImage else {
            throw ImageRenderError.failed
        }
        return image
    }

    @MainActor
    private func saveImageToPhotoLibrary(_ image: UIImage) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest.forAsset().addResource(with: .photo, data: image.pngData()!, options: nil)
        }
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

// MARK: - ActivityViewController

private struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - SaveImageStatus

enum SaveImageStatus {
    case success
    case failed
}

enum ImageRenderError: LocalizedError {
    case noKeyWindow
    case failed

    var errorDescription: String? {
        switch self {
        case .noKeyWindow: return "无法获取当前窗口，请确保应用在前台"
        case .failed: return "图片渲染失败"
        }
    }
}

// MARK: - Long Image Rendering

private struct LongImageContentView: View {
    let item: NewsItem
    let document: Document?

    private let bg = Color(uiColor: UIColor(red: 250/255, green: 249/255, blue: 245/255, alpha: 1))
    private let border = Color(uiColor: UIColor(red: 230/255, green: 223/255, blue: 216/255, alpha: 1))
    private let text = Color(uiColor: UIColor(red: 61/255, green: 61/255, blue: 58/255, alpha: 1))

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(displayTitle)
                        .font(.system(size: 28, weight: .semibold))
                        .lineSpacing(4)
                        .foregroundStyle(text)

                    Text(metadataText)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(text.opacity(0.6))

                    if let description = item.articleDescription, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 17, weight: .regular))
                            .lineSpacing(4)
                            .foregroundStyle(text.opacity(0.8))
                            .padding(.top, DesignSystem.Spacing.xxs)
                    }
                }
                .padding(.bottom, DesignSystem.Spacing.sm)

                if let document {
                    MarkdownDocumentView(document: document)
                } else if let markdown = item.articleMarkdown {
                    Text(markdown)
                        .font(.system(size: 17, weight: .regular))
                        .lineSpacing(7)
                        .foregroundStyle(text)
                        .textSelection(.disabled)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(bg)
            .fixedSize(horizontal: false, vertical: true)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(border, lineWidth: 1)
            )

            watermark
                .padding(.top, 0)
        }
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
            let f = DateFormatter()
            f.locale = Locale(identifier: "zh_CN")
            f.dateFormat = "MM月dd日 HH:mm"
            parts.append(f.string(from: publishedAt))
        }
        return parts.joined(separator: " · ")
    }

    private var watermark: some View {
        Text("FROM AIHOT")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(text.opacity(0.35))
            .frame(maxWidth: .infinity)
            .padding(.top, DesignSystem.Spacing.sm)
            .padding(.bottom, DesignSystem.Spacing.sm)
            .background(border)
    }
}
