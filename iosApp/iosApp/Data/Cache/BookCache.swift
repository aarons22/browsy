import Foundation

/// In-memory LRU cache for book data.
///
/// This cache provides fast access to recently accessed books while managing memory usage
/// through LRU (Least Recently Used) eviction and TTL (Time To Live) expiration.
class BookCache {
    private var cache: [String: CachedBook] = [:]
    private var accessOrder: [String] = []
    private let maxSize: Int
    private let ttlMillis: Int64 = 30 * 60 * 1000  // 30 minutes
    
    init(maxSize: Int = 100) {
        self.maxSize = maxSize
    }
    
    /// Retrieves a book from the cache.
    func get(_ key: String) -> Book? {
        guard let cached = cache[key] else {
            return nil
        }
        
        // Check if expired (30 minutes TTL)
        let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        if currentTime - cached.timestamp > ttlMillis {
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
    func put(_ key: String, book: Book) {
        if cache.count >= maxSize && cache[key] == nil {
            // Evict least recently used
            if let lru = accessOrder.first {
                cache.removeValue(forKey: lru)
                accessOrder.removeFirst()
            }
        }
        
        let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        cache[key] = CachedBook(book: book, timestamp: currentTime)
        
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
        accessOrder.append(key)
    }
    
    /// Removes a specific entry from the cache.
    func remove(_ key: String) {
        cache.removeValue(forKey: key)
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
    }
    
    /// Clears all entries from the cache.
    func clear() {
        cache.removeAll()
        accessOrder.removeAll()
    }
    
    /// Internal struct wrapping a cached book with its timestamp.
    private struct CachedBook {
        let book: Book
        let timestamp: Int64
    }
}
