## ADDED Requirements

### Requirement: Cache news items locally
The system SHALL persist fetched news items using SwiftData so they are available offline.

#### Scenario: Save items after fetch
- **WHEN** the system receives items from the API
- **THEN** the items are upserted into the local SwiftData store (matched by `id`)

#### Scenario: Load cached items on launch
- **WHEN** the app launches
- **THEN** the system immediately loads all cached items from SwiftData, sorted by publishedAt descending, and presents them to the UI

### Requirement: Deduplicate items
The system SHALL not create duplicate entries when the same item appears in multiple API responses.

#### Scenario: Existing item re-fetched
- **WHEN** an item with an `id` already exists in the local store
- **THEN** the system updates the existing record rather than creating a new one

### Requirement: Cache freshness
The system SHALL track when the cache was last updated and expose this information.

#### Scenario: Record last fetch timestamp
- **WHEN** a successful API fetch completes
- **THEN** the system records the current timestamp as the last refresh time

#### Scenario: Expose freshness to UI
- **WHEN** the UI queries for cache metadata
- **THEN** the system returns the last refresh timestamp so the UI can display it (e.g., "上次更新: 5分钟前")

### Requirement: Cache size management
The system SHALL limit the local cache to prevent unbounded growth.

#### Scenario: Prune old items
- **WHEN** the cache contains more than 500 items
- **THEN** the system deletes items with the oldest publishedAt dates to bring the count back to 500
