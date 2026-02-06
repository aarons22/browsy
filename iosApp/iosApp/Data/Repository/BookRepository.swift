import Foundation

/// Unified book data access layer with dual-API fallback strategy and in-memory caching.
///
/// This repository provides reliable book data by:
/// 1. Checking in-memory cache first for fast access
/// 2. Trying Google Books API (primary source for better metadata quality)
/// 3. Falling back to Open Library API if Google Books fails or has no results
/// 4. Caching successful results to reduce API calls
class BookRepository {
    private let googleBooksApi: GoogleBooksApi
    private let openLibraryApi: OpenLibraryApi
    private let cache: BookCache
    
    init(googleBooksApi: GoogleBooksApi, openLibraryApi: OpenLibraryApi, cache: BookCache = BookCache()) {
        self.googleBooksApi = googleBooksApi
        self.openLibraryApi = openLibraryApi
        self.cache = cache
    }
    
    /// Searches for books matching the given query.
    ///
    /// Search strategy:
    /// 1. Check cache for previously fetched results (only for first page)
    /// 2. Query Google Books API (supports full search syntax)
    /// 3. If Google Books returns no results, return empty list
    func searchBooks(
        query: String,
        startIndex: Int = 0,
        orderBy: String? = nil
    ) async -> Result<[Book], Error> {
        // Check cache first (only for first page)
        if startIndex == 0 {
            let cacheKey = "search:\(query)"
            if let cachedBook = cache.get(cacheKey) {
                return .success([cachedBook])
            }
        }
        
        // Try Google Books first
        do {
            let response = try await googleBooksApi.searchBooks(
                query: query,
                startIndex: startIndex,
                orderBy: orderBy
            )
            
            let books = (response.items ?? []).map { GoogleBooksMapper.toBook(from: $0) }
            
            if !books.isEmpty {
                // Cache first result from first page only
                if startIndex == 0, let firstBook = books.first {
                    cache.put("search:\(query)", book: firstBook)
                }
                return .success(books)
            }
        } catch {
            print("BookRepository: Google Books search failed: \(error)")
        }
        
        // For MVP, return empty list if Google Books has nothing
        // (Open Library doesn't have general search, only ISBN lookup)
        return .success([])
    }
    
    /// Swift-compatible overload for searchBooks without orderBy parameter.
    func searchBooks(query: String, startIndex: Int) async -> Result<[Book], Error> {
        return await searchBooks(query: query, startIndex: startIndex, orderBy: nil)
    }
    
    /// Fetches book details by ISBN with automatic API fallback.
    func getBookByIsbn(_ isbn: String) async -> Result<Book?, Error> {
        // Check cache
        let cacheKey = "isbn:\(isbn)"
        if let cachedBook = cache.get(cacheKey) {
            return .success(cachedBook)
        }
        
        // Try Google Books first
        do {
            let response = try await googleBooksApi.getBookByIsbn(isbn)
            if let volumeItem = response.items?.first {
                let book = GoogleBooksMapper.toBook(from: volumeItem)
                cache.put(cacheKey, book: book)
                return .success(book)
            }
        } catch {
            print("BookRepository: Google Books ISBN lookup failed: \(error)")
        }
        
        // Fallback to Open Library
        do {
            if let bookData = try await openLibraryApi.getBookByIsbn(isbn) {
                let book = OpenLibraryMapper.toBook(from: bookData, isbn: isbn)
                cache.put(cacheKey, book: book)
                return .success(book)
            }
        } catch {
            print("BookRepository: Open Library ISBN lookup failed: \(error)")
        }
        
        // Neither API found the book
        return .success(nil)
    }
    
    /// Closes all API clients and releases resources.
    func close() {
        googleBooksApi.close()
        openLibraryApi.close()
    }
    
    /// Creates a BookRepository instance with default configuration.
    static func create(googleBooksApiKey: String) -> BookRepository {
        return BookRepository(
            googleBooksApi: GoogleBooksApi(apiKey: googleBooksApiKey),
            openLibraryApi: OpenLibraryApi(),
            cache: BookCache()
        )
    }
}
