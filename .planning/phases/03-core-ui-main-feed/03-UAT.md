---
status: diagnosed
phase: 03-core-ui-main-feed
source: 03-01-SUMMARY.md, 03-02-SUMMARY.md
started: 2026-01-15T15:00:00Z
updated: 2026-01-15T15:10:00Z
---

## Current Test

[testing complete]

## Tests

### 1. iOS Vertical Swipe Navigation
expected: Launch iOS app. Swipe up/down to navigate between books. Each swipe snaps to show exactly one book at a time (full screen).
result: pass

### 2. iOS Book Cover Display
expected: Book covers display full-screen with no borders or gaps. Images fill the screen and maintain quality (not pixelated or stretched).
result: issue
reported: "quality of images is very poor; images fill screen horizontally, but they should bleed into the safe areas on the top and bottom to get a true full screen experience; the book text and favorite button sometimes get pushed off the side of the screen"
severity: major
root_cause: (1) AsyncImage not configured for high-res loading; (2) deprecated .edgesIgnoringSafeArea(.all) doesn't extend into safe areas properly - needs .ignoresSafeArea(); (3) HStack layout lacks width constraints and truncation for text/button overflow

### 3. iOS Title/Author Overlay
expected: Each book shows title and author text overlaid at bottom of screen with a gradient background for readability.
result: issue
reported: "yes, but there are issues with the text going off the side of the screen for some books"
severity: minor
root_cause: Text views lack .frame(maxWidth: .infinity) constraint and proper truncation mode - long titles push content off screen

### 4. iOS Infinite Scroll
expected: Continue swiping through books. New books load automatically as you approach the end (no "load more" button needed).
result: issue
reported: "no - when I get to the end, i see a white screen and no more books load. there are errors in the console: ForEach the ID cj0lhuzFSloC occurs multiple times within the collection; LazyVStackLayout: the ID is used by multiple child views"
severity: blocker
root_cause: GoogleBooksApi.searchBooks() lacks startIndex parameter for pagination - each loadMoreBooks() call returns same first 20 results, causing duplicate IDs when appended to list

### 5. iOS TBR Button Visible
expected: A heart button is visible in the corner of each book screen. (It won't do anything yet - just checking it's there.)
result: issue
reported: "yes, but similar to the book title, it gets pushed off the side of the screen for some books"
severity: minor
root_cause: Same HStack layout issue as UAT-002/003 - button pushed off by unconstrained text width

### 6. Android Vertical Swipe Navigation
expected: Launch Android app. Swipe up/down to navigate between books. Each swipe snaps to show exactly one book at a time (full screen).
result: issue
reported: "app crashes on launch - FATAL EXCEPTION: SecurityException: Permission denied (missing INTERNET permission?)"
severity: blocker
root_cause: AndroidManifest.xml missing <uses-permission android:name="android.permission.INTERNET" /> declaration

### 7. Android Book Cover Display
expected: Book covers display full-screen with no borders or gaps. Images fill the screen and maintain quality (not pixelated or stretched).
result: skipped
reason: Android app crashes on launch (UAT-005)

### 8. Android Title/Author Overlay
expected: Each book shows title and author text overlaid at bottom of screen with a gradient background for readability.
result: skipped
reason: Android app crashes on launch (UAT-005)

### 9. Android Infinite Scroll
expected: Continue swiping through books. New books load automatically as you approach the end (no "load more" button needed).
result: skipped
reason: Android app crashes on launch (UAT-005)

### 10. Android TBR Button Visible
expected: A heart button is visible in the corner of each book screen. (It won't do anything yet - just checking it's there.)
result: skipped
reason: Android app crashes on launch (UAT-005)

## Summary

total: 10
passed: 1
issues: 5
pending: 0
skipped: 4

## Issues for /gsd:plan-fix

- UAT-001: iOS cover display issues - poor image quality, doesn't extend into safe areas, text/button overflow (major) - Test 2
  root_cause: AsyncImage not configured for high-res; deprecated .edgesIgnoringSafeArea(); HStack lacks width constraints

- UAT-002: iOS text overlay goes off screen for some books (minor) - Test 3
  root_cause: Text views lack .frame(maxWidth: .infinity) and truncation mode

- UAT-003: iOS infinite scroll broken - white screen at end, duplicate ID errors (blocker) - Test 4
  root_cause: GoogleBooksApi.searchBooks() lacks startIndex parameter - returns same 20 books each pagination call

- UAT-004: iOS TBR button gets pushed off screen for some books (minor) - Test 5
  root_cause: Same HStack layout issue - button pushed off by unconstrained text

- UAT-005: Android app crashes on launch - missing INTERNET permission (blocker) - Test 6
  root_cause: AndroidManifest.xml missing INTERNET permission declaration
