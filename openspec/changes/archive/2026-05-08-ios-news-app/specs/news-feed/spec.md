## ADDED Requirements

### Requirement: Display curated news list
The system SHALL display a scrollable list of curated AI news items from the `mode=selected` API endpoint, showing title, source, published date, and summary for each item.

#### Scenario: Load and display news items
- **WHEN** user opens the app
- **THEN** the system displays a list of news items ordered by publishedAt descending, each showing title, source name, relative time (e.g. "3小时前"), and summary text

#### Scenario: Empty state when no data
- **WHEN** user opens the app for the first time with no cached data and network is unavailable
- **THEN** the system displays an empty state message indicating no news available

### Requirement: Infinite scroll pagination
The system SHALL load more news items as the user scrolls to the bottom of the list using cursor-based pagination.

#### Scenario: Load next page on scroll
- **WHEN** user scrolls to the last 5 items in the list
- **THEN** the system requests the next page using the `nextCursor` from the previous response and appends new items to the list

#### Scenario: No more items
- **WHEN** the API response has `hasNext: false`
- **THEN** the system stops requesting further pages and shows a "已加载全部" indicator at the list bottom

### Requirement: Pull to refresh
The system SHALL support pull-to-refresh to fetch the latest news items.

#### Scenario: User pulls down
- **WHEN** user pulls down from the top of the list
- **THEN** the system fetches fresh data from the API (without cursor), replaces the list content, updates the local cache, and dismisses the refresh indicator

### Requirement: Open news in Safari
The system SHALL open the original article URL in Safari when user taps a news item.

#### Scenario: Tap news item
- **WHEN** user taps on a news item card
- **THEN** the system opens the item's `url` field in an in-app Safari view (SFSafariViewController)

### Requirement: Loading states
The system SHALL display appropriate loading indicators during data fetching.

#### Scenario: Initial load with no cache
- **WHEN** app launches with no cached data
- **THEN** the system shows a loading spinner centered on screen until the first API response arrives

#### Scenario: Loading next page
- **WHEN** the system is fetching the next page of items
- **THEN** a progress indicator appears at the bottom of the list
