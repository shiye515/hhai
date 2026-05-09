import Foundation

enum APIError: Error, LocalizedError {
    case networkUnavailable
    case rateLimited
    case httpError(Int)
    case decodingError(Error)
    case scrapeFailed(String)
    case firecrawlAPIKeyMissing

    var errorDescription: String? {
        switch self {
        case .networkUnavailable: return "网络不可用"
        case .rateLimited: return "请求过于频繁，请稍后再试"
        case .httpError(let code): return "服务器错误 (\(code))"
        case .decodingError: return "数据解析失败"
        case .scrapeFailed(let message): return message
        case .firecrawlAPIKeyMissing: return "未配置 Firecrawl API Key"
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let baseURL = URL(string: "https://aihot.virxact.com/api/public/items")!
    private let scrapeURL = URL(string: "https://api.firecrawl.dev/v2/scrape")!
    private let session: URLSession
    private var etag: String?

    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
    }

    func fetchItems(cursor: String? = nil, take: Int = 50) async throws -> ItemListResponse? {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        var queryItems = [
            URLQueryItem(name: "mode", value: "selected"),
            URLQueryItem(name: "take", value: "\(take)")
        ]
        if let cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.timeoutInterval = 15

        if let etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        #if DEBUG
        print("[API] GET \(request.url!.absoluteString)")
        #endif

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkUnavailable
            }

            #if DEBUG
            print("[API] \(httpResponse.statusCode) — \(data.count) bytes")
            #endif

            switch httpResponse.statusCode {
            case 200:
                if let newEtag = httpResponse.value(forHTTPHeaderField: "ETag") {
                    etag = newEtag
                }
                let decoded = try NewsItemDTO.decoder.decode(ItemListResponse.self, from: data)
                return decoded

            case 304:
                return nil

            case 503:
                try await Task.sleep(for: .seconds(1))
                return try await fetchItems(cursor: cursor, take: take)

            default:
                throw APIError.httpError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkUnavailable
        }
    }

    func scrapeArticle(url: String) async throws -> ArticleScrapeResult {
        guard let firecrawlAPIKey = FirecrawlSettings.apiKey else {
            throw APIError.firecrawlAPIKeyMissing
        }

        var request = URLRequest(url: scrapeURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("Bearer \(firecrawlAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(ArticleScrapeRequest(url: url))

        #if DEBUG
        print("[Firecrawl] POST \(url)")
        #endif

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkUnavailable
            }

            #if DEBUG
            print("[Firecrawl] \(httpResponse.statusCode) — \(data.count) bytes")
            #endif

            switch httpResponse.statusCode {
            case 200:
                let decoded = try NewsItemDTO.decoder.decode(ArticleScrapeResponse.self, from: data)
                guard decoded.success, let result = decoded.data else {
                    throw APIError.scrapeFailed("网页缓存失败")
                }
                return result

            case 429:
                throw APIError.rateLimited

            default:
                throw APIError.httpError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkUnavailable
        }
    }
}
