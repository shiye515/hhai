## ADDED Requirements

### Requirement: Color tokens
The system SHALL define all DESIGN.md colors as SwiftUI Color extensions accessible via semantic names.

#### Scenario: Use primary color
- **WHEN** a view references `DesignSystem.Color.primary`
- **THEN** it resolves to #0066cc (Action Blue)

#### Scenario: Use surface colors
- **WHEN** a view references `DesignSystem.Color.canvas` or `DesignSystem.Color.canvasParchment`
- **THEN** it resolves to #ffffff or #f5f5f7 respectively

#### Scenario: Dark mode support
- **WHEN** the device is in dark mode
- **THEN** text colors automatically adapt (ink → white, canvas → near-black) using SwiftUI environment-aware colors

### Requirement: Typography tokens
The system SHALL define all DESIGN.md typography styles as SwiftUI Font/ViewModifier extensions.

#### Scenario: Display headline
- **WHEN** a view applies `DesignSystem.Typography.displayHeadline`
- **THEN** the text renders in SF Pro Display, 40px, weight 600, letter spacing -0.374

#### Scenario: Body text
- **WHEN** a view applies `DesignSystem.Typography.body`
- **THEN** the text renders in SF Pro Text, 17px, weight 400, line height 1.47

#### Scenario: Caption text
- **WHEN** a view applies `DesignSystem.Typography.caption`
- **THEN** the text renders in SF Pro Text, 14px, weight 400, letter spacing -0.224

### Requirement: Spacing tokens
The system SHALL define all DESIGN.md spacing values as constants.

#### Scenario: Use spacing values
- **WHEN** a view uses `DesignSystem.Spacing.md` (17pt), `.lg` (24pt), `.section` (80pt)
- **THEN** the values match DESIGN.md specifications exactly

### Requirement: News card component
The system SHALL provide a reusable news card view following DESIGN.md card styling.

#### Scenario: Render news card
- **WHEN** a news item is displayed in the list
- **THEN** the card shows: title in body-strong (17px/600), source + time in caption (14px/muted), summary in body (17px/400), with proper spacing tokens and no shadows or borders (per DESIGN.md Do's)

#### Scenario: Card interaction
- **WHEN** user taps a news card
- **THEN** the card provides haptic feedback and triggers the navigation action

### Requirement: Navigation bar styling
The system SHALL style the navigation bar following DESIGN.md's global nav pattern.

#### Scenario: Nav bar appearance
- **WHEN** the main view is displayed
- **THEN** the navigation bar uses a minimal style with the app title in SF Pro Display weight 600, and no decorative elements
