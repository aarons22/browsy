# Phase 2: Book Data Layer - Discovery

**Phase:** 02-book-data-layer
**Discovery depth:** Standard (Level 2)
**Completed:** 2026-01-14

## Research Question

How do we integrate Open Library and Google Books APIs to fetch book metadata and covers in a Kotlin Multiplatform project?

## APIs Evaluated

### Open Library API

**Base URL:** `https://openlibrary.org/api/books`

**Pros:**
- Completely free, no API key required
- Rich metadata via `jscmd=data` parameter
- Dedicated Covers API with multiple sizes
- Multiple identifier support (ISBN, OCLC, LCCN, OLID)
- No authentication needed

**Cons:**
- Rate limit: 100 requests per IP every 5 minutes
- Less reliable uptime than commercial services
- Cover image quality varies
- No crawling allowed

**Request format:**
```
https://openlibrary.org/api/books?bibkeys=ISBN:0451526538&format=json&jscmd=data
```

**Response includes:**
- Title, subtitle, authors
- ISBN, LCCN, OCLC identifiers
- Publishers, publication dates
- Subjects, classifications
- Cover images (small, medium, large)
- Page count, excerpts

**Covers API:**
```
https://covers.openlibrary.org/b/$key/$value-$size.jpg
```
- Sizes: S (small), M (medium), L (large)
- Keys: ISBN, OLID, OCLC, LCCN, ID
- Rate limit: 100 requests per IP per 5 minutes

### Google Books API

**Base URL:** `https://www.googleapis.com/books/v1/volumes`

**Pros:**
- More reliable uptime
- Better search capabilities
- Larger cover images available
- More consistent metadata quality
- Higher rate limits with API key

**Cons:**
- Requires API key (free tier available)
- OAuth 2.0 needed for user-specific data
- Pagination limited to 40 results max
- Some books have limited preview

**Request format:**
```
https://www.googleapis.com/books/v1/volumes?q=intitle:lord+of+the+rings&key=YOUR_API_KEY
```

**Search features:**
- Field-specific: `intitle:`, `inauthor:`, `isbn:`, `subject:`
- Exact phrases with quotes
- Exclusion with minus sign

**Response includes:**
- volumeInfo with title, authors, publisher
- imageLinks with thumbnail to extra-large sizes
- ISBN identifiers
- Page count, ratings, publication date
- Categories, description

## Recommended Stack

### HTTP Client: Ktor

**Why Ktor:**
- Official Kotlin Multiplatform HTTP client
- Async/await with coroutines
- Platform-specific engines (OkHttp for Android, Darwin for iOS)
- Built-in JSON support with kotlinx.serialization

**Dependencies:**
```kotlin
commonMain {
    implementation("io.ktor:ktor-client-core:2.3.7")
    implementation("io.ktor:ktor-client-content-negotiation:2.3.7")
    implementation("io.ktor:ktor-serialization-kotlinx-json:2.3.7")
}
androidMain {
    implementation("io.ktor:ktor-client-okhttp:2.3.7")
}
iosMain {
    implementation("io.ktor:ktor-client-darwin:2.3.7")
}
```

### Serialization: kotlinx.serialization

**Why kotlinx.serialization:**
- Official Kotlin serialization library
- Full multiplatform support
- Compile-time safety
- JSON, Protobuf, CBOR support

**Setup:**
- Plugin: `org.jetbrains.kotlin.plugin.serialization`
- Dependency: `org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.2`

## Data Models

### Book Model (Shared)
```kotlin
@Serializable
data class Book(
    val id: String,
    val title: String,
    val author: String,
    val coverUrl: String?,
    val description: String?,
    val publishedDate: String?,
    val pageCount: Int?,
    val isbn: String?,
    val subjects: List<String>
)
```

### API Response Models
```kotlin
// Open Library
@Serializable
data class OpenLibraryResponse(
    @SerialName("ISBN:...")
    val bookData: BookData
)

// Google Books
@Serializable
data class GoogleBooksResponse(
    val items: List<VolumeItem>
)
```

## Caching Strategy

### In-Memory Cache
- Use Kotlin `Map` for recently accessed books
- LRU eviction with max 100 entries
- Cache cover URLs, not images themselves

### Platform-Specific Storage (Future)
- Android: Room database
- iOS: CoreData or SQLDelight
- Defer to Phase 4+ based on actual needs

## API Selection Strategy

**Primary:** Google Books API
- Better reliability and uptime
- More consistent metadata quality
- Higher rate limits

**Fallback:** Open Library
- When Google Books returns no results
- For books with missing covers in Google Books
- No API key needed for backup

**Implementation:**
1. Try Google Books first
2. If no results or error, fall back to Open Library
3. Merge results if both return data (prefer Google Books metadata)

## Common Pitfalls

1. **Rate limiting:** Don't crawl covers; cache URLs instead of fetching repeatedly
2. **Missing covers:** Always handle null/blank cover images gracefully
3. **ISBN formats:** Support both ISBN-10 and ISBN-13
4. **API keys:** Google Books key required; use environment variable, never hardcode
5. **Network errors:** Implement retry logic with exponential backoff
6. **JSON parsing:** Handle partial/malformed responses without crashing

## Next Steps

1. Add Ktor and kotlinx.serialization dependencies
2. Create data models for Book and API responses
3. Implement BookRepository with dual-API strategy
4. Add in-memory cache for book metadata
5. Create cover image loading utilities

## Sources

- [Open Library Books API](https://openlibrary.org/dev/docs/api/books)
- [Open Library Covers API](https://openlibrary.org/dev/docs/api/covers)
- [Google Books API - Using the API](https://developers.google.com/books/docs/v1/using)
- [Ktor Multiplatform Documentation](https://ktor.io/docs/client-create-multiplatform-application.html)
- [kotlinx.serialization Documentation](https://kotlinlang.org/docs/serialization.html)
