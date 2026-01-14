---
phase: 02-book-data-layer
plan: 04
subsystem: data
tags: [repository-pattern, dual-api-fallback, caching, lru-cache, google-books, open-library]

# Dependency graph
requires:
  - phase: 02-book-data-layer
    plan: 02
    provides: Google Books API client and mapper
  - phase: 02-book-data-layer
    plan: 03
    provides: Open Library API client and mapper
  - phase: 02-book-data-layer
    plan: 01
    provides: Book domain model
provides:
  - BookRepository with dual-API fallback strategy
  - BookCache with LRU eviction and TTL expiration
  - Factory method for simple repository initialization
  - Unified book search and ISBN lookup interface
affects: [ui-layer, book-search, isbn-scanner, offline-support]

# Tech tracking
tech-stack:
  added: []
  patterns: [repository-pattern, dual-api-fallback, lru-cache-pattern, expect-actual-multiplatform, factory-method-pattern]

key-files:
  created:
    - shared/src/commonMain/kotlin/com/browsy/data/cache/BookCache.kt
    - shared/src/androidMain/kotlin/com/browsy/data/cache/CurrentTimeMillis.android.kt
    - shared/src/iosMain/kotlin/com/browsy/data/cache/CurrentTimeMillis.ios.kt
    - shared/src/commonMain/kotlin/com/browsy/data/repository/BookRepository.kt

key-decisions:
  - "LRU cache with 30-minute TTL balances freshness and performance"
  - "Google Books API as primary source for better metadata quality"
  - "Open Library fallback ensures ISBN lookups succeed even if Google Books has no results"
  - "expect/actual pattern for currentTimeMillis() enables KMP-compatible time operations"
  - "Factory method (BookRepository.create) simplifies initialization"
  - "Cache keying: search:query for searches, isbn:number for ISBN lookups"

patterns-established:
  - "Repository pattern: Single interface for multiple data sources with transparent fallback"
  - "Dual-API strategy: Primary API + fallback API for resilience"
  - "LRU cache: In-memory caching with automatic eviction when full"
  - "expect/actual: Platform-specific implementations for time operations"
  - "Factory method: Simplified object creation with sensible defaults"

# Metrics
duration: 2min
completed: 2026-01-14
---

# Phase 2 Plan 4: BookRepository with Dual-API Fallback Summary

**BookRepository unifies Google Books and Open Library with LRU caching, automatic fallback, and factory initialization**

## Performance

- **Duration:** 2 min
- **Started:** 2026-01-14T23:36:10Z
- **Completed:** 2026-01-14T23:38:43Z
- **Tasks:** 3
- **Files created:** 4

## Accomplishments
- BookCache implements LRU eviction with 30-minute TTL for optimal memory usage
- BookRepository tries Google Books first, falls back to Open Library for ISBN lookups
- Cache reduces redundant API calls by storing search and ISBN lookup results
- Factory method simplifies repository creation with single API key parameter
- Platform-specific time implementations enable KMP-compatible caching

## Task Commits

Each task was committed atomically:

1. **Task 1: Create in-memory book cache with LRU eviction** - `2fd1f93` (feat)
2. **Task 2: Create BookRepository with dual-API fallback strategy** - `a94230a` (feat)
3. **Task 3: Add BookRepository.create() factory method** - `676f656` (feat)

**Plan metadata:** (next commit) (docs: complete plan)

## Files Created/Modified
- `shared/src/commonMain/kotlin/com/browsy/data/cache/BookCache.kt` - LRU cache with TTL expiration for book data
- `shared/src/androidMain/kotlin/com/browsy/data/cache/CurrentTimeMillis.android.kt` - Android System.currentTimeMillis() implementation
- `shared/src/iosMain/kotlin/com/browsy/data/cache/CurrentTimeMillis.ios.kt` - iOS NSDate.timeIntervalSince1970 implementation
- `shared/src/commonMain/kotlin/com/browsy/data/repository/BookRepository.kt` - Unified book data access with dual-API fallback

## Decisions Made

**LRU cache strategy:**
- 30-minute TTL balances data freshness with reduced API calls
- 100 entry max size prevents unbounded memory growth
- LRU eviction ensures most relevant books stay in cache

**Dual-API fallback logic:**
- Google Books primary for rich metadata and better coverage
- Open Library fallback for ISBN lookups when Google Books has no results
- Search operations only use Google Books (Open Library lacks general search)

**expect/actual for time:**
- Needed KMP-compatible way to get current timestamp
- Platform-specific implementations: System.currentTimeMillis() (Android), NSDate (iOS)
- Internal visibility keeps implementation detail private

**Factory method design:**
- BookRepository.create(apiKey) provides simple initialization
- Configures all dependencies automatically (GoogleBooksApi, OpenLibraryApi, BookCache)
- KDoc explains platform-specific API key configuration strategy

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Added expect/actual pattern for currentTimeMillis()**
- **Found during:** Task 1 (BookCache implementation)
- **Issue:** System.currentTimeMillis() not available in commonMain - compilation failed
- **Fix:** Created expect function in commonMain, actual implementations for Android and iOS
- **Files modified:**
  - BookCache.kt (added expect function declaration)
  - CurrentTimeMillis.android.kt (Android implementation using System)
  - CurrentTimeMillis.ios.kt (iOS implementation using NSDate)
- **Verification:** ./gradlew :shared:build succeeds without errors
- **Committed in:** 2fd1f93 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking issue)
**Impact on plan:** Essential fix for KMP compilation. No scope creep - minimal code to unblock task.

## Issues Encountered

None

## User Setup Required

**Google Books API Key:**
The BookRepository requires a Google Books API key. Users must:

1. Create Google Cloud account (if not already exists)
2. Enable Books API in Google Cloud Console:
   - Navigate to APIs & Services → Library
   - Search for "Books API"
   - Click "Enable"
3. Create API Key:
   - Navigate to APIs & Services → Credentials
   - Click "Create Credentials" → "API Key"
   - Restrict key to Books API for security
4. Configure in platform-specific code:
   - **Android:** Add to `local.properties` (gitignored): `GOOGLE_BOOKS_API_KEY=your_key_here`
   - **iOS:** Add to Info.plist or Bundle configuration
   - Pass to `BookRepository.create(apiKey)`

**Open Library:** No setup required - free public API, no authentication needed.

## Next Phase Readiness

Book data layer is now complete and ready for UI integration:
- BookRepository provides unified search and ISBN lookup
- Dual-API fallback ensures reliability (Google Books → Open Library)
- In-memory cache reduces API calls and improves performance
- Factory method simplifies initialization for UI code

All verification criteria met:
- ./gradlew :shared:build succeeds without errors
- BookCache implements LRU eviction and TTL expiration
- BookRepository tries Google Books first, then Open Library
- Search results and ISBN lookups are cached
- Repository uses Result type consistently
- No hardcoded API keys in repository code

**Phase 2 complete:** Book data layer ready for UI integration in next phase.

---
*Phase: 02-book-data-layer*
*Completed: 2026-01-14*
