import Foundation
import Security

enum FirecrawlSettings {
    private static let apiKeyAccount = "firecrawlAPIKey"

    static var apiKey: String? {
        get {
            KeychainStorage.string(for: apiKeyAccount)
        }
        set {
            let trimmed = newValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            KeychainStorage.setString(trimmed.isEmpty ? nil : trimmed, for: apiKeyAccount)
        }
    }

    static var isConfigured: Bool {
        apiKey != nil
    }
}

private enum KeychainStorage {
    private static let service = "com.hhai.firecrawl"

    static func string(for account: String) -> String? {
        var query = baseQuery(for: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func setString(_ value: String?, for account: String) {
        guard let value, let data = value.data(using: .utf8) else {
            deleteString(for: account)
            return
        }

        let query = baseQuery(for: account)
        let attributes: [String: Any] = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = data
            newItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            SecItemAdd(newItem as CFDictionary, nil)
        }
    }

    private static func deleteString(for account: String) {
        SecItemDelete(baseQuery(for: account) as CFDictionary)
    }

    private static func baseQuery(for account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
