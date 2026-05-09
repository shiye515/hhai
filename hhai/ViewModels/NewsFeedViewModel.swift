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
    @ObservationIgnored private var articleCacheTask: Task<Void, Never>?
    @ObservationIgnored private var pendingArticleCacheCandidates: [ArticleCacheCandidate] = []
    @ObservationIgnored private var queuedArticleIDs = Set<String>()

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
        nextCursor = nil
        hasNext = false
        isLoading = true
        error = nil

        do {
            guard let response = try await api.fetchItems(cursor: nil) else {
                isLoading = false
                return
            }
            let dtos = response.items
            persistence.saveItems(dtos)
            items = persistence.loadCachedItems()
            cacheArticleMarkdowns(for: Array(dtos.prefix(20)))
            nextCursor = response.nextCursor
            hasNext = response.hasNext
            lastLoadTime = Date()
            UserDefaults.standard.set(lastLoadTime.timeIntervalSince1970, forKey: "lastRefreshTime")

            persistence.pruneCache()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    var lastRefreshTimeText: String {
        let interval = UserDefaults.standard.double(forKey: "lastRefreshTime")
        guard interval > 0 else { return "" }
        let date = Date(timeIntervalSince1970: interval)
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .short
        return "上次更新: \(formatter.localizedString(for: date, relativeTo: Date()))"
    }

    private func cacheArticleMarkdowns(for dtos: [NewsItemDTO]) {
        guard FirecrawlSettings.isConfigured else { return }

        let candidates = persistence.itemsNeedingArticleCache(from: dtos).map {
            ArticleCacheCandidate(id: $0.id, url: $0.url)
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
