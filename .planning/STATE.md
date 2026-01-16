# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-01-14)

**Core value:** The swipe experience must feel like browsing shelves in a bookstore — full-screen covers, smooth transitions, one book at a time, never rushed.
**Current focus:** Phase 1 — Foundation

## Current Position

Phase: 3 of 8 (Core UI - Main Feed) - COMPLETE
Plan: FIX2 complete (1/1 tasks)
Status: Phase complete - all UAT issues resolved
Last activity: 2026-01-15 — Completed 03-FIX2.md (safe area fix)

Progress: ███████░░░ 65%

## Performance Metrics

**Velocity:**
- Total plans completed: 9
- Average duration: 9 min
- Total execution time: 92 min

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-foundation | 3/3 | 35 min | 12 min |
| 02-book-data-layer | 4/4 | 22 min | 6 min |
| 03-core-ui-main-feed | 3/TBD | 35 min | 12 min |

**Recent Trend:**
- Last 5 plans: 02-03 (8 min), 02-04 (2 min), 03-01 (5 min), 03-02 (20 min), 03-FIX (10 min)
- Trend: Fix plans efficient when issues are well-diagnosed

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

| Phase | Decision | Rationale |
|-------|----------|-----------|
| 01-01 | Kotlin 2.0.0 | Latest stable for KMP with best multiplatform support |
| 01-01 | Gradle 8.5 | Modern build tool version with Kotlin DSL improvements |
| 01-01 | Version catalog | Centralized dependency management via libs.versions.toml |
| 01-01 | Static iOS framework | Simpler integration, avoids dynamic linking issues |
| 01-02 | iOS 16.0 target | Modern baseline for SwiftUI features |
| 01-02 | Swift 5.9 | Latest stable Swift for best SwiftUI support |
| 01-02 | Xcode build phase | Gradle integration via embedAndSignAppleFrameworkForXcode |
| 01-03 | Android SDK 34 | Current target SDK with build-tools 34.0.0 |
| 01-03 | Deferred manual testing | User lacks device access; testing moved to future session |
| 02-01 | Ktor 2.3.7 | Multiplatform HTTP client with content negotiation support |
| 02-01 | kotlinx.serialization 1.6.2 | Official Kotlin serialization for JSON handling |
| 02-01 | Platform-specific engines | OkHttp (Android), Darwin (iOS) for optimal performance |
| 02-01 | Single author string | MVP simplicity; will expand to List<String> for multi-author books |
| 02-01 | BookCover utility model | Non-serializable helper for multi-size cover image handling |
| 02-02 | Google Books API primary source | Reliable metadata and comprehensive cover image sizes |
| 02-02 | Result<T> error handling | Non-exceptional error handling pattern for API calls |
| 02-02 | Extension function mapping | Clean DTO to domain conversion with toBook() extension |
| 02-02 | Cover size preference | Large → medium → thumbnail for best quality |
| 02-02 | ISBN-13 preference | Modern standard over ISBN-10, null if unavailable |
| 02-02 | Google Books API key required | External API key needed for requests (not hardcoded) |
| 02-03 | OL: ID prefix | Distinguishes Open Library books from Google Books (GB:) for source tracking |
| 02-03 | Dynamic key handling | JsonObject extraction for API responses with non-fixed keys |
| 02-04 | LRU cache with 30-min TTL | Balances data freshness with reduced API calls |
| 02-04 | Dual-API fallback | Google Books primary, Open Library fallback for ISBN lookups |
| 02-04 | expect/actual for time | Platform-specific currentTimeMillis() enables KMP-compatible caching |
| 03-01 | TabView for iOS 16 | TabView + PageTabViewStyle works on iOS 16; scrollTargetBehavior requires iOS 17+ |
| 03-01 | Hardcoded "fantasy" query | MVP simplicity; Phase 8 will add user preferences |
| 03-01 | API key placeholder | Users must provide their own Google Books API key for testing |
| 03-01 | TBR button non-functional | Visible for UX preview; Phase 4 will implement action |
| 03-02 | Coil 2.7.0 for Android | Stable version with good Compose support; Coil 3.x KMP support not needed for Android-only |
| 03-02 | Compose BOM 2024.06.00 | Upgraded from 2024.01.00 for better VerticalPager API compatibility |
| 03-02 | pageContent parameter | Used for VerticalPager instead of trailing lambda for BOM version compatibility |
| 03-02 | ViewModel per screen | FeedViewModel manages feed state; follows Android recommended architecture |
| 03-FIX | startIndex pagination | Google Books API requires startIndex parameter for proper pagination |
| 03-FIX | .ignoresSafeArea() | Modern SwiftUI replacement for deprecated .edgesIgnoringSafeArea() |
| 03-FIX | Deduplication by ID | Both platforms filter duplicates when appending pagination results |
| 03-FIX2 | ignoresSafeArea on container | Apply to ScrollView not child views for proper safe area extension |

### Deferred Issues

**Manual app testing (from 01-03):**
- Android and iOS apps need visual verification on emulator/device
- User lacks access to test devices currently
- Will be validated during future feature development
- Not blocking - build system verified working correctly

### Blockers/Concerns

None yet.

## Session Continuity

Last session: 2026-01-15T21:27:00Z
Stopped at: Completed Phase 03 (Core UI - Main Feed)
Resume file: None
Next: Plan Phase 04 (Book Info & Actions)
