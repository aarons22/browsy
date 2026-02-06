import Foundation

/// Repository for managing local book shelf storage.
///
/// This repository provides CRUD operations for saving books to shelves (TBR, RECOMMEND, READ).
/// Data is persisted locally using UserDefaults.
class LocalBookShelfRepository {
    private let storage = LocalBookShelfStorage()
    private var cache: [String: SavedBook] = [:]
    
    init() {
        loadFromStorage()
    }
    
    /// Adds a book to a shelf.
    func addToShelf(bookId: String, shelf: BookShelfType) {
        let savedAt = Int64(Date().timeIntervalSince1970 * 1000)
        let saved = SavedBook(bookId: bookId, shelf: shelf, savedAt: savedAt)
        cache[cacheKey(bookId: bookId, shelf: shelf)] = saved
        persist()
    }
    
    /// Removes a book from a shelf.
    func removeFromShelf(bookId: String, shelf: BookShelfType) {
        cache.removeValue(forKey: cacheKey(bookId: bookId, shelf: shelf))
        persist()
    }
    
    /// Checks if a book is on a specific shelf.
    func isOnShelf(bookId: String, shelf: BookShelfType) -> Bool {
        return cache.keys.contains(cacheKey(bookId: bookId, shelf: shelf))
    }
    
    /// Gets all saved books on a specific shelf.
    func getShelf(_ shelf: BookShelfType) -> [SavedBook] {
        return cache.values
            .filter { $0.shelf == shelf }
            .sorted { $0.savedAt > $1.savedAt }  // Most recent first
    }
    
    /// Gets all shelves that a book is on.
    func getShelves(bookId: String) -> [BookShelfType] {
        return BookShelfType.allCases.filter { isOnShelf(bookId: bookId, shelf: $0) }
    }
    
    /// Toggles a book's presence on a shelf.
    func toggleShelf(bookId: String, shelf: BookShelfType) -> Bool {
        if isOnShelf(bookId: bookId, shelf: shelf) {
            removeFromShelf(bookId: bookId, shelf: shelf)
            return false
        } else {
            addToShelf(bookId: bookId, shelf: shelf)
            return true
        }
    }
    
    private func cacheKey(bookId: String, shelf: BookShelfType) -> String {
        return "\(bookId):\(shelf.rawValue)"
    }
    
    private func loadFromStorage() {
        guard let data = storage.load() else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let list = try decoder.decode([SavedBook].self, from: Data(data.utf8))
            cache = Dictionary(uniqueKeysWithValues: list.map {
                (cacheKey(bookId: $0.bookId, shelf: $0.shelf), $0)
            })
        } catch {
            print("Failed to load saved books: \(error)")
            cache = [:]
        }
    }
    
    private func persist() {
        let encoder = JSONEncoder()
        do {
            let list = Array(cache.values)
            let data = try encoder.encode(list)
            if let jsonString = String(data: data, encoding: .utf8) {
                storage.save(jsonString)
            }
        } catch {
            print("Failed to persist saved books: \(error)")
        }
    }
}
