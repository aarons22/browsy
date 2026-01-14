package com.browsy.data.repository

import com.browsy.data.cache.BookCache
import com.browsy.data.model.Book
import com.browsy.data.remote.GoogleBooksApi
import com.browsy.data.remote.OpenLibraryApi
import com.browsy.data.remote.mapper.GoogleBooksMapper
import com.browsy.data.remote.mapper.GoogleBooksMapper.toBook
import com.browsy.data.remote.mapper.OpenLibraryMapper
import com.browsy.data.remote.mapper.OpenLibraryMapper.toBook

/**
 * Unified book data access layer with dual-API fallback strategy and in-memory caching.
 *
 * This repository provides reliable book data by:
 * 1. Checking in-memory cache first for fast access
 * 2. Trying Google Books API (primary source for better metadata quality)
 * 3. Falling back to Open Library API if Google Books fails or has no results
 * 4. Caching successful results to reduce API calls
 *
 * Dual-API strategy:
 * - Google Books: Primary source with rich metadata, cover images, and descriptions
 * - Open Library: Fallback for ISBN lookups when Google Books has no results
 *
 * Caching behavior:
 * - Search results: Cached by query string (key: "search:query")
 * - ISBN lookups: Cached by ISBN (key: "isbn:1234567890")
 * - TTL: 30 minutes for all cached entries
 * - Size: 100 entries max with LRU eviction
 *
 * Error handling:
 * - All methods return Result<T> for safe error handling
 * - Network failures don't throw exceptions
 * - Empty results are success cases (Result.success(emptyList) or Result.success(null))
 *
 * Usage:
 * ```
 * val repo = BookRepository.create(googleBooksApiKey = "your-key")
 * val searchResult = repo.searchBooks("kotlin programming")
 * searchResult.onSuccess { books ->
 *     books.forEach { println(it.title) }
 * }
 * repo.close() // Clean up when done
 * ```
 *
 * @property googleBooksApi Primary API client
 * @property openLibraryApi Fallback API client
 * @property cache In-memory cache for recently accessed books
 */
class BookRepository(
    private val googleBooksApi: GoogleBooksApi,
    private val openLibraryApi: OpenLibraryApi,
    private val cache: BookCache = BookCache()
) {
    /**
     * Searches for books matching the given query.
     *
     * Search strategy:
     * 1. Check cache for previously fetched results
     * 2. Query Google Books API (supports full search syntax)
     * 3. If Google Books returns no results, return empty list
     *    (Open Library doesn't have general search, only ISBN lookup)
     * 4. Cache first result for faster subsequent access
     *
     * Note: For MVP, Open Library is not used for search since it only
     * supports ISBN-based lookup, not general text search.
     *
     * @param query Search query (supports Google Books query syntax: intitle:, inauthor:, isbn:, etc.)
     * @return Result with list of matching books, or empty list if none found
     */
    suspend fun searchBooks(query: String): Result<List<Book>> {
        // Check cache first
        val cacheKey = "search:$query"
        cache.get(cacheKey)?.let { return Result.success(listOf(it)) }

        // Try Google Books first
        val googleResult = googleBooksApi.searchBooks(query)
        if (googleResult.isSuccess) {
            val books = googleResult.getOrNull()?.items?.map {
                GoogleBooksMapper.run { it.toBook() }
            }.orEmpty()

            if (books.isNotEmpty()) {
                books.firstOrNull()?.let { cache.put(cacheKey, it) }
                return Result.success(books)
            }
        }

        // Fallback to Open Library if Google Books failed or returned nothing
        // Open Library doesn't have general search, only ISBN lookup
        // For MVP, return empty list if Google Books has nothing
        return Result.success(emptyList())
    }

    /**
     * Fetches book details by ISBN with automatic API fallback.
     *
     * ISBN lookup strategy:
     * 1. Check cache for previously fetched book
     * 2. Try Google Books API (ISBN search)
     * 3. If Google Books fails or has no results, try Open Library API
     * 4. Cache successful result
     * 5. Return null if neither API has the book
     *
     * Accepts both ISBN-10 and ISBN-13 formats (with or without hyphens).
     *
     * @param isbn Book ISBN (10 or 13 digits, hyphens optional)
     * @return Result with Book if found by either API, null if not found by any API
     */
    suspend fun getBookByIsbn(isbn: String): Result<Book?> {
        // Check cache
        val cacheKey = "isbn:$isbn"
        cache.get(cacheKey)?.let { return Result.success(it) }

        // Try Google Books first
        val googleResult = googleBooksApi.getBookByIsbn(isbn)
        if (googleResult.isSuccess) {
            val book = googleResult.getOrNull()?.items?.firstOrNull()?.let {
                GoogleBooksMapper.run { it.toBook() }
            }
            if (book != null) {
                cache.put(cacheKey, book)
                return Result.success(book)
            }
        }

        // Fallback to Open Library
        val openLibraryResult = openLibraryApi.getBookByIsbn(isbn)
        if (openLibraryResult.isSuccess) {
            val book = openLibraryResult.getOrNull()?.let {
                OpenLibraryMapper.run { it.toBook(isbn) }
            }
            if (book != null) {
                cache.put(cacheKey, book)
                return Result.success(book)
            }
        }

        // Neither API found the book
        return Result.success(null)
    }

    /**
     * Closes all API clients and releases resources.
     *
     * Call this when you're done using the repository to clean up HTTP connection
     * pools and other resources.
     */
    fun close() {
        googleBooksApi.close()
        openLibraryApi.close()
    }

    companion object {
        /**
         * Creates a BookRepository instance with default configuration.
         *
         * This factory method initializes the repository with:
         * - GoogleBooksApi configured with provided API key
         * - OpenLibraryApi as fallback (no key required)
         * - BookCache with default settings (100 entries, 30-min TTL)
         *
         * API key configuration:
         * - Obtain Google Books API key from Google Cloud Console
         * - Enable Books API for your project
         * - Pass the key to this method (should come from platform-specific config)
         * - Do not hardcode API keys in source code
         *
         * Usage:
         * ```
         * // Android: Read from BuildConfig or local.properties
         * val repo = BookRepository.create(BuildConfig.GOOGLE_BOOKS_API_KEY)
         *
         * // iOS: Read from Info.plist or Bundle
         * let repo = BookRepository.create(apiKey: Bundle.main.object(forInfoDictionaryKey: "GoogleBooksApiKey"))
         * ```
         *
         * @param googleBooksApiKey Google Books API key for authenticated requests
         * @return Configured BookRepository ready for use
         */
        fun create(googleBooksApiKey: String): BookRepository {
            return BookRepository(
                googleBooksApi = GoogleBooksApi(googleBooksApiKey),
                openLibraryApi = OpenLibraryApi(),
                cache = BookCache()
            )
        }
    }
}
