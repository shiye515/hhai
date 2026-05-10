import Foundation
import SwiftUI

@Observable
final class NewsFeedViewModel {
    var items: [NewsItem] = []
    var isLoading = false
    var isLoadingNext = false
    var hasNext = false
    var error: String?

    private let api = APIClient.shared
    private let persistence = PersistenceController.shared
    private var nextCursor: String?
    private var lastLoadTime: Date = .distantPast
    @ObservationIgnored private var refreshTask: Task<Void, Never>?
    @ObservationIgnored private var articleCacheTask: Task<Void, Never>?
    @ObservationIgnored private var pendingArticleCacheCandidates: [ArticleCacheCandidate] = []
    @ObservationIgnored private var queuedArticleIDs = Set<String>()
    @ObservationIgnored private var cachedLastRefreshText: String = ""

    func loadInitial() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        items = persistence.loadCachedItems()
        isLoading = false
    }

    func loadNextPage() async {
        guard hasNext, !isLoadingNext, !isLoading else { return }
        guard let cursor = nextCursor else { return }

        isLoadingNext = true

        do {
            guard let response = try await api.fetchItems(cursor: cursor) else {
                isLoadingNext = false
                return
            }
            let dtos = response.items
            let existingIds = Set(items.map(\.id))
            let newIds = Set(dtos.map(\.id))
            let hasNewData = !newIds.isSubset(of: existingIds)

            persistence.saveItems(dtos)
            items = persistence.loadCachedItems()
            nextCursor = response.nextCursor
            hasNext = response.hasNext && hasNewData
            lastLoadTime = Date()

            persistence.pruneCache()
        } catch {
            // Silent failure for pagination
        }

        isLoadingNext = false
    }

    func refresh() async {
        if let refreshTask {
            await refreshTask.value
            return
        }

        let task = Task<Void, Never> { [weak self] in
            guard let self else { return }
            await self.performRefresh()
        }
        refreshTask = task
        await task.value
        refreshTask = nil
    }

    private func performRefresh() async {
        // Cancel in-flight article cache from a previous refresh so the new
        // top-30 items take priority.
        articleCacheTask?.cancel()
        articleCacheTask = nil
        pendingArticleCacheCandidates.removeAll()
        queuedArticleIDs.removeAll()

        nextCursor = nil
        hasNext = false
        isLoading = true
        error = nil

        do {
            if let response = try await api.fetchItems(cursor: nil) {
                persistence.saveItems(response.items)
                nextCursor = response.nextCursor
                hasNext = response.hasNext
                items = persistence.loadCachedItems()
            }
            // When the API returns 304 (response is nil), the local cache is
            // unchanged so skip the costly loadCachedItems query and reuse
            // the existing items array.

            cacheArticleMarkdowns(for: Array(items.prefix(30)))
            updateLastRefreshTime()
            persistence.pruneCache()
        } catch is CancellationError {
            // SwiftUI can cancel refreshable work as the view updates. Keep the
            // current feed state and avoid surfacing cancellation as an error.
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    private func updateLastRefreshTime() {
        let now = Date()
        lastLoadTime = now
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .short
        cachedLastRefreshText = "上次更新: \(formatter.localizedString(for: now, relativeTo: Date()))"
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: "lastRefreshTime")
    }

    var lastRefreshTimeText: String {
        cachedLastRefreshText
    }

    private func cacheArticleMarkdowns(for items: [NewsItem]) {
        guard FirecrawlSettings.isConfigured else { return }

        let candidates = items.compactMap { item -> ArticleCacheCandidate? in
            guard shouldCacheArticleMarkdown(for: item) else { return nil }
            return ArticleCacheCandidate(id: item.id, url: item.url)
        }
        guard !candidates.isEmpty else { return }

        for candidate in candidates where !queuedArticleIDs.contains(candidate.id) {
            pendingArticleCacheCandidates.append(candidate)
            queuedArticleIDs.insert(candidate.id)
        }

        guard articleCacheTask == nil else { return }
        articleCacheTask = Task {
            await processArticleCacheQueue()
        }
    }

    private func shouldCacheArticleMarkdown(for item: NewsItem) -> Bool {
        let hasMarkdown = item.articleMarkdown?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        return !hasMarkdown || item.articleCacheStatus == .failed
    }

    private func processArticleCacheQueue() async {
        defer { articleCacheTask = nil }

        while !pendingArticleCacheCandidates.isEmpty {
            guard !Task.isCancelled else { return }
            let candidate = pendingArticleCacheCandidates.removeFirst()

            do {
                persistence.markArticleCacheLoading(for: candidate.id)
                let result = try await api.scrapeArticle(url: candidate.url)
                persistence.saveArticleContent(for: candidate.id, result: result)
            } catch {
                persistence.saveArticleCacheFailure(
                    for: candidate.id,
                    message: error.localizedDescription
                )
            }

            queuedArticleIDs.remove(candidate.id)
        }
    }
}

private struct ArticleCacheCandidate {
    let id: String
    let url: String
}
