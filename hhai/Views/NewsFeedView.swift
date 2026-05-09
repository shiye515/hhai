import SwiftUI

struct NewsFeedView: View {
    @State private var viewModel = NewsFeedViewModel()
    @State private var selectedItem: NewsItem?
    @State private var safariURL: URL?
    @State private var isShowingSettings = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.items.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.items.isEmpty {
                EmptyStateView()
            } else {
                timelineFeed
            }
        }
        .navigationTitle("AI 热点")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("设置")
            }
        }
        .task {
            await viewModel.loadInitial()
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
        .sheet(item: $safariURL) { url in
            SafariView(url: url)
        }
        .sheet(
            isPresented: Binding(
                get: { selectedItem != nil },
                set: { isPresented in
                    if !isPresented {
                        selectedItem = nil
                    }
                }
            )
        ) {
            if let selectedItem {
                ArticleMarkdownView(item: selectedItem)
            }
        }
    }

    private var timelineFeed: some View {
        ScrollView {
            NewsTimelineView(
                items: viewModel.items,
                isLoadingNext: viewModel.isLoadingNext,
                hasNext: viewModel.hasNext,
                onTap: { item in
                    if item.hasCachedArticleMarkdown {
                        selectedItem = item
                    } else if let url = URL(string: item.url) {
                        safariURL = url
                    }
                },
                onLoadMore: {
                    Task { await viewModel.loadNextPage() }
                }
            )
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
