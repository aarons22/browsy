import Foundation

/// Unified book data access layer with dual-API fallback strategy and in-memory caching.
///
/// This repository provides reliable book data by:
/// 1. Checking in-memory cache first for fast access
/// 2. Trying Google Books API (primary source for better metadata quality)
/// 3. Falling back to Open Library API if Google Books fails or has no results
/// 4. Caching successful results to reduce API calls
///
/// Dual-API strategy:
/// - Google Books: Primary source with rich metadata, cover images, and descriptions
/// - Open Library: Fallback for ISBN lookups when Google Books has no results
///
/// Caching behavior:
/// - Search results: Cached by query string (key: "search:query")
/// - ISBN lookups: Cached by ISBN (key: "isbn:1234567890")
/// - TTL: 30 minutes for all cached entries
/// - Size: 100 entries max with LRU eviction
public actor BookRepository {
    private let googleBooksAPI: GoogleBooksAPI
    private let openLibraryAPI: OpenLibraryAPI
    private let cache: BookCache

    public init(googleBooksApiKey: String) {
        self.googleBooksAPI = GoogleBooksAPI(apiKey: googleBooksApiKey)
        self.openLibraryAPI = OpenLibraryAPI()
        self.cache = BookCache()
    }

    /// Searches for books matching the given query.
    ///
    /// Search strategy:
    /// 1. Check cache for previously fetched results (only for first page)
    /// 2. Query Google Books API (supports full search syntax)
    /// 3. If Google Books returns no results, return empty array
    ///    (Open Library doesn't have general search, only ISBN lookup)
    /// 4. Cache first result for faster subsequent access
    ///
    /// - Parameters:
    ///   - query: Search query (supports Google Books query syntax: intitle:, inauthor:, isbn:, etc.)
    ///   - startIndex: Index of first result to return (for pagination, default 0)
    ///   - orderBy: Sort order: "newest" or "relevance" (default nil uses API default)
    /// - Returns: Array of matching books, or empty array if none found
    /// - Throws: Error if API request fails
    public func searchBooks(
        query: String,
        startIndex: Int = 0,
        orderBy: String? = nil
    ) async throws -> [Book] {
        // Check cache first (only for first page)
        if startIndex == 0 {
            let cacheKey = "search:\(query)"
            if let cached = await cache.get(cacheKey) {
                return [cached]
            }
        }

        // Try Google Books first
        do {
            let response = try await googleBooksAPI.searchBooks(
                query: query,
                startIndex: startIndex,
                orderBy: orderBy
            )

            let books = response.items?.map { GoogleBooksMapper.toBook(from: $0) } ?? []

            if !books.isEmpty {
                // Cache first result from first page only
                if startIndex == 0, let firstBook = books.first {
                    await cache.put("search:\(query)", firstBook)
                }
                return books
            }
        } catch {
            print("Google Books search failed: \(error)")
            // Fall through to return empty array
        }

        // Fallback to Open Library if Google Books failed or returned nothing
        // Open Library doesn't have general search, only ISBN lookup
        // For MVP, return empty array if Google Books has nothing
        return []
    }

    /// Fetches book details by ISBN with automatic API fallback.
    ///
    /// ISBN lookup strategy:
    /// 1. Check cache for previously fetched book
    /// 2. Try Google Books API (ISBN search)
    /// 3. If Google Books fails or has no results, try Open Library API
    /// 4. Cache successful result
    /// 5. Return nil if neither API has the book
    ///
    /// Accepts both ISBN-10 and ISBN-13 formats (with or without hyphens).
    ///
    /// - Parameter isbn: Book ISBN (10 or 13 digits, hyphens optional)
    /// - Returns: Book if found by either API, nil if not found by any API
    public func getBookByIsbn(_ isbn: String) async throws -> Book? {
        // Check cache
        let cacheKey = "isbn:\(isbn)"
        if let cached = await cache.get(cacheKey) {
            return cached
        }

        // Try Google Books first
        do {
            let response = try await googleBooksAPI.getBookByIsbn(isbn)
            if let item = response.items?.first {
                let book = GoogleBooksMapper.toBook(from: item)
                await cache.put(cacheKey, book)
                return book
            }
        } catch {
            print("Google Books ISBN lookup failed: \(error)")
        }

        // Fallback to Open Library
        do {
            if let data = try await openLibraryAPI.getBookByIsbn(isbn) {
                let book = OpenLibraryMapper.toBook(from: data, isbn: isbn)
                await cache.put(cacheKey, book)
                return book
            }
        } catch {
            print("Open Library ISBN lookup failed: \(error)")
        }

        // Neither API found the book
        return nil
    }
}
