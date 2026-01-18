---
status: diagnosed
phase: 04-book-info-actions
source: 04-01-SUMMARY.md, 04-02-PLAN.md, 04-03-PLAN.md
started: 2026-01-18T09:15:00Z
updated: 2026-01-18T09:25:00Z
---

## Current Test

[testing complete - issues recorded]

## Tests

### 1. iOS - Info Sheet Display
expected: Tap book cover, info sheet slides up showing book details
result: issue
reported: "first book I tap always shows a blank white sheet. going to another book and tapping fixes this, and then the original book then works"
severity: major

### 2. iOS - TBR State Sync (Detail → Feed)
expected: Tap TBR in detail sheet, heart icon on feed updates to filled state
result: issue
reported: "the TBR state isn't synced with the button on the feed. I can tap the heart icon on the feed and it syncs to the detail sheet, but not vice versa"
severity: major

### 3. iOS - TBR Persistence
expected: TBR state persists after dismiss and reopen
result: pass

### 4. iOS - Recommend/Read Persistence
expected: Recommend and Read states persist after dismiss/reopen
result: pass

### 5. Android - Books Loading
expected: Books load and display in feed
result: issue
reported: "it's not moving beyond the 'Loading books...' screen"
severity: blocker

### 6. Android - Info Sheet Display
expected: Tap book cover, bottom sheet slides up showing book details
result: skipped
reason: blocked by issue #5 (books not loading)

### 7. Android - TBR State Sync
expected: TBR state syncs between feed and detail sheet
result: skipped
reason: blocked by issue #5

### 8. Android - Action Persistence
expected: TBR/Recommend/Read states persist after dismiss/reopen
result: skipped
reason: blocked by issue #5

## Summary

total: 8
passed: 2
issues: 3
pending: 0
skipped: 3

## Gaps

- truth: "Tap book cover shows info sheet with book details"
  status: failed
  reason: "User reported: first book I tap always shows a blank white sheet. going to another book and tapping fixes this, and then the original book then works"
  severity: major
  test: 1
  root_cause: "Using .sheet(isPresented:) with separate selectedBook state creates race condition. Sheet can render before selectedBook is set, causing 'if let book = selectedBook' to fail and show empty content."
  artifacts:
    - path: "iosApp/iosApp/BookFeedView.swift"
      issue: "Lines 38-44: sheet(isPresented:) with optional selectedBook binding"
  missing:
    - "Use .sheet(item:) modifier instead, which binds presentation to optional Book directly"

- truth: "TBR state syncs from detail sheet to feed heart icon"
  status: failed
  reason: "User reported: the TBR state isn't synced with the button on the feed. I can tap the heart icon on the feed and it syncs to the detail sheet, but not vice versa"
  severity: major
  test: 2
  root_cause: "BookCoverCard and BookInfoSheet each create separate @StateObject ShelfViewModel instances. When TBR is toggled in detail sheet, it updates repository but feed's ShelfViewModel doesn't reload."
  artifacts:
    - path: "iosApp/iosApp/BookFeedView.swift"
      issue: "Line 52: BookCoverCard has own @StateObject shelfViewModel"
    - path: "iosApp/iosApp/BookInfoSheet.swift"
      issue: "Line 6: BookInfoSheet has own @StateObject shelfViewModel"
  missing:
    - "Reload feed card shelf state when sheet dismisses via onDismiss callback"

- truth: "Android app loads and displays books in feed"
  status: failed
  reason: "User reported: it's not moving beyond the 'Loading books...' screen"
  severity: blocker
  test: 5
  root_cause: "API call failing silently or hanging. Missing loading state UI when isLoading=true AND books.isEmpty(). BookFeedScreen.kt line 80-91 has logical gap - no UI for initial loading state."
  artifacts:
    - path: "androidApp/src/main/java/com/browsy/android/ui/feed/BookFeedScreen.kt"
      issue: "Lines 80-109: Missing loading state when books.isEmpty() && isLoading"
    - path: "androidApp/src/main/java/com/browsy/android/ui/feed/FeedViewModel.kt"
      issue: "Lines 57-76: Errors logged to println but no user-visible error handling"
  missing:
    - "Add proper loading spinner when isLoading is true"
    - "Add error state UI when API call fails"
    - "Add network error logging to diagnose API issues"
