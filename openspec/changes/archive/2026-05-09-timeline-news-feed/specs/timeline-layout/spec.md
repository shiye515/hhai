## ADDED Requirements

### Requirement: Vertical timeline axis
The system SHALL display a vertical timeline line on the left side of the screen, running the full height of the news feed content.

#### Scenario: Timeline renders with feed
- **WHEN** the news feed loads with at least one item
- **THEN** a vertical line (2pt wide, `{colors.hairline}` color) is displayed on the left edge, extending from the first item to the last item

#### Scenario: Timeline hidden on narrow screens
- **WHEN** the screen width is less than 736pt
- **THEN** the timeline axis is hidden and cards display in full-width layout

### Requirement: Timeline dot with time label
The system SHALL display a dot on the timeline for each news card, with the publication time (hour:minute) shown beside the dot.

#### Scenario: Dot and time for each card
- **WHEN** a news item is displayed in the feed
- **THEN** an 8pt diameter solid circle in `{colors.primary}` (#0066cc) is shown on the timeline, aligned to the top of the card, with the time in "HH:mm" format displayed to the right of the dot in `{typography.caption}` style

#### Scenario: Same-minute items
- **WHEN** multiple news items share the same publication minute
- **THEN** each item has its own dot and time label; duplicate time text is acceptable

### Requirement: Timeline column layout
The system SHALL use a fixed-width left column for the timeline and a flexible-width right column for cards.

#### Scenario: Column proportions on regular width
- **WHEN** the screen width is 736pt or greater
- **THEN** the timeline column is 60pt wide and the card column fills the remaining space

#### Scenario: Column collapse on compact width
- **WHEN** the screen width is less than 736pt
- **THEN** the timeline column collapses and cards take full width

### Requirement: Floating card style
The system SHALL render news cards with a minimalist floating appearance: no border, subtle shadow, rounded corners, and ample padding.

#### Scenario: Card visual treatment
- **WHEN** a news card is rendered
- **THEN** the card has background `{colors.canvas}`, rounded corners `{rounded.lg}` (18px), padding `{spacing.lg}` (24px), and a subtle shadow of `rgba(0, 0, 0, 0.06) 0 2px 12px`

#### Card shadow does not overlap adjacent cards
- **WHEN** cards are stacked vertically
- **THEN** there is at least `{spacing.md}` (17px) vertical gap between cards to prevent shadow overlap
