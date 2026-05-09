## ADDED Requirements

### Requirement: Fetch curated items
The system SHALL provide an async method to fetch curated news items from `GET /api/public/items?mode=selected`.

#### Scenario: Successful fetch
- **WHEN** the client calls `fetchItems(cursor: nil)`
- **THEN** the system sends a GET request to `https://aihot.virxact.com/api/public/items` with `mode=selected` and returns an `ItemList` containing items, count, hasNext, and nextCursor

#### Scenario: Fetch with cursor
- **WHEN** the client calls `fetchItems(cursor: "some-cursor")`
- **THEN** the system includes the cursor as a query parameter and returns the next page of results

### Requirement: Handle pagination
The system SHALL support cursor-based pagination with configurable page size.

#### Scenario: Default page size
- **WHEN** no `take` parameter is specified
- **THEN** the system requests 50 items per page (API default)

#### Scenario: Custom page size
- **WHEN** the client specifies `take: 20`
- **THEN** the system sends `take=20` as a query parameter

### Requirement: Network error handling
The system SHALL handle network errors gracefully without crashing.

#### Scenario: Network unavailable
- **WHEN** the device has no network connectivity
- **THEN** the system throws a typed error that the caller can handle (e.g., display cached data)

#### Scenario: Rate limited
- **WHEN** the API returns 503
- **THEN** the system waits 1 second and retries once; if still failing, throws an error

#### Scenario: HTTP error
- **WHEN** the API returns a 4xx or 5xx status (other than 503)
- **THEN** the system throws an error with the status code

### Requirement: ETag caching support
The system SHALL support HTTP ETag-based conditional requests to minimize data transfer.

#### Scenario: ETag match
- **WHEN** the server returns a 304 Not Modified response
- **THEN** the system returns nil (indicating no new data) without throwing an error
