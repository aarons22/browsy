import Foundation

/// In-memory LRU cache for book data.
///
/// This cache provides fast access to recently accessed books while managing memory usage
/// through LRU (Least Recently Used) eviction and TTL (Time To Live) expiration.
///
/// Cache strategy:
/// - LRU eviction: When cache is full, removes least recently accessed entry
/// - TTL expiration: Entries expire after 30 minutes to maintain data freshness
/// - Thread-safe: Uses actor isolation for concurrent access
///
/// Eviction policy:
/// - Max size: 100 entries by default (configurable)
/// - Access order tracked: Every get() updates entry to "most recently used"
/// - Automatic eviction: When adding new entry at max capacity, removes LRU entry
/// - TTL check on access: Expired entries removed automatically on get()
///
/// Usage:
/// ```swift
/// let cache = BookCache(maxSize: 100)
/// await cache.put("search:kotlin", book)
/// let cached = await cache.get("search:kotlin") // nil if expired or not found
/// await cache.clear() // Remove all entries
/// ```
public actor BookCache {
    private var cache: [String: CachedBook] = [:]
    private var accessOrder: [String] = []
    private let maxSize: Int
    private let ttlMilliseconds: Int64

    /// Internal data class wrapping a cached book with its timestamp.
    private struct CachedBook {
        let book: Book
        let timestamp: Int64
    }

    public init(maxSize: Int = 100, ttlMinutes: Int = 30) {
        self.maxSize = maxSize
        self.ttlMilliseconds = Int64(ttlMinutes * 60 * 1000)
    }

    /// Retrieves a book from the cache.
    ///
    /// This method checks TTL expiration and updates LRU access order on successful retrieval.
    /// Expired entries are automatically removed.
    ///
    /// - Parameter key: Cache key (e.g., "search:kotlin", "isbn:9781234567890")
    /// - Returns: Book if found and not expired, nil otherwise
    public func get(_ key: String) -> Book? {
        guard let cached = cache[key] else { return nil }

        // Check if expired (30 minutes TTL)
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        if now - cached.timestamp > ttlMilliseconds {
            remove(key)
            return nil
        }

        // Update access order (LRU)
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
        accessOrder.append(key)

        return cached.book
    }

    /// Stores a book in the cache.
    ///
    /// If the cache is at max capacity and the key is new, the least recently used entry
    /// is evicted to make room. Existing keys are updated without eviction.
    ///
    /// - Parameters:
    ///   - key: Cache key (e.g., "search:kotlin", "isbn:9781234567890")
    ///   - book: Book instance to cache
    public func put(_ key: String, _ book: Book) {
        if cache.count >= maxSize && cache[key] == nil {
            // Evict least recently used
            if let lru = accessOrder.first {
                cache.removeValue(forKey: lru)
                accessOrder.removeFirst()
            }
        }

        cache[key] = CachedBook(book: book, timestamp: Int64(Date().timeIntervalSince1970 * 1000))
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
        accessOrder.append(key)
    }

    /// Removes a specific entry from the cache.
    ///
    /// - Parameter key: Cache key to remove
    public func remove(_ key: String) {
        cache.removeValue(forKey: key)
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
    }

    /// Clears all entries from the cache.
    public func clear() {
        cache.removeAll()
        accessOrder.removeAll()
    }
}
