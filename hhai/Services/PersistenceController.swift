import Foundation
import SwiftData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    private init() {
        do {
            container = try ModelContainer(for: NewsItem.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    func saveItems(_ dtos: [NewsItemDTO]) {
        let context = container.mainContext
        let ids = dtos.map(\.id)
        let descriptor = FetchDescriptor<NewsItem>(
            predicate: #Predicate<NewsItem> { ids.contains($0.id) }
        )
        let existingItems = (try? context.fetch(descriptor)) ?? []
        let existingMap = Dictionary(uniqueKeysWithValues: existingItems.map { ($0.id, $0) })

        for dto in dtos {
            if let item = existingMap[dto.id] {
                item.update(from: dto)
            } else {
                let item = NewsItem(
                    id: dto.id,
                    title: dto.title,
                    titleEn: dto.titleEn,
                    url: dto.url,
                    source: dto.source,
                    publishedAt: dto.publishedAt,
                    summary: dto.summary,
                    category: dto.category
                )
                context.insert(item)
            }
        }
        try? context.save()
    }

    func loadCachedItems() -> [NewsItem] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<NewsItem>(
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func markArticleCacheLoading(for itemID: String) {
        guard let item = item(withID: itemID) else { return }
        item.markArticleCacheLoading()
        try? container.mainContext.save()
    }

    func saveArticleContent(for itemID: String, result: ArticleScrapeResult) {
        guard let item = item(withID: itemID) else { return }
        item.updateArticleContent(from: result)
        try? container.mainContext.save()
    }

    func saveArticleCacheFailure(for itemID: String, message: String) {
        guard let item = item(withID: itemID) else { return }
        item.markArticleCacheFailed(message)
        try? container.mainContext.save()
    }

    func pruneCache(maxItems: Int = 500) {
        let context = container.mainContext
        let all = loadCachedItems()
        guard all.count > maxItems else { return }
        let toDelete = all.suffix(from: maxItems)
        for item in toDelete {
            context.delete(item)
        }
        try? context.save()
    }

    private func item(withID id: String) -> NewsItem? {
        let context = container.mainContext
        var descriptor = FetchDescriptor<NewsItem>(
            predicate: #Predicate<NewsItem> { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }
}
