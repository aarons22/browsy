import Foundation

/// Repository for managing local book shelf storage.
///
/// This repository provides CRUD operations for saving books to shelves (TBR, RECOMMEND, READ).
/// Data is persisted locally using UserDefaults.
///
/// Note: A book can be on multiple shelves simultaneously. For example, a user might
/// mark a book as READ and also RECOMMEND it to others.
///
/// Thread safety: Uses actor isolation for concurrent access safety.
public actor LocalBookShelfRepository {
    private let storage: LocalBookShelfStorage
    private let json = JSONEncoder()
    private let decoder = JSONDecoder()
    private var cache: [String: SavedBook] = [:]

    public init(storage: LocalBookShelfStorage = LocalBookShelfStorage()) {
        self.storage = storage
        Task {
            await loadFromStorage()
        }
    }

    /// Adds a book to a shelf.
    ///
    /// If the book is already on the specified shelf, this updates the savedAt timestamp.
    ///
    /// - Parameters:
    ///   - bookId: The ID of the book to save
    ///   - shelf: The shelf to add the book to
    public func addToShelf(bookId: String, shelf: BookShelf) async {
        let saved = SavedBook(
            bookId: bookId,
            shelf: shelf,
            savedAt: Int64(Date().timeIntervalSince1970 * 1000)
        )
        cache[cacheKey(bookId: bookId, shelf: shelf)] = saved
        await persist()
    }

    /// Removes a book from a shelf.
    ///
    /// If the book is not on the specified shelf, this is a no-op.
    ///
    /// - Parameters:
    ///   - bookId: The ID of the book to remove
    ///   - shelf: The shelf to remove the book from
    public func removeFromShelf(bookId: String, shelf: BookShelf) async {
        cache.removeValue(forKey: cacheKey(bookId: bookId, shelf: shelf))
        await persist()
    }

    /// Checks if a book is on a specific shelf.
    ///
    /// - Parameters:
    ///   - bookId: The ID of the book to check
    ///   - shelf: The shelf to check
    /// - Returns: true if the book is on the shelf, false otherwise
    public func isOnShelf(bookId: String, shelf: BookShelf) -> Bool {
        return cache.keys.contains(cacheKey(bookId: bookId, shelf: shelf))
    }

    /// Gets all saved books on a specific shelf.
    ///
    /// - Parameter shelf: The shelf to retrieve books from
    /// - Returns: Array of SavedBook entries, sorted by savedAt descending (most recent first)
    public func getShelf(_ shelf: BookShelf) -> [SavedBook] {
        return cache.values
            .filter { $0.shelf == shelf }
            .sorted { $0.savedAt > $1.savedAt }
    }

    /// Gets all shelves that a book is on.
    ///
    /// - Parameter bookId: The ID of the book to check
    /// - Returns: Array of BookShelf values the book is saved to
    public func getShelves(bookId: String) -> [BookShelf] {
        return BookShelf.allCases.filter { isOnShelf(bookId: bookId, shelf: $0) }
    }

    /// Toggles a book's presence on a shelf.
    ///
    /// If the book is on the shelf, removes it. If not, adds it.
    ///
    /// - Parameters:
    ///   - bookId: The ID of the book
    ///   - shelf: The shelf to toggle
    /// - Returns: true if the book is now on the shelf, false if removed
    public func toggleShelf(bookId: String, shelf: BookShelf) async -> Bool {
        if isOnShelf(bookId: bookId, shelf: shelf) {
            await removeFromShelf(bookId: bookId, shelf: shelf)
            return false
        } else {
            await addToShelf(bookId: bookId, shelf: shelf)
            return true
        }
    }

    private func cacheKey(bookId: String, shelf: BookShelf) -> String {
        return "\(bookId):\(shelf.rawValue)"
    }

    private func loadFromStorage() async {
        guard let data = await storage.load() else { return }
        guard let jsonData = data.data(using: .utf8) else { return }

        do {
            let list = try decoder.decode([SavedBook].self, from: jsonData)
            cache = Dictionary(uniqueKeysWithValues: list.map {
                (cacheKey(bookId: $0.bookId, shelf: $0.shelf), $0)
            })
        } catch {
            // If data is corrupted, start fresh
            print("Failed to load saved books: \(error)")
            cache = [:]
        }
    }

    private func persist() async {
        let list = Array(cache.values)
        do {
            let jsonData = try json.encode(list)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                await storage.save(jsonString)
            }
        } catch {
            print("Failed to persist saved books: \(error)")
        }
    }
}
