# Migration Plan: Kotlin Multiplatform to Native iOS & Android

## Executive Summary

This document provides a comprehensive plan for migrating the Browsy app from Kotlin Multiplatform Mobile (KMP) to fully native iOS (Swift) and Android (Kotlin/JVM) implementations. This migration will eliminate KMP complexity while maintaining feature parity.

## Current Architecture

### Shared Module (KMP)
- **Location**: `/shared/src/commonMain`
- **Components**:
  - Data models: `Book`, `SavedBook`, `BookShelf`, `BookCover`
  - API clients: `GoogleBooksApi`, `OpenLibraryApi`
  - DTOs: `GoogleBooksResponse`, `OpenLibraryBookData`
  - Mappers: `GoogleBooksMapper`, `OpenLibraryMapper`
  - Repositories: `BookRepository`, `LocalBookShelfRepository`
  - Utilities: `BookCache`, `FeedStrategy`, `ImageUrlEnhancer`
  - Storage: `LocalBookShelfStorage`

### iOS App
- **Framework**: SwiftUI
- **Dependencies**: Consumes KMP shared module as framework
- **Views**: `BookFeedView`, `BookInfoSheet`, `ContentView`
- **ViewModels**: `FeedViewModel`, `ShelfViewModel` (consume shared module)

### Android App
- **Framework**: Jetpack Compose
- **Dependencies**: Consumes KMP shared module as AAR
- **Views**: `BookFeedScreen`, `BookInfoBottomSheet`
- **ViewModels**: `FeedViewModel`, `ShelfViewModel` (consume shared module)

## Migration Strategy

### Phase 1: Create Native Swift Shared Logic

#### 1.1 iOS Project Structure Setup

Instead of a separate Swift package, shared logic will be integrated directly into the iOS project:

```bash
# Create directory structure within iOS project
iosApp/Browsy/
├── Browsy/
│   ├── BrowsyApp.swift
│   ├── Models/
│   │   ├── Book.swift
│   │   ├── BookShelf.swift
│   │   ├── SavedBook.swift
│   │   └── BookCover.swift
│   ├── API/
│   │   ├── DTOs/
│   │   │   ├── GoogleBooksDTO.swift
│   │   │   └── OpenLibraryDTO.swift
│   │   ├── GoogleBooksAPI.swift
│   │   ├── OpenLibraryAPI.swift
│   │   └── Mappers/
│   │       ├── GoogleBooksMapper.swift
│   │       └── OpenLibraryMapper.swift
│   ├── Cache/
│   │   └── BookCache.swift
│   ├── Repository/
│   │   ├── BookRepository.swift
│   │   ├── LocalBookShelfStorage.swift
│   │   └── LocalBookShelfRepository.swift
│   ├── Feed/
│   │   └── FeedStrategy.swift
│   ├── Utilities/
│   │   └── ImageUrlEnhancer.swift
│   ├── Views/
│   │   ├── BookFeedView.swift
│   │   ├── BookInfoSheet.swift
│   │   └── ContentView.swift
│   └── ViewModels/
│       ├── FeedViewModel.swift
│       └── ShelfViewModel.swift
└── BrowsyTests/
```

**Project Configuration**:
- Platform: iOS 26.0+ minimum deployment target
- No external dependencies (use native URLSession)
- All shared logic as part of main app target

#### 1.2 Data Models Migration

Files to create in `Browsy/Models/`:

**Book.swift**:
```swift
public struct Book: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let author: String
    public let coverUrl: String?
    public let description: String?
    public let publishedDate: String?
    public let pageCount: Int?
    public let isbn: String?
    public let subjects: [String]
}
```

**BookShelf.swift**:
```swift
public enum BookShelf: String, Codable {
    case tbr = "TBR"
    case recommend = "RECOMMEND"
    case read = "READ"
}
```

**SavedBook.swift**:
```swift
public struct SavedBook: Codable, Equatable {
    public let bookId: String
    public let shelf: BookShelf
    public let savedAt: Int64
}
```

**BookCover.swift**:
```swift
public struct BookCover: Equatable {
    public let small: String?
    public let medium: String?
    public let large: String?

    public static func fromUrl(_ url: String) -> BookCover
    public static let empty: BookCover
}
```

#### 1.3 API DTOs Migration

Files to create in `Browsy/API/DTOs/`:

**GoogleBooksDTO.swift**:
```swift
public struct GoogleBooksResponse: Codable {
    public let items: [VolumeItem]?
    public let totalItems: Int
}

public struct VolumeItem: Codable {
    public let id: String
    public let volumeInfo: VolumeInfo
}

public struct VolumeInfo: Codable {
    public let title: String
    public let authors: [String]?
    public let description: String?
    public let publishedDate: String?
    public let pageCount: Int?
    public let categories: [String]?
    public let imageLinks: ImageLinks?
    public let industryIdentifiers: [IndustryIdentifier]?
}

public struct ImageLinks: Codable {
    public let thumbnail: String?
    public let smallThumbnail: String?
    public let small: String?
    public let medium: String?
    public let large: String?
    public let extraLarge: String?
}

public struct IndustryIdentifier: Codable {
    public let type: String
    public let identifier: String
}
```

**OpenLibraryDTO.swift**:
```swift
public struct OpenLibraryBookData: Codable {
    public let title: String
    public let subtitle: String?
    public let authors: [Author]?
    public let publishers: [Publisher]?
    public let publishDate: String?
    public let numberOfPages: Int?
    public let subjects: [Subject]?
    public let cover: Cover?
    public let identifiers: Identifiers?

    enum CodingKeys: String, CodingKey {
        case title, subtitle, authors, publishers, subjects, cover, identifiers
        case publishDate = "publish_date"
        case numberOfPages = "number_of_pages"
    }
}

public struct Author: Codable {
    public let name: String
    public let url: String?
}

public struct Publisher: Codable {
    public let name: String
}

public struct Subject: Codable {
    public let name: String
    public let url: String?
}

public struct Cover: Codable {
    public let small: String?
    public let medium: String?
    public let large: String?
}

public struct Identifiers: Codable {
    public let isbn13: [String]?
    public let isbn10: [String]?
    public let oclc: [String]?
    public let lccn: [String]?

    enum CodingKeys: String, CodingKey {
        case isbn13 = "isbn_13"
        case isbn10 = "isbn_10"
        case oclc, lccn
    }
}
```

#### 1.4 API Clients Migration

Files to create in `Browsy/API/`:

**GoogleBooksAPI.swift**:
```swift
public actor GoogleBooksAPI {
    private let apiKey: String
    private let baseURL = URL(string: "https://www.googleapis.com/books/v1/volumes")!
    private let session: URLSession

    public init(apiKey: String) {
        self.apiKey = apiKey
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    public func searchBooks(
        query: String,
        maxResults: Int = 20,
        startIndex: Int = 0,
        orderBy: String? = nil
    ) async throws -> GoogleBooksResponse {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "startIndex", value: "\(startIndex)"),
            URLQueryItem(name: "key", value: apiKey)
        ]

        if let orderBy = orderBy {
            components.queryItems?.append(URLQueryItem(name: "orderBy", value: orderBy))
        }

        let (data, response) = try await session.data(from: components.url!)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode(GoogleBooksResponse.self, from: data)
    }

    public func getBookByIsbn(_ isbn: String) async throws -> GoogleBooksResponse {
        return try await searchBooks(query: "isbn:\(isbn)", maxResults: 1)
    }
}

public enum APIError: Error {
    case invalidResponse
    case networkError(Error)
}
```

**OpenLibraryAPI.swift**:
```swift
public actor OpenLibraryAPI {
    private let booksURL = URL(string: "https://openlibrary.org/api/books")!
    private let coversURL = "https://covers.openlibrary.org/b"
    private let session: URLSession

    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    public func getBookByIsbn(_ isbn: String) async throws -> OpenLibraryBookData? {
        var components = URLComponents(url: booksURL, resolvingAgainstBaseURL: false)!
        let bibkey = "ISBN:\(isbn)"
        components.queryItems = [
            URLQueryItem(name: "bibkeys", value: bibkey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "jscmd", value: "data")
        ]

        let (data, response) = try await session.data(from: components.url!)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let bookDataDict = json?[bibkey] as? [String: Any] else {
            return nil  // Book not found
        }

        let bookData = try JSONSerialization.data(withJSONObject: bookDataDict)
        let decoder = JSONDecoder()
        return try decoder.decode(OpenLibraryBookData.self, from: bookData)
    }

    public func getCoverUrl(isbn: String, size: String = "L") -> String {
        return "\(coversURL)/isbn/\(isbn)-\(size).jpg"
    }
}
```

#### 1.5 Mappers Migration

Files to create in `Browsy/API/Mappers/`:

**GoogleBooksMapper.swift**:
```swift
public struct GoogleBooksMapper {
    public static func toBook(from item: VolumeItem) -> Book {
        let volumeInfo = item.volumeInfo

        // Extract best cover URL
        let coverUrl = volumeInfo.imageLinks?.large
            ?? volumeInfo.imageLinks?.medium
            ?? volumeInfo.imageLinks?.small
            ?? volumeInfo.imageLinks?.thumbnail

        // Get ISBN-13 or ISBN-10
        let isbn = volumeInfo.industryIdentifiers?.first(where: { $0.type == "ISBN_13" })?.identifier
            ?? volumeInfo.industryIdentifiers?.first(where: { $0.type == "ISBN_10" })?.identifier

        return Book(
            id: item.id,
            title: volumeInfo.title,
            author: volumeInfo.authors?.first ?? "Unknown Author",
            coverUrl: ImageUrlEnhancer.enhance(coverUrl),
            description: volumeInfo.description,
            publishedDate: volumeInfo.publishedDate,
            pageCount: volumeInfo.pageCount,
            isbn: isbn,
            subjects: volumeInfo.categories ?? []
        )
    }
}
```

**OpenLibraryMapper.swift**:
```swift
public struct OpenLibraryMapper {
    public static func toBook(from data: OpenLibraryBookData, isbn: String) -> Book {
        let coverUrl = data.cover?.large ?? data.cover?.medium ?? data.cover?.small

        return Book(
            id: "OL_\(isbn)",
            title: data.title,
            author: data.authors?.first?.name ?? "Unknown Author",
            coverUrl: ImageUrlEnhancer.enhance(coverUrl),
            description: nil,  // Open Library doesn't provide descriptions in this endpoint
            publishedDate: data.publishDate,
            pageCount: data.numberOfPages,
            isbn: isbn,
            subjects: data.subjects?.map { $0.name } ?? []
        )
    }
}
```

#### 1.6 Utilities Migration

Files to create in `Browsy/Utilities/`:

**ImageUrlEnhancer.swift**:
```swift
public struct ImageUrlEnhancer {
    public static func enhance(_ originalUrl: String?) -> String? {
        guard let url = originalUrl else { return nil }

        if url.contains("books.google.com/books/content") {
            return enhanceGoogleBooksUrl(url)
        } else if url.contains("covers.openlibrary.org") {
            return enhanceOpenLibraryUrl(url)
        } else {
            return url
        }
    }

    private static func enhanceGoogleBooksUrl(_ url: String) -> String {
        return url
            .replacingOccurrences(of: "zoom=5", with: "zoom=0")
            .replacingOccurrences(of: "zoom=1", with: "zoom=0")
            .replacingOccurrences(of: "&edge=curl", with: "")
            .replacingOccurrences(of: "edge=curl&", with: "")
            .replacingOccurrences(of: "http://", with: "https://")
    }

    private static func enhanceOpenLibraryUrl(_ url: String) -> String {
        if url.contains("-S.jpg") {
            return url.replacingOccurrences(of: "-S.jpg", with: "-L.jpg")
        } else if url.contains("-M.jpg") {
            return url.replacingOccurrences(of: "-M.jpg", with: "-L.jpg")
        } else {
            return url
        }
    }
}
```

#### 1.7 Cache Migration

Files to create in `Browsy/Cache/`:

**BookCache.swift**:
```swift
public actor BookCache {
    private var cache: [String: CacheEntry] = [:]
    private let maxEntries: Int
    private let ttlMilliseconds: Int64

    public init(maxEntries: Int = 100, ttlMinutes: Int = 30) {
        self.maxEntries = maxEntries
        self.ttlMilliseconds = Int64(ttlMinutes * 60 * 1000)
    }

    public func get(_ key: String) -> Book? {
        guard let entry = cache[key] else { return nil }

        let now = Date().timeIntervalSince1970 * 1000
        if Int64(now) - entry.timestamp > ttlMilliseconds {
            cache.removeValue(forKey: key)
            return nil
        }

        return entry.book
    }

    public func put(_ key: String, _ book: Book) {
        if cache.count >= maxEntries {
            evictOldest()
        }

        cache[key] = CacheEntry(
            book: book,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
    }

    public func clear() {
        cache.removeAll()
    }

    private func evictOldest() {
        guard let oldestKey = cache.min(by: { $0.value.timestamp < $1.value.timestamp })?.key else {
            return
        }
        cache.removeValue(forKey: oldestKey)
    }

    private struct CacheEntry {
        let book: Book
        let timestamp: Int64
    }
}
```

#### 1.8 Repository Migration

Files to create in `Browsy/Repository/`:

**BookRepository.swift**:
```swift
public actor BookRepository {
    private let googleBooksAPI: GoogleBooksAPI
    private let openLibraryAPI: OpenLibraryAPI
    private let cache: BookCache

    public init(googleBooksApiKey: String) {
        self.googleBooksAPI = GoogleBooksAPI(apiKey: googleBooksApiKey)
        self.openLibraryAPI = OpenLibraryAPI()
        self.cache = BookCache()
    }

    public func searchBooks(
        query: String,
        startIndex: Int = 0,
        orderBy: String? = nil
    ) async throws -> [Book] {
        // Check cache for first page
        if startIndex == 0 {
            if let cachedBook = await cache.get("search:\(query)") {
                return [cachedBook]
            }
        }

        // Try Google Books
        do {
            let response = try await googleBooksAPI.searchBooks(
                query: query,
                startIndex: startIndex,
                orderBy: orderBy
            )

            let books = response.items?.map { GoogleBooksMapper.toBook(from: $0) } ?? []

            if !books.isEmpty && startIndex == 0 {
                if let firstBook = books.first {
                    await cache.put("search:\(query)", firstBook)
                }
            }

            return books
        } catch {
            print("Google Books search failed: \(error)")
            return []
        }
    }

    public func getBookByIsbn(_ isbn: String) async throws -> Book? {
        // Check cache
        if let cachedBook = await cache.get("isbn:\(isbn)") {
            return cachedBook
        }

        // Try Google Books first
        do {
            let response = try await googleBooksAPI.getBookByIsbn(isbn)
            if let item = response.items?.first {
                let book = GoogleBooksMapper.toBook(from: item)
                await cache.put("isbn:\(isbn)", book)
                return book
            }
        } catch {
            print("Google Books ISBN lookup failed: \(error)")
        }

        // Fallback to Open Library
        do {
            if let data = try await openLibraryAPI.getBookByIsbn(isbn) {
                let book = OpenLibraryMapper.toBook(from: data, isbn: isbn)
                await cache.put("isbn:\(isbn)", book)
                return book
            }
        } catch {
            print("Open Library ISBN lookup failed: \(error)")
        }

        return nil
    }
}
```

#### 1.9 Feed Strategy Migration

Files to create in `Browsy/Feed/`:

**FeedStrategy.swift**:
```swift
public struct FeedStrategy {
    private static let smartQueries: [(String, String?)] = [
        ("subject:fiction orderBy:newest", nil),
        ("subject:fiction", "relevance"),
        ("subject:fantasy", "relevance"),
        ("subject:science fiction", "relevance"),
        ("subject:mystery", "relevance")
    ]

    public static func getSmartQuery(loadCount: Int) -> (String, String?) {
        let index = loadCount % smartQueries.count
        return smartQueries[index]
    }
}
```

#### 1.10 Local Storage Migration

Files to create in `Browsy/Repository/`:

**LocalBookShelfStorage.swift**:
```swift
public actor LocalBookShelfStorage {
    private let userDefaults: UserDefaults
    private let key = "saved_books"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func saveBook(_ book: SavedBook) throws {
        var books = try loadAll()

        // Remove existing entry if present
        books.removeAll { $0.bookId == book.bookId && $0.shelf == book.shelf }

        // Add new entry
        books.append(book)

        let encoder = JSONEncoder()
        let data = try encoder.encode(books)
        userDefaults.set(data, forKey: key)
    }

    public func removeBook(bookId: String, shelf: BookShelf) throws {
        var books = try loadAll()
        books.removeAll { $0.bookId == bookId && $0.shelf == shelf }

        let encoder = JSONEncoder()
        let data = try encoder.encode(books)
        userDefaults.set(data, forKey: key)
    }

    public func loadAll() throws -> [SavedBook] {
        guard let data = userDefaults.data(forKey: key) else {
            return []
        }

        let decoder = JSONDecoder()
        return try decoder.decode([SavedBook].self, from: data)
    }

    public func loadByShelf(_ shelf: BookShelf) throws -> [SavedBook] {
        return try loadAll().filter { $0.shelf == shelf }
    }
}
```

**LocalBookShelfRepository.swift**:
```swift
public actor LocalBookShelfRepository {
    private let storage: LocalBookShelfStorage

    public init(storage: LocalBookShelfStorage = LocalBookShelfStorage()) {
        self.storage = storage
    }

    public func addToShelf(bookId: String, shelf: BookShelf) async throws {
        let savedBook = SavedBook(
            bookId: bookId,
            shelf: shelf,
            savedAt: Int64(Date().timeIntervalSince1970 * 1000)
        )
        try await storage.saveBook(savedBook)
    }

    public func removeFromShelf(bookId: String, shelf: BookShelf) async throws {
        try await storage.removeBook(bookId: bookId, shelf: shelf)
    }

    public func getBooksOnShelf(_ shelf: BookShelf) async throws -> [SavedBook] {
        return try await storage.loadByShelf(shelf)
    }

    public func isBookOnShelf(bookId: String, shelf: BookShelf) async throws -> Bool {
        let books = try await storage.loadByShelf(shelf)
        return books.contains { $0.bookId == bookId }
    }
}
```

### Phase 2: Create New Native iOS Project (iOS 26+)

#### 2.1 Xcode Project Setup

1. **Create new Xcode project**:
   - Template: iOS App
   - Interface: SwiftUI
   - Language: Swift
   - Minimum deployment: iOS 26.0
   - Location: `iosApp/Browsy/`

2. **Create directory structure** as outlined in Phase 1.1 above

3. **Configure Info.plist**:
   ```xml
   <key>GoogleBooksAPIKey</key>
   <string>$(GOOGLE_BOOKS_API_KEY)</string>
   ```

4. **Create xcconfig files** for API key management:
   ```
   # Development.xcconfig
   GOOGLE_BOOKS_API_KEY = your_dev_key_here
   ```

#### 2.2 Migrate iOS Views

**Update ViewModels**:
- Remove `import shared`
- All shared logic is now part of the same target, no imports needed
- Update API calls to use Swift async/await
- Remove KMP-specific type conversions

**FeedViewModel.swift** (updated):
```swift
import Foundation

@MainActor
class FeedViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let repository: BookRepository
    private var currentPage = 0
    private var loadCount = 0
    private var currentQuery = "fantasy"

    init(apiKey: String) {
        self.repository = BookRepository(googleBooksApiKey: apiKey)
    }

    func loadInitialBooks() async {
        guard !isLoading else { return }

        isLoading = true
        currentPage = 0

        do {
            let (query, orderBy) = FeedStrategy.getSmartQuery(loadCount: loadCount)
            currentQuery = query

            books = try await repository.searchBooks(
                query: query,
                startIndex: 0,
                orderBy: orderBy
            )

            loadCount += 1
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func loadMoreBooks() async {
        guard !isLoading else { return }

        isLoading = true

        do {
            let newBooks = try await repository.searchBooks(
                query: currentQuery,
                startIndex: books.count
            )

            let existingIds = Set(books.map { $0.id })
            let uniqueNewBooks = newBooks.filter { !existingIds.contains($0.id) }
            books.append(contentsOf: uniqueNewBooks)
            currentPage += 1
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
```

#### 2.3 Update Build Configuration

**Build Settings**:
- Remove all KMP-specific build phases
- Remove framework search paths pointing to `shared/build/`
- Remove Run Script phases for Gradle

**Info.plist**:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

### Phase 3: Create New Android Project

#### 3.1 Create Clean Slate Android Project

Following the requirement to start fresh with a new Android project:

1. **Create new Android project in Android Studio**:
   - File → New → New Project
   - Template: Empty Activity (Compose)
   - Language: Kotlin
   - Minimum SDK: 24
   - Target SDK: 34
   - Package: com.browsy.android
   - Location: Create outside existing repo initially

2. **Set up project structure**:
   ```
   browsy-android/
   ├── app/
   │   ├── src/main/
   │   │   ├── kotlin/com/browsy/android/
   │   │   │   ├── MainActivity.kt
   │   │   │   ├── BrowsyApplication.kt
   │   │   │   ├── models/
   │   │   │   ├── api/
   │   │   │   ├── cache/
   │   │   │   ├── repository/
   │   │   │   ├── feed/
   │   │   │   ├── utilities/
   │   │   │   ├── ui/
   │   │   │   │   ├── feed/
   │   │   │   │   ├── info/
   │   │   │   │   └── theme/
   │   │   │   └── viewmodels/
   │   │   └── AndroidManifest.xml
   │   └── build.gradle.kts
   ├── settings.gradle.kts
   └── build.gradle.kts
   ```

3. **Integrate all code in the main app module** (no separate shared module needed):
   - All shared logic goes directly in the app module
   - Organized by package rather than module
   - Simpler project structure, easier to maintain

#### 3.2 Port Shared Logic to New Android Project

**app/build.gradle.kts**:
```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.serialization")
}

android {
    namespace = "com.browsy.android"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.browsy.android"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.8"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    // Kotlin Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

    // Ktor for networking
    implementation("io.ktor:ktor-client-okhttp:2.3.7")
    implementation("io.ktor:ktor-client-content-negotiation:2.3.7")
    implementation("io.ktor:ktor-serialization-kotlinx-json:2.3.7")

    // Kotlinx Serialization
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.2")

    // Compose
    implementation(platform("androidx.compose:compose-bom:2024.01.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.foundation:foundation")

    // Android Core
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")

    // Image loading
    implementation("io.coil-kt:coil-compose:2.5.0")

    // Debug
    debugImplementation("androidx.compose.ui:ui-tooling")
}
```

**Key Changes from KMP**:
1. Keep Kotlin code from `shared/src/commonMain/`
2. Replace platform-specific code from `shared/src/androidMain/`
3. Use OkHttp instead of Ktor's platform-specific client
4. Use Android SharedPreferences for storage

**LocalBookShelfStorage.kt** (Android-specific):
```kotlin
class LocalBookShelfStorage(private val context: Context) {
    private val prefs = context.getSharedPreferences("browsy_shelves", Context.MODE_PRIVATE)
    private val key = "saved_books"
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    fun saveBook(book: SavedBook) {
        val books = loadAll().toMutableList()
        books.removeAll { it.bookId == book.bookId && it.shelf == book.shelf }
        books.add(book)

        val jsonString = json.encodeToString(ListSerializer(SavedBook.serializer()), books)
        prefs.edit().putString(key, jsonString).apply()
    }

    fun loadAll(): List<SavedBook> {
        val jsonString = prefs.getString(key, null) ?: return emptyList()
        return json.decodeFromString(ListSerializer(SavedBook.serializer()), jsonString)
    }

    fun loadByShelf(shelf: BookShelf): List<SavedBook> {
        return loadAll().filter { it.shelf == shelf }
    }
}
```

#### 3.3 Copy and Update Code

**Migration Process**:

1. **Copy Kotlin models, APIs, repositories** from `shared/src/commonMain/` to new project:
   - Place in appropriate packages under `com.browsy.android`
   - No module separation needed - all in app module

2. **Copy UI code** from `androidApp/src/main/`:
   - Compose UI components go to `ui/` package
   - ViewModels go to `viewmodels/` package
   - Theme stays in `ui/theme/`

3. **Update imports**:
   - Change `import com.browsy.` to `import com.browsy.android.`
   - No more shared module imports needed

**Update ViewModels**:
```kotlin
package com.browsy.android.viewmodels

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.browsy.android.repository.BookRepository
import com.browsy.android.models.Book
import com.browsy.android.feed.FeedStrategy

class FeedViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = BookRepository.create(
        googleBooksApiKey = BuildConfig.GOOGLE_BOOKS_API_KEY
    )

    // Rest of implementation stays the same
}
```

#### 3.4 Configuration

**settings.gradle.kts** (simple, single module):
```kotlin
rootProject.name = "Browsy"
include(":app")
```

**local.properties**:
```properties
sdk.dir=/path/to/android/sdk
google.books.api.key=your_api_key_here
```

### Phase 4: Remove KMP Infrastructure

#### 4.1 Delete KMP Files

```bash
# Remove shared KMP module entirely
rm -rf shared/

# Remove old iOS KMP-based Xcode project
rm -rf iosApp/iosApp.xcodeproj
rm -rf iosApp/iosApp/  # Old KMP iOS app

# Remove old Android KMP-based app
rm -rf androidApp/

# Remove BrowsyShared Swift package (not needed with new approach)
rm -rf iosApp/BrowsyShared/
```

#### 4.2 Clean Up Root Gradle Files (if keeping any shared repo structure)

Note: Since we're creating completely separate projects, you may not need root Gradle files at all.

If you want to keep the repo structure with both projects:

**build.gradle.kts**:
```kotlin
plugins {
    alias(libs.plugins.androidApplication) apply false
    alias(libs.plugins.androidLibrary) apply false
    alias(libs.plugins.kotlinAndroid) apply false
    alias(libs.plugins.compose.compiler) apply false
    // Remove: alias(libs.plugins.kotlinMultiplatform) apply false
}
```

**gradle/libs.versions.toml**:
Remove KMP-specific dependencies:
```toml
[plugins]
# Remove kotlinMultiplatform
# Remove buildkonfig
```

#### 4.3 Update .gitignore

```gitignore
# iOS
iosApp/Browsy/*.xcodeproj/xcuserdata/
iosApp/Browsy/*.xcodeproj/project.xcworkspace/xcuserdata/
iosApp/Browsy/DerivedData/
*.xcconfig  # Don't commit API keys

# Android
androidApp/build/
androidShared/build/
.gradle/
local.properties

# Remove KMP-specific ignores
# shared/build/
```

### Phase 5: Update Documentation

#### 5.1 Update PROJECT_STRUCTURE.md

Replace KMP architecture description with:

```markdown
# Browsy - Project Structure

## Overview

Native iOS (Swift) and Android (Kotlin/JVM) applications with platform-specific shared logic modules.

## Modules

### iOS App: Browsy
- **Location**: `iosApp/Browsy/`
- **Framework**: SwiftUI
- **Minimum iOS**: 18.0
- **Dependencies**: BrowsyShared (Swift Package)

### BrowsyShared (Swift Package)
- **Location**: `iosApp/BrowsyShared/`
- **Purpose**: Shared business logic for iOS
- **Components**: Models, API clients, repositories, utilities

### Android App: androidApp
- **Location**: `androidApp/`
- **Framework**: Jetpack Compose
- **Minimum SDK**: 24
- **Dependencies**: androidShared module

### androidShared (Android Library)
- **Location**: `androidShared/`
- **Purpose**: Shared business logic for Android
- **Components**: Models, API clients, repositories, utilities
```

#### 5.2 Update README.md

Update build instructions:

```markdown
## Building

### iOS (macOS only)
```bash
# Open in Xcode
open iosApp/Browsy/Browsy.xcodeproj

# Or build from command line
xcodebuild -project iosApp/Browsy/Browsy.xcodeproj \
  -scheme Browsy \
  -configuration Debug \
  build
```

### Android
```bash
# Build debug APK
./gradlew :androidApp:assembleDebug

# Install on device
./gradlew :androidApp:installDebug
```
```

#### 5.3 Update CLAUDE.md

Remove KMP-specific content and update to reflect native architecture:

```markdown
# Browsy Architectural Philosophy

## Native Development Priority

Browsy uses native iOS (Swift) and Android (Kotlin/JVM) implementations to ensure the best possible user experience.

### Development Approach

**iOS Development**:
- Swift 5.10+ with async/await
- SwiftUI for UI
- Native URLSession for networking
- UserDefaults for local storage
- Swift Package Manager for shared logic

**Android Development**:
- Kotlin with Coroutines
- Jetpack Compose for UI
- Ktor + OkHttp for networking
- SharedPreferences for local storage
- Gradle for dependency management

### Shared Logic Strategy

Each platform maintains its own shared logic module:
- iOS: BrowsyShared Swift Package
- Android: androidShared Gradle module

Code is duplicated but optimized for each platform's idioms and best practices.
```

### Phase 6: Testing & Validation

#### 6.1 iOS Testing Checklist

- [ ] Swift package builds successfully
- [ ] All models conform to required protocols
- [ ] API clients successfully fetch data
- [ ] Cache works correctly
- [ ] Repository layer integrates properly
- [ ] ViewModels compile and run
- [ ] App launches and displays book feed
- [ ] Infinite scroll works
- [ ] Book info sheet displays
- [ ] User shelves work

#### 6.2 Android Testing Checklist

- [ ] androidShared module builds
- [ ] All data classes are properly serializable
- [ ] API clients work with OkHttp
- [ ] Storage uses SharedPreferences correctly
- [ ] ViewModels integrate with Compose
- [ ] App launches and displays book feed
- [ ] Infinite scroll works
- [ ] Bottom sheet displays
- [ ] User shelves work

#### 6.3 Feature Parity Validation

Compare with original KMP implementation:
- [ ] All book search features work
- [ ] ISBN lookup works
- [ ] Image URL enhancement works
- [ ] Feed strategy rotation works
- [ ] Caching improves performance
- [ ] All three shelves (TBR, RECOMMEND, READ) work
- [ ] Data persists across app restarts

## Implementation Timeline

### Week 1: Swift Implementation
- Days 1-2: Models, DTOs, utilities
- Days 3-4: API clients and mappers
- Day 5: Repository and cache

### Week 2: iOS App Migration
- Days 1-2: New Xcode project setup
- Days 3-4: Migrate ViewModels and Views
- Day 5: Testing and bug fixes

### Week 3: Android Migration
- Days 1-2: Create androidShared module
- Days 3-4: Port shared logic
- Day 5: Update app integration

### Week 4: Cleanup & Documentation
- Days 1-2: Remove KMP infrastructure
- Days 3-4: Update all documentation
- Day 5: Final testing and validation

## Risk Mitigation

### Risks & Mitigation Strategies

1. **Feature Gaps**
   - Risk: Missing features during migration
   - Mitigation: Create comprehensive checklist, test each feature

2. **API Behavior Differences**
   - Risk: Native URLSession/OkHttp behave differently than Ktor
   - Mitigation: Extensive integration testing with real APIs

3. **Storage Migration**
   - Risk: Users lose saved books during migration
   - Mitigation: Implement data migration scripts for both platforms

4. **Build Configuration**
   - Risk: API keys not properly configured
   - Mitigation: Document xcconfig and gradle.properties setup clearly

## Success Criteria

Migration is complete when:
- [ ] Both apps build without errors
- [ ] All features from KMP version work
- [ ] No KMP dependencies remain
- [ ] Documentation is updated
- [ ] Performance is equal or better than KMP version
- [ ] Code is properly tested
- [ ] API keys are properly managed
- [ ] All shared logic is platform-optimized

## Rollback Plan

If migration fails or takes too long:
1. Keep KMP branch available
2. Can revert to KMP at any time
3. Migration can be done incrementally (iOS first, then Android)

## Notes

- This migration eliminates KMP complexity
- Each platform can use its native best practices
- Code is duplicated but optimized for each platform
- Maintenance may require updating both codebases
- Future consideration: Share logic via backend services instead
