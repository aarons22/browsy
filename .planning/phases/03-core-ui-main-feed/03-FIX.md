---
phase: 03-core-ui-main-feed
plan: 03-FIX
type: fix
wave: 1
depends_on: []
files_modified: [androidApp/src/main/AndroidManifest.xml, shared/src/commonMain/kotlin/com/browsy/data/remote/GoogleBooksApi.kt, shared/src/commonMain/kotlin/com/browsy/data/repository/BookRepository.kt, iosApp/iosApp/FeedViewModel.swift, iosApp/iosApp/BookFeedView.swift]
autonomous: true
---

<objective>
Fix 5 UAT issues from phase 03.

Source: 03-UAT.md
Diagnosed: yes - root causes identified for all issues
Priority: 2 blocker, 1 major, 2 minor
</objective>

<execution_context>
@~/.claude/get-shit-done/workflows/execute-plan.md
@~/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@.planning/ROADMAP.md

**Issues being fixed:**
@.planning/phases/03-core-ui-main-feed/03-UAT.md

**Original plans for reference:**
@.planning/phases/03-core-ui-main-feed/03-01-PLAN.md
@.planning/phases/03-core-ui-main-feed/03-02-PLAN.md

**Source files:**
@iosApp/iosApp/BookFeedView.swift
@iosApp/iosApp/FeedViewModel.swift
@shared/src/commonMain/kotlin/com/browsy/data/remote/GoogleBooksApi.kt
@shared/src/commonMain/kotlin/com/browsy/data/repository/BookRepository.kt
@androidApp/src/main/AndroidManifest.xml
</context>

<tasks>
<task type="auto">
  <name>Task 1: Fix UAT-005 - Add INTERNET permission to Android</name>
  <files>androidApp/src/main/AndroidManifest.xml</files>
  <action>
**Root Cause:** AndroidManifest.xml missing INTERNET permission declaration
**Issue:** "app crashes on launch - FATAL EXCEPTION: SecurityException: Permission denied (missing INTERNET permission?)"
**Expected:** Android app launches and loads books from API

**Fix:** Add `<uses-permission android:name="android.permission.INTERNET" />` to AndroidManifest.xml before the `<application>` tag.
  </action>
  <verify>
- Build Android app: ./gradlew assembleDebug succeeds
- App launches without SecurityException crash
  </verify>
  <done>UAT-005 resolved - Android app has INTERNET permission and can make network requests</done>
</task>

<task type="auto">
  <name>Task 2: Fix UAT-003 - Add pagination startIndex to Google Books API</name>
  <files>shared/src/commonMain/kotlin/com/browsy/data/remote/GoogleBooksApi.kt, shared/src/commonMain/kotlin/com/browsy/data/repository/BookRepository.kt, iosApp/iosApp/FeedViewModel.swift, androidApp/src/main/java/com/browsy/android/ui/feed/FeedViewModel.kt</files>
  <action>
**Root Cause:** GoogleBooksApi.searchBooks() lacks startIndex parameter - each loadMoreBooks() call returns same first 20 results, causing duplicate IDs when appended to list
**Issue:** "no - when I get to the end, i see a white screen and no more books load. there are errors in the console: ForEach the ID cj0lhuzFSloC occurs multiple times within the collection"
**Expected:** New books load automatically as user approaches end of list

**Fix:**
1. **GoogleBooksApi.kt:** Add `startIndex: Int = 0` parameter to searchBooks() method. Add `parameter("startIndex", startIndex)` to the HTTP request.

2. **BookRepository.kt:** Update searchBooks() to accept startIndex parameter and pass it to GoogleBooksApi.

3. **iOS FeedViewModel.swift:** Track currentPage or startIndex. In loadMoreBooks(), calculate startIndex = books.count and pass to searchBooks(). Only append books that aren't already in the list (check by ID).

4. **Android FeedViewModel.kt:** Same pattern - track startIndex, pass to repository, deduplicate results.
  </action>
  <verify>
- Build succeeds for both platforms
- iOS: Swipe through 20+ books, new books load without duplicate ID errors
- Android: Same behavior after INTERNET permission fix
  </verify>
  <done>UAT-003 resolved - pagination uses startIndex to fetch next page of results</done>
</task>

<task type="auto">
  <name>Task 3: Fix UAT-001/002/004 - iOS layout and safe area issues</name>
  <files>iosApp/iosApp/BookFeedView.swift</files>
  <action>
**Root Cause:**
- (1) AsyncImage not configured for high-res loading
- (2) deprecated .edgesIgnoringSafeArea(.all) doesn't extend into safe areas properly
- (3) HStack layout lacks width constraints and truncation for text/button overflow

**Issues:**
- UAT-001: "quality of images is very poor; images fill screen horizontally, but they should bleed into the safe areas on the top and bottom"
- UAT-002: "text going off the side of the screen for some books"
- UAT-004: "TBR button gets pushed off the side of the screen"

**Expected:** Full-screen covers extending into safe areas, text/button stay within bounds

**Fix:**
1. **Safe area:** Replace `.edgesIgnoringSafeArea(.all)` with `.ignoresSafeArea()` on the image/background layer. Keep text overlay within safe area bounds.

2. **Text constraints:**
   - Add `.frame(maxWidth: .infinity, alignment: .leading)` to title/author VStack
   - Add `.lineLimit(2)` to title and `.lineLimit(1)` to author with `.truncationMode(.tail)`
   - Ensure TBR button has fixed size and doesn't get pushed off

3. **Layout structure:** Use a ZStack where:
   - Background/image layer ignores safe area
   - Text overlay respects safe area with proper padding

4. **Image quality:** AsyncImage should already request the large URL (mapper prefers large). If images are still poor quality, check that we're not downscaling. Use `.interpolation(.high)` if needed.
  </action>
  <verify>
- Build iOS app succeeds
- Covers extend to screen edges (into safe areas)
- Long titles truncate with "..." instead of pushing content off screen
- TBR button stays visible in corner regardless of title length
  </verify>
  <done>UAT-001/002/004 resolved - iOS layout properly handles safe areas and text overflow</done>
</task>
</tasks>

<verification>
Before declaring plan complete:
- [ ] All blocker issues fixed (UAT-003, UAT-005)
- [ ] All major issues fixed (UAT-001)
- [ ] Minor issues fixed (UAT-002, UAT-004)
- [ ] Each fix verified against original reported issue
- [ ] Both iOS and Android apps build successfully
</verification>

<success_criteria>
- All 5 UAT issues from 03-UAT.md addressed
- Builds pass for both platforms
- Ready for re-verification with /gsd:verify-work 3
</success_criteria>

<output>
After completion, create `.planning/phases/03-core-ui-main-feed/03-FIX-SUMMARY.md`
</output>
