package com.browsy.data.cache

import com.browsy.data.model.Book

/**
 * Returns current time in milliseconds since Unix epoch.
 * Platform-specific implementation provided via expect/actual.
 */
internal expect fun currentTimeMillis(): Long

/**
 * In-memory LRU cache for book data.
 *
 * This cache provides fast access to recently accessed books while managing memory usage
 * through LRU (Least Recently Used) eviction and TTL (Time To Live) expiration.
 *
 * Cache strategy:
 * - LRU eviction: When cache is full, removes least recently accessed entry
 * - TTL expiration: Entries expire after 30 minutes to maintain data freshness
 * - Thread-safe: Designed for single-threaded KMP commonMain (no concurrent access)
 *
 * Eviction policy:
 * - Max size: 100 entries by default (configurable)
 * - Access order tracked: Every get() updates entry to "most recently used"
 * - Automatic eviction: When adding new entry at max capacity, removes LRU entry
 * - TTL check on access: Expired entries removed automatically on get()
 *
 * Usage:
 * ```
 * val cache = BookCache(maxSize = 100)
 * cache.put("search:kotlin", book)
 * val cached = cache.get("search:kotlin") // null if expired or not found
 * cache.clear() // Remove all entries
 * ```
 *
 * @property maxSize Maximum number of entries before LRU eviction (default: 100)
 */
class BookCache(private val maxSize: Int = 100) {
    private val cache = mutableMapOf<String, CachedBook>()
    private val accessOrder = mutableListOf<String>()

    /**
     * Retrieves a book from the cache.
     *
     * This method checks TTL expiration and updates LRU access order on successful retrieval.
     * Expired entries are automatically removed.
     *
     * @param key Cache key (e.g., "search:kotlin", "isbn:9781234567890")
     * @return Book if found and not expired, null otherwise
     */
    fun get(key: String): Book? {
        val cached = cache[key] ?: return null

        // Check if expired (30 minutes TTL)
        if (currentTimeMillis() - cached.timestamp > 30 * 60 * 1000) {
            remove(key)
            return null
        }

        // Update access order (LRU)
        accessOrder.remove(key)
        accessOrder.add(key)

        return cached.book
    }

    /**
     * Stores a book in the cache.
     *
     * If the cache is at max capacity and the key is new, the least recently used entry
     * is evicted to make room. Existing keys are updated without eviction.
     *
     * @param key Cache key (e.g., "search:kotlin", "isbn:9781234567890")
     * @param book Book instance to cache
     */
    fun put(key: String, book: Book) {
        if (cache.size >= maxSize && key !in cache) {
            // Evict least recently used
            val lru = accessOrder.removeFirstOrNull()
            lru?.let { cache.remove(it) }
        }

        cache[key] = CachedBook(book, currentTimeMillis())
        accessOrder.remove(key)
        accessOrder.add(key)
    }

    /**
     * Removes a specific entry from the cache.
     *
     * @param key Cache key to remove
     */
    fun remove(key: String) {
        cache.remove(key)
        accessOrder.remove(key)
    }

    /**
     * Clears all entries from the cache.
     */
    fun clear() {
        cache.clear()
        accessOrder.clear()
    }

    /**
     * Internal data class wrapping a cached book with its timestamp.
     *
     * @property book The cached Book instance
     * @property timestamp Unix timestamp (milliseconds) when this entry was cached
     */
    private data class CachedBook(
        val book: Book,
        val timestamp: Long
    )
}
