import Foundation
import SwiftData

@Model
final class NewsItem {
    @Attribute(.unique) var id: String
    var title: String
    var titleEn: String?
    var url: String
    var source: String
    var publishedAt: Date?
    var summary: String?
    var category: String?
    var cachedAt: Date
    var articleMarkdown: String?
    var articleTitle: String?
    var articleDescription: String?
    var articleLanguage: String?
    var articleStatusCode: Int?
    var articleError: String?
    var articleCachedAt: Date?
    var articleCacheStatusRawValue: Int?

    init(id: String, title: String, titleEn: String?, url: String, source: String,
         publishedAt: Date?, summary: String?, category: String?) {
        self.id = id
        self.title = title
        self.titleEn = titleEn
        self.url = url
        self.source = source
        self.publishedAt = publishedAt
        self.summary = summary
        self.category = category
        self.cachedAt = Date()
        self.articleMarkdown = nil
        self.articleTitle = nil
        self.articleDescription = nil
        self.articleLanguage = nil
        self.articleStatusCode = nil
        self.articleError = nil
        self.articleCachedAt = nil
        self.articleCacheStatusRawValue = ArticleCacheStatus.notStarted.rawValue
    }

    func update(from dto: NewsItemDTO) {
        let didChangeURL = url != dto.url
        title = dto.title
        titleEn = dto.titleEn
        url = dto.url
        source = dto.source
        publishedAt = dto.publishedAt
        summary = dto.summary
        category = dto.category
        cachedAt = Date()

        if didChangeURL {
            clearArticleContent()
        }
    }

    func updateArticleContent(from result: ArticleScrapeResult) {
        articleMarkdown = result.markdown
        articleTitle = result.metadata.title
        articleDescription = result.metadata.description
        articleLanguage = result.metadata.language
        articleStatusCode = result.metadata.statusCode
        articleError = result.metadata.error
        articleCachedAt = Date()
        articleCacheStatus = .success
    }

    func markArticleCacheFailed(_ message: String) {
        articleError = message
        articleCachedAt = Date()
        articleCacheStatus = .failed
    }

    func markArticleCacheLoading() {
        articleCacheStatus = .loading
        articleError = nil
    }

    private func clearArticleContent() {
        articleMarkdown = nil
        articleTitle = nil
        articleDescription = nil
        articleLanguage = nil
        articleStatusCode = nil
        articleError = nil
        articleCachedAt = nil
        articleCacheStatus = .notStarted
    }

    var articleCacheStatus: ArticleCacheStatus {
        get {
            if let raw = articleCacheStatusRawValue,
               let status = ArticleCacheStatus(rawValue: raw) {
                return status
            }
            if let markdown = articleMarkdown, !markdown.isEmpty {
                return .success
            }
            if let error = articleError, !error.isEmpty {
                return .failed
            }
            return .notStarted
        }
        set {
            articleCacheStatusRawValue = newValue.rawValue
        }
    }

    var hasCachedArticleMarkdown: Bool {
        guard let markdown = articleMarkdown else { return false }
        return !markdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - API DTOs

struct ItemListResponse: Decodable {
    let count: Int
    let hasNext: Bool
    let nextCursor: String?
    let items: [NewsItemDTO]
}

struct NewsItemDTO: Decodable {
    let id: String
    let title: String
    let titleEn: String?
    let url: String
    let source: String
    let publishedAt: Date?
    let summary: String?
    let category: String?

    enum CodingKeys: String, CodingKey {
        case id, title, url, source, summary, category
        case titleEn = "title_en"
        case publishedAt
    }

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

// MARK: - Article Scrape DTOs

struct ArticleScrapeRequest: Encodable {
    let url: String
    let onlyMainContent: Bool
    let maxAge: Int
    let parsers: [String]
    let formats: [String]

    init(url: String) {
        self.url = url
        self.onlyMainContent = false
        self.maxAge = 172_800_000
        self.parsers = ["pdf"]
        self.formats = ["markdown"]
    }
}

struct ArticleScrapeResponse: Decodable {
    let success: Bool
    let data: ArticleScrapeResult?
}

struct ArticleScrapeResult: Decodable {
    let markdown: String
    let metadata: ArticleScrapeMetadata
}

struct ArticleScrapeMetadata: Decodable {
    let title: String?
    let description: String?
    let language: String?
    let sourceURL: String?
    let statusCode: Int?
    let error: String?
}

enum ArticleCacheStatus: Int {
    case notStarted = 0
    case loading = 1
    case success = 2
    case failed = 3
}
