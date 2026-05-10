## ADDED Requirements

### Requirement: Save article as long image to photo library
The app SHALL render the full Markdown article content into a single image and save it to the user's photo library using `PHPhotoLibrary`.

#### Scenario: User taps save image button
- **WHEN** user taps the save image button in the bottom toolbar
- **THEN** the article content is rendered offscreen at full height and saved to the photo library

#### Scenario: Image save requires photo library permission
- **WHEN** the app does not yet have photo library add permission
- **THEN** the system permission dialog SHALL be presented with the usage description "用于保存文章长图到相册"

#### Scenario: Image save succeeds
- **WHEN** the image is successfully saved
- **THEN** a brief confirmation toast SHALL be shown to the user

#### Scenario: Image save fails
- **WHEN** the image fails to save (permission denied, storage full, etc.)
- **THEN** an error alert SHALL be shown with the failure reason

### Requirement: Long image respects current color scheme
The rendered long image SHALL use the current system color scheme (light or dark) for text and background colors.

#### Scenario: Light mode image
- **WHEN** the system is in light mode
- **THEN** the saved image has a light background and dark text

#### Scenario: Dark mode image
- **WHEN** the system is in dark mode
- **THEN** the saved image has a dark background and light text
