# Phase 3: Core UI - Main Feed - Research

**Researched:** 2026-01-15
**Domain:** SwiftUI + Jetpack Compose vertical paging with high-quality image display
**Confidence:** HIGH

<research_summary>
## Summary

Researched the native SwiftUI and Jetpack Compose ecosystems for building a TikTok-style vertical swipe feed with full-screen book covers, snap-to-position behavior, and infinite scroll pagination.

**Key findings:**
- iOS 17+ provides native vertical paging via `ScrollView` with `scrollTargetBehavior(.paging)` and `containerRelativeFrame` for full-screen layouts
- Jetpack Compose has official `VerticalPager` in `androidx.compose.foundation` (Accompanist Pager is deprecated)
- For KMP image loading, Coil 3 is the clear winner - official multiplatform support, caching, coroutine-based
- Don't hand-roll: paging mechanics, snap behavior, image caching/loading, or gesture systems

**Primary recommendation:** Use native platform paging APIs (SwiftUI ScrollView paging for iOS, Compose VerticalPager for Android) with Coil 3 for unified KMP image loading. Prioritize image quality settings and implement pagination for memory efficiency.
</research_summary>

<standard_stack>
## Standard Stack

### Core - iOS (SwiftUI)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI ScrollView | iOS 17+ | Native vertical paging | Built-in paging with scrollTargetBehavior(.paging) |
| containerRelativeFrame | iOS 17+ | Full-screen sizing | Native way to size views relative to scroll container |
| AsyncImage or 3rd-party | iOS 15+ | Image loading | Native for simple cases, Kingfisher/Nuke for advanced features |

### Core - Android (Compose)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| VerticalPager | compose.foundation 1.9+ | Native vertical paging | Official Compose pager with snap behavior |
| PagerState | compose.foundation 1.9+ | Pager state management | Tracks currentPage, settledPage, handles animations |
| Coil 3 | 3.3.0 | Image loading | KMP support, coroutine-based, lightweight |

### Cross-Platform (KMP)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Coil 3 | 3.3.0 | Image loading for KMP | Official KMP support, works with iOS + Android + Compose Multiplatform |
| Ktor | 2.3.7+ | Network engine for Coil | Already in project, needed for Coil's network module |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Coil 3 | Kamel | Kamel is KMP-native but Coil 3 has better ecosystem support |
| Native image loading | SDWebImage (iOS) / Glide (Android) | Platform-specific means duplicated logic, Coil 3 unifies |
| ScrollView paging | TabView + PageTabViewStyle | TabView works but ScrollView is more flexible for custom layouts |
| VerticalPager | Custom LazyColumn | Custom approach misses built-in snap, fling, and animation logic |

**Installation:**

For iOS (SwiftUI native - no extra dependencies needed):
```swift
// iOS 17+ features are built-in
import SwiftUI
```

For Android (Compose Foundation):
```kotlin
// Already included in Compose Foundation
implementation("androidx.compose.foundation:foundation:1.9.0+")
```

For KMP Image Loading (Coil 3):
```kotlin
// build.gradle.kts (shared module)
commonMain.dependencies {
    implementation("io.coil-kt.coil3:coil:3.3.0")
    implementation("io.coil-kt.coil3:coil-compose:3.3.0")
    implementation("io.coil-kt.coil3:coil-network-ktor:3.3.0")
}
```
</standard_stack>

<architecture_patterns>
## Architecture Patterns

### Recommended Project Structure
```
shared/src/
├── commonMain/kotlin/
│   ├── ui/
│   │   ├── feed/
│   │   │   ├── FeedViewModel.kt          # Shared feed logic
│   │   │   └── FeedState.kt              # Feed state data class
│   │   └── components/
│   │       └── BookCoverImage.kt         # KMP image loading wrapper
│   └── domain/
│       └── pagination/
│           └── BookPaginator.kt          # Pagination logic
├── iosMain/
│   └── ui/
│       └── feed/
│           └── BookFeedView.swift        # SwiftUI feed implementation
└── androidMain/
    └── ui/
        └── feed/
            └── BookFeedScreen.kt         # Compose feed implementation
```

### Pattern 1: SwiftUI Vertical Paging with ScrollView (iOS 17+)

**What:** Native vertical paging using ScrollView with scrollTargetBehavior and containerRelativeFrame
**When to use:** iOS 17+ apps requiring full-screen vertical paging
**Example:**
```swift
// Source: Apple Developer Documentation + Swift with Majid blog
ScrollView(.vertical) {
    LazyVStack(spacing: 0) {
        ForEach(books) { book in
            BookCoverView(book: book)
                .containerRelativeFrame([.horizontal, .vertical])
        }
    }
    .scrollTargetLayout()
}
.scrollTargetBehavior(.paging)
.scrollIndicators(.hidden)
```

**Key points:**
- `containerRelativeFrame([.horizontal, .vertical])` makes each book fill the screen
- `spacing: 0` in LazyVStack prevents scroll offset issues
- `.scrollTargetLayout()` on container enables paging snap points
- `.scrollTargetBehavior(.paging)` enables page-by-page snapping

### Pattern 2: Jetpack Compose VerticalPager

**What:** Official Compose VerticalPager with snap behavior and state management
**When to use:** All Android Compose implementations
**Example:**
```kotlin
// Source: Official Android Developer Documentation
val pagerState = rememberPagerState(pageCount = { books.size })

VerticalPager(
    state = pagerState,
    pageSpacing = 0.dp,
    beyondBoundsPageCount = 1  // Preload 1 page ahead
) { page ->
    BookCoverCard(
        book = books[page],
        modifier = Modifier.fillMaxSize()
    )
}

// React to page changes
LaunchedEffect(pagerState) {
    snapshotFlow { pagerState.currentPage }
        .collect { page ->
            viewModel.onPageChanged(page)
        }
}
```

**Key points:**
- Default fling behavior snaps one page at a time
- `beyondBoundsPageCount` controls preloading for smooth scrolling
- Use `snapshotFlow` to react to page changes for analytics/state updates

### Pattern 3: High-Quality Image Loading with Coil 3

**What:** Cross-platform image loading with caching and quality optimization
**When to use:** All image loading in KMP shared code
**Example:**
```kotlin
// Source: Coil 3 official documentation
@Composable
fun BookCoverImage(
    coverUrl: String,
    modifier: Modifier = Modifier
) {
    AsyncImage(
        model = ImageRequest.Builder(LocalContext.current)
            .data(coverUrl)
            .crossfade(true)
            .memoryCachePolicy(CachePolicy.ENABLED)
            .diskCachePolicy(CachePolicy.ENABLED)
            .size(Size.ORIGINAL)  // Preserve original quality
            .build(),
        contentDescription = "Book cover",
        contentScale = ContentScale.Fit,
        modifier = modifier
    )
}
```

**Key points:**
- Enable both memory and disk cache policies
- Use `Size.ORIGINAL` to preserve image quality (per user priority)
- `crossfade(true)` for smooth image transitions
- Coil handles background thread loading automatically via coroutines

### Pattern 4: Infinite Scroll Pagination

**What:** Load books in chunks as user scrolls to manage memory
**When to use:** All feed implementations to prevent memory exhaustion
**Example:**
```kotlin
// Source: Best practices from mobile pagination research
class BookPaginator(
    private val pageSize: Int = 20,
    private val prefetchDistance: Int = 5
) {
    private var currentPage = 0
    private var isLoading = false

    fun shouldLoadNextPage(currentIndex: Int, totalLoaded: Int): Boolean {
        return !isLoading &&
               currentIndex >= totalLoaded - prefetchDistance
    }

    suspend fun loadNextPage(): List<Book> {
        if (isLoading) return emptyList()

        isLoading = true
        val books = repository.getBooks(
            page = currentPage,
            pageSize = pageSize
        )
        currentPage++
        isLoading = false

        return books
    }
}
```

**Key points:**
- Load 20 books at a time (configurable)
- Prefetch when user is 5 books from end
- Prevent concurrent loads with `isLoading` flag
- Handle errors gracefully with retry mechanism

### Anti-Patterns to Avoid

- **Loading all books upfront**: Causes memory exhaustion with large datasets. Always paginate.
- **Not using keys in LazyVStack/VerticalPager**: Causes unnecessary recompositions and poor scroll performance.
- **Missing beyondBoundsPageCount**: Images appear while scrolling instead of being preloaded.
- **Using .frame() instead of containerRelativeFrame**: Doesn't adapt to different screen sizes properly.
- **Custom gesture recognizers for paging**: Native paging APIs handle edge cases, fling physics, and accessibility.
- **Loading images synchronously**: Blocks UI thread and causes jank. Always use async image loaders.
</architecture_patterns>

<dont_hand_roll>
## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Vertical paging mechanics | Custom ScrollView + gesture logic | ScrollView + scrollTargetBehavior (iOS) / VerticalPager (Android) | Snap physics, fling behavior, edge bounce, and accessibility are complex |
| Image caching | Custom URLCache wrapper | Coil 3, Kingfisher, or Nuke | Memory management, disk persistence, LRU eviction, cancellation all non-trivial |
| Full-screen sizing | Manual GeometryReader calculations | containerRelativeFrame (iOS) / Modifier.fillMaxSize() (Android) | Native APIs handle safe areas, rotation, and iPad split-view correctly |
| Snap-to-position | Custom drag gesture + animation | Built-in paging snap | Velocity calculations, deceleration curves, and interruption handling are subtle |
| Image loading indicators | Custom loading states | AsyncImage placeholder / Coil placeholders | Handles retry, error states, crossfade, and cancellation automatically |
| Infinite scroll detection | Manual scroll offset tracking | LazyVStack/VerticalPager + onAppear triggers | Preloading distance, duplicate requests, and race conditions need careful handling |

**Key insight:** Both iOS and Android have invested heavily in native paging APIs specifically for feeds like TikTok/Instagram Reels. Custom implementations miss subtle details like:
- Proper fling physics and deceleration
- Snap interruption when user grabs mid-animation
- VoiceOver/TalkBack navigation
- Right-to-left layout support
- Memory warnings and view recycling
- Edge cases like device rotation during scroll
</dont_hand_roll>

<common_pitfalls>
## Common Pitfalls

### Pitfall 1: Image Memory Exhaustion

**What goes wrong:** App crashes after scrolling through 50-100 books due to memory warnings
**Why it happens:** Loading all images into memory without cache limits or pagination
**How to avoid:**
- Use pagination (load 20 books at a time)
- Enable Coil's memory/disk cache with limits
- Use `beyondBoundsPageCount = 1` (don't preload too many pages)
- On iOS, prefer Kingfisher/Nuke over AsyncImage for better memory management in feeds
**Warning signs:** Memory usage steadily climbing in Xcode/Android Profiler, app crashes on older devices

### Pitfall 2: Image Quality Degradation

**What goes wrong:** Book covers look blurry or pixelated despite high-res source images
**Why it happens:** Image loaders downsample by default to save memory
**How to avoid:**
- Use `Size.ORIGINAL` in Coil ImageRequest (or equivalent in other loaders)
- Request "large" size covers from book APIs (already implemented in Phase 2)
- Set `contentScale = ContentScale.Fit` to preserve aspect ratio
- Use `Bitmap.Config.ARGB_8888` for highest quality (Coil default)
**Warning signs:** Covers look blurry on high-DPI devices, pinch-to-zoom reveals low resolution

### Pitfall 3: Jank During Scroll

**What goes wrong:** Feed stutters or drops frames when swiping between books
**Why it happens:** Images loading on main thread, missing preloading, or too many simultaneous loads
**How to avoid:**
- Use `beyondBoundsPageCount = 1` to preload adjacent pages
- Ensure image loading is async (Coil does this automatically)
- Implement pagination to limit total items in memory
- On iOS, avoid heavy view logic in LazyVStack cells
**Warning signs:** Dropped frames in Instruments/GPU profiler, delayed image appearance

### Pitfall 4: Pagination Race Conditions

**What goes wrong:** Duplicate books appear, or same page loads twice, or pagination breaks
**Why it happens:** Multiple pagination triggers fire before previous load completes
**How to avoid:**
- Use `isLoading` flag to prevent concurrent requests
- Debounce pagination triggers (wait for previous to settle)
- Use unique keys for each book (book.id) to detect duplicates
- Handle failed loads with retry mechanism
**Warning signs:** Duplicate books in feed, incorrect page count, missing books in sequence

### Pitfall 5: Device Rotation Breaks Paging

**What goes wrong:** After rotating device, paging offset is wrong or scroll position lost
**Why it happens:** SwiftUI doesn't auto-realign on size class change; Compose handles better
**How to avoid:**
- On iOS: Apply `.id(sizeClass)` to ScrollView to force recalculation on rotation
- Preserve scroll position using ScrollViewReader or PagerState
- Use containerRelativeFrame which adapts to new container size
**Warning signs:** Books halfway between pages after rotation, lost scroll position

### Pitfall 6: Missing Keys in Lazy Containers

**What goes wrong:** Poor scroll performance, items re-render unnecessarily, state lost during scroll
**Why it happens:** LazyVStack/VerticalPager reuses views without stable identity
**How to avoid:**
- Always use `ForEach(books, id: \.id)` in SwiftUI
- Always use `key = { books[it].id }` in Compose VerticalPager
- Ensure book IDs are truly unique and stable
**Warning signs:** Images flash/reload during scroll, poor scroll framerate, lost view state
</common_pitfalls>

<code_examples>
## Code Examples

Verified patterns from official sources:

### SwiftUI Full-Screen Vertical Feed

```swift
// Source: Apple Developer Docs + Swift with Majid
// https://swiftwithmajid.com/2025/01/28/container-relative-frames-in-swiftui/
// https://developer.apple.com/documentation/swiftui/scrolltargetbehavior

struct BookFeedView: View {
    @StateObject var viewModel: FeedViewModel
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.books, id: \.id) { book in
                    BookCoverCard(book: book)
                        .containerRelativeFrame([.horizontal, .vertical])
                        .onAppear {
                            viewModel.onBookAppear(book)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .id(sizeClass)  // Force recalc on rotation
    }
}
```

### Compose VerticalPager with Preloading

```kotlin
// Source: Official Android Developer Documentation
// https://developer.android.com/develop/ui/compose/layouts/pager

@Composable
fun BookFeedScreen(
    books: List<Book>,
    onBookChanged: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    val pagerState = rememberPagerState(pageCount = { books.size })

    VerticalPager(
        state = pagerState,
        pageSpacing = 0.dp,
        beyondBoundsPageCount = 1,
        key = { books[it].id },
        modifier = modifier.fillMaxSize()
    ) { page ->
        BookCoverCard(
            book = books[page],
            modifier = Modifier.fillMaxSize()
        )
    }

    LaunchedEffect(pagerState) {
        snapshotFlow { pagerState.settledPage }
            .collect { page -> onBookChanged(page) }
    }
}
```

### KMP Image Loading with Quality Priority

```kotlin
// Source: Coil 3 documentation
// https://coil-kt.github.io/coil/compose/

@Composable
fun BookCoverImage(
    coverUrl: String,
    contentDescription: String,
    modifier: Modifier = Modifier
) {
    val context = LocalPlatformContext.current

    AsyncImage(
        model = ImageRequest.Builder(context)
            .data(coverUrl)
            .crossfade(300)
            .memoryCachePolicy(CachePolicy.ENABLED)
            .diskCachePolicy(CachePolicy.ENABLED)
            .size(Size.ORIGINAL)  // User priority: quality over performance
            .build(),
        contentDescription = contentDescription,
        contentScale = ContentScale.Fit,
        modifier = modifier,
        placeholder = painterResource(Res.drawable.book_placeholder),
        error = painterResource(Res.drawable.book_error)
    )
}
```

### Pagination State Management

```kotlin
// Source: Mobile pagination best practices
// https://www.justinmind.com/ui-design/infinite-scroll

class FeedViewModel : ViewModel() {
    private val paginator = BookPaginator(pageSize = 20)

    private val _books = MutableStateFlow<List<Book>>(emptyList())
    val books: StateFlow<List<Book>> = _books.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    fun onBookAppear(book: Book) {
        val index = _books.value.indexOf(book)
        if (paginator.shouldLoadNextPage(index, _books.value.size)) {
            loadNextPage()
        }
    }

    private fun loadNextPage() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val newBooks = paginator.loadNextPage()
                _books.value += newBooks
            } catch (e: Exception) {
                // Handle error, show retry
            } finally {
                _isLoading.value = false
            }
        }
    }
}
```
</code_examples>

<sota_updates>
## State of the Art (2024-2025)

What's changed recently:

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| TabView + PageTabViewStyle (iOS) | ScrollView + scrollTargetBehavior | iOS 17 (2023) | More flexible, works with any content, better customization |
| Accompanist Pager (Compose) | Official VerticalPager/HorizontalPager | Compose 1.4 (2023) | No extra dependency, official support, better maintained |
| Platform-specific image loaders | Coil 3 (KMP) | Coil 3.0 (late 2024) | Single library across platforms, less code duplication |
| Kingfisher/SDWebImage (iOS only) | Coil 3 multiplatform | Coil 3.0 (2024) | Cross-platform code sharing for image loading |

**New tools/patterns to consider:**
- **containerRelativeFrame (iOS 17+)**: Modern alternative to GeometryReader for responsive sizing - cleaner API, better performance
- **Coil 3 KMP support**: Full multiplatform image loading means shared image loading logic between iOS and Android
- **scrollTargetBehavior protocol (iOS 17+)**: Custom scroll behaviors beyond basic paging - enables advanced scroll interactions
- **Compose VerticalPager snap customization**: Fine-tune snap distance and fling behavior for custom scroll feel

**Deprecated/outdated:**
- **Accompanist Pager**: Replaced by official androidx.compose.foundation pagers - migrate to VerticalPager
- **TabView for complex feeds**: Still works but ScrollView is more flexible for custom layouts
- **GeometryReader for sizing**: containerRelativeFrame is cleaner for responsive layouts (iOS 17+)
- **Custom paging gestures**: Native APIs now handle all edge cases - don't reinvent

**iOS version targeting note:**
- iOS 17+ features (scrollTargetBehavior, containerRelativeFrame) are the modern approach
- For iOS 16 support, fall back to TabView + PageTabViewStyle (still works, just less flexible)
- Project targets iOS 16.0, so plan should include conditional logic or reconsider minimum version
</sota_updates>

<open_questions>
## Open Questions

Things that couldn't be fully resolved:

1. **iOS 16 vs iOS 17 Targeting Decision**
   - What we know: Project currently targets iOS 16.0 (from Phase 1), but best SwiftUI paging is iOS 17+
   - What's unclear: Should we bump minimum to iOS 17, or implement dual approach (iOS 17 ScrollView, iOS 16 TabView fallback)?
   - Recommendation: Check user's target audience. If most users on iOS 17+, bump minimum. Otherwise, implement fallback using TabView + PageTabViewStyle for iOS 16.

2. **Cover Image Optimal Resolution**
   - What we know: Google Books provides small/medium/large/extraLarge, Open Library has various sizes
   - What's unclear: What resolution is "large enough" for modern iPhone/Android screens without wasting bandwidth?
   - Recommendation: During planning, test actual device screen sizes. Likely "large" (typically 800px+) is sufficient for most devices. ExtraLarge may be overkill.

3. **Pagination Prefetch Distance**
   - What we know: Too small = user sees loading, too large = memory issues
   - What's unclear: Optimal prefetch distance for this specific use case
   - Recommendation: Start with 5 books prefetch, measure in testing, adjust based on memory pressure and user scroll speed

4. **Image Cache Size Limits**
   - What we know: Coil has default cache limits, but book covers are large images
   - What's unclear: What memory/disk cache sizes prevent memory warnings while supporting smooth scrolling?
   - Recommendation: Start with Coil defaults (memory: 20% of available, disk: 250 MB), monitor in testing, tune as needed
</open_questions>

<sources>
## Sources

### Primary (HIGH confidence)

**SwiftUI:**
- [Apple Developer - ScrollTargetBehavior](https://developer.apple.com/documentation/swiftui/scrolltargetbehavior) - Official scrollTargetBehavior API
- [Apple Developer - Paging](https://developer.apple.com/documentation/swiftui/scrolltargetbehavior/paging) - Official paging behavior docs
- [WWDC23 Beyond Scroll Views](https://developer.apple.com/videos/play/wwdc2023/10159/) - Official Apple WWDC session
- [Swift with Majid - Container Relative Frames](https://swiftwithmajid.com/2025/01/28/container-relative-frames-in-swiftui/) - Verified implementation guide

**Jetpack Compose:**
- [Android Developer - Pager in Compose](https://developer.android.com/develop/ui/compose/layouts/pager) - Official VerticalPager documentation
- [Composables.com - VerticalPager](https://composables.com/foundation/verticalpager) - Official API reference

**Image Loading:**
- [Coil Official Docs](https://coil-kt.github.io/coil/) - Official Coil 3 documentation
- [Coil 3 Compose](https://coil-kt.github.io/coil/compose/) - Official Compose integration docs
- [Android Developer - Loading Images in Compose](https://developer.android.com/develop/ui/compose/graphics/images/loading) - Official Android guidance

### Secondary (MEDIUM confidence)

**SwiftUI Patterns:**
- [Hacking with Swift - Scrolling Pages](https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-scrolling-pages-of-content-using-tabviewstyle) - TabView patterns
- [Hacking with Swift - Vertical Page Scrolling](https://www.hackingwithswift.com/quick-start/swiftui/how-to-enable-vertical-page-scrolling) - Vertical paging guide
- [Medium - TikTok Swiping ScrollView iOS 17+](https://ipryhara.medium.com/tik-tok-like-swiping-scroll-view-in-swiftui-ios-17-1f58f0c86a0f) - Verified TikTok-style implementation
- [Fat Bober Man - Custom Paging](https://fatbobman.com/en/posts/mastering-swiftui-scrolling-implementing-custom-paging/) - Advanced paging patterns
- [Fat Bober Man - containerRelativeFrame](https://fatbobman.com/en/posts/mastering-the-containerrelativeframe-modifier-in-swiftui/) - containerRelativeFrame deep dive

**Compose Patterns:**
- [Medium - Exploring Official Pager](https://medium.com/@domen.lanisnik/exploring-the-official-pager-in-compose-8c2698c49a98) - VerticalPager implementation guide
- [Medium - Accompanist is Dead](https://medium.com/@hiren6997/accompanist-is-dead-heres-what-you-should-use-instead-37b6d9d23554) - Migration from Accompanist

**Image Loading:**
- [Medium - Coil in KMP](https://medium.com/@santosh_yadav321/coil-image-loading-in-kotlin-multiplatform-kmp-with-compose-multiplatform-ui-android-ios-483e416af64f) - KMP integration guide
- [Colin White - Coil 3 Release](https://colinwhite.me/post/coil_3_release/) - Coil 3 feature overview
- [SwiftLee - Downloading and Caching Images](https://www.avanderlee.com/swiftui/downloading-caching-images/) - iOS image caching patterns

**Performance & Best Practices:**
- [Justinmind - Infinite Scroll Best Practices](https://www.justinmind.com/ui-design/infinite-scroll) - UX research on infinite scroll
- [LogRocket - Pagination vs Infinite Scroll](https://blog.logrocket.com/ux-design/pagination-vs-infinite-scroll-ux/) - UX patterns
- [Medium - LazyVStack Performance](https://medium.com/@viralswift/mastering-swiftui-lazyvstack-lazyhstack-optimized-layouts-for-large-content-534141cfa41f) - Performance optimization
- [Medium - Memory Leaks in Compose](https://medium.com/@mahesh31.ambekar/avoiding-memory-leaks-in-android-jetpack-compose-%EF%B8%8F-4b5e9ba1b861) - Compose memory management

### Tertiary (LOW confidence - needs validation)
- None - all critical findings verified with official sources or cross-referenced
</sources>

<metadata>
## Metadata

**Research scope:**
- Core technology: SwiftUI (iOS 17+) + Jetpack Compose (Foundation 1.9+)
- Ecosystem: Coil 3 for KMP, native paging APIs
- Patterns: Vertical paging, infinite scroll, image quality optimization, memory management
- Pitfalls: Memory exhaustion, image quality, scroll jank, pagination races

**Confidence breakdown:**
- Standard stack: HIGH - Official docs from Apple and Google, verified Coil 3 KMP support
- Architecture: HIGH - Code examples from official docs and verified community implementations
- Pitfalls: HIGH - Cross-referenced performance docs, community reports, official optimization guides
- Code examples: HIGH - Sourced from official documentation and verified tutorials

**Research date:** 2026-01-15
**Valid until:** 2026-02-15 (30 days - iOS and Compose ecosystems are stable)

**iOS version consideration:** Project targets iOS 16.0 but best APIs are iOS 17+. Planning should address this.
</metadata>

---

*Phase: 03-core-ui-main-feed*
*Research completed: 2026-01-15*
*Ready for planning: yes*
