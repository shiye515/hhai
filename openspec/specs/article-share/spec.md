## ADDED Requirements

### Requirement: Article share via system share sheet
The app SHALL provide a share action that presents `UIActivityViewController` with the article's title, URL, and summary text as shareable items.

#### Scenario: User taps share button
- **WHEN** user taps the share button in the article view bottom toolbar
- **THEN** the system share sheet appears with the article title, URL, and summary as shareable content

#### Scenario: Share sheet dismissed
- **WHEN** user dismisses the share sheet without completing a share action
- **THEN** the article view returns to its previous state with no side effects

#### Scenario: Share button unavailable when no URL
- **WHEN** the article item has no valid URL
- **THEN** the share button SHALL be hidden or disabled
