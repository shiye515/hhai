import Foundation

@Observable
final class BookmarkManager {
    static let shared = BookmarkManager()

    private let key = "bookmarked_ids"
    private(set) var bookmarkedIDs: Set<String>

    private init() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        bookmarkedIDs = Set(saved)
    }

    func isBookmarked(_ id: String) -> Bool {
        bookmarkedIDs.contains(id)
    }

    func toggle(_ id: String) {
        if bookmarkedIDs.contains(id) {
            bookmarkedIDs.remove(id)
        } else {
            bookmarkedIDs.insert(id)
        }
        UserDefaults.standard.set(Array(bookmarkedIDs), forKey: key)
    }
}
