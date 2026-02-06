import Foundation

/// Represents a book saved to a user's shelf with metadata about when it was saved.
public struct SavedBook: Codable, Equatable {
    public let bookId: String
    public let shelf: BookShelf
    public let savedAt: Int64

    public init(bookId: String, shelf: BookShelf, savedAt: Int64) {
        self.bookId = bookId
        self.shelf = shelf
        self.savedAt = savedAt
    }
}
