# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.



## Project Overview

`hhai` (AI HOT iOS) is a SwiftUI iPhone client for reading AI news from the 数字生命卡兹克 curated feed at `https://aihot.virxact.com`. It features a timeline-based feed view, offline Markdown article caching via Firecrawl API, and bookmarking.

## Build & Run

```bash
# Xcode (recommended)
open hhai.xcodeproj

# CLI build
xcodebuild -project hhai.xcodeproj -scheme hhai -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

No test targets, linting, or CI pipelines exist. The project has no external package manager — dependencies (swift-markdown) are added as Swift Package references in the Xcode project.

## Architecture

### Layered Structure

```
hhaiApp.swift              → App entry point, wires up SwiftData container
ContentView.swift          → Root NavigationStack wrapping NewsFeedView
├── Views/
│   ├── NewsFeedView       → Main feed screen; state management for sheets (article, safari, settings)
│   ├── NewsTimelineView   → ScrollView + LazyVStack timeline layout with pagination
│   ├── NewsCardView       → Individual news card (not currently used — cards are inline in TimelineView)
│   ├── ArticleMarkdownView→ Full-screen Markdown article reader using swift-markdown
│   ├── SafariView         → SFSafariViewController wrapper for uncached articles
│   ├── SettingsView       → Firecrawl API Key configuration
│   └── EmptyStateView     → Placeholder when feed is empty
├── ViewModels/
│   └── NewsFeedViewModel  → @Observable; handles fetch, refresh, pagination, article cache queue
├── Models/
│   └── NewsItem           → SwiftData @Model + API DTOs (NewsItemDTO, ArticleScrapeResult, etc.)
├── Services/
│   ├── APIClient          → Singleton; fetches feed + scrapes articles via Firecrawl
│   ├── PersistenceController → Singleton SwiftData ModelContainer for NewsItem
│   ├── BookmarkManager    → @Observable; UserDefaults-backed bookmark set
│   └── FirecrawlSettings  → Keychain-stored Firecrawl API key
└── DesignSystem/
    ├── Colors             → DesignSystem.Colors enum with Apple-style color tokens
    ├── Spacing            → DesignSystem.Spacing + DesignSystem.Rounded enums
    └── Typography         → DesignSystem.Typography view modifiers
```

### Data Flow

1. **Feed fetch**: `NewsFeedViewModel.loadInitial()` loads from SwiftData cache first, then `refresh()` calls `APIClient.fetchItems()` → `PersistenceController.saveItems()` → `loadCachedItems()`.
2. **Article caching**: After refresh, the ViewModel queues the first 30 items for Markdown scraping. `APIClient.scrapeArticle()` calls Firecrawl API → `PersistenceController.saveArticleContent()` stores markdown on the `NewsItem` model.
3. **Card tap**: If `hasCachedArticleMarkdown` → show `ArticleMarkdownView`. Otherwise → open `SafariView` with the original URL.

### Key Conventions

- **@Observable** (not ObservableObject): ViewModel and BookmarkManager use the modern Observation framework.
- **SwiftData** is the single persistence layer; no Core Data or Realm.
- **No MVVM separation for individual views** — views own their state directly with `@State`.
- **DesignSystem** enum namespace provides colors, spacing, rounded corners, and typography consistent with Apple's web design language (documented in `DESIGN.md`).
- **API Key storage**: Firecrawl key is stored in Keychain via `FirecrawlSettings`, not UserDefaults or plaintext.

## External Dependencies

- `swift-markdown` (Apple) — Markdown parsing and rendering in `ArticleMarkdownView`
- No other third-party dependencies

## External Services

| Service   | URL                                          | Purpose                           |
| --------- | -------------------------------------------- | --------------------------------- |
| Feed API  | `https://aihot.virxact.com/api/public/items` | Fetch curated news items          |
| Firecrawl | `https://api.firecrawl.dev/v2/scrape`        | Convert article pages to Markdown |
