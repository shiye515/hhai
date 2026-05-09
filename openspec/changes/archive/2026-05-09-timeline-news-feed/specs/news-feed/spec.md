## MODIFIED Requirements

### Requirement: Display curated news list
The system SHALL display a timeline-based feed of curated AI news items from the `mode=selected` API endpoint, with a vertical timeline on the left and floating cards on the right, showing title, source, published time, and summary for each item.

#### Scenario: Load and display news items
- **WHEN** user opens the app
- **THEN** the system displays a timeline feed with news items ordered by publishedAt descending, each showing a timeline dot with HH:mm time label on the left, and a floating card with title, source name, and summary text on the right

#### Scenario: Empty state when no data
- **WHEN** user opens the app for the first time with no cached data and network is unavailable
- **THEN** the system displays an empty state message indicating no news available (no timeline visible)

### Requirement: Loading states
The system SHALL display appropriate loading indicators during data fetching, integrated with the timeline layout.

#### Scenario: Initial load with no cache
- **WHEN** app launches with no cached data
- **THEN** the system shows a loading spinner centered on screen (no timeline visible) until the first API response arrives

#### Scenario: Loading next page
- **WHEN** the system is fetching the next page of items
- **THEN** a progress indicator appears at the bottom of the timeline feed
