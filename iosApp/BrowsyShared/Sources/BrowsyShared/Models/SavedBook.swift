import Foundation

/// Represents a book saved to a user's shelf.
///
/// This model captures the relationship between a book and a shelf, including
/// when it was saved. The bookId references the Book.id from the data model.
///
/// Note: A book can be on multiple shelves simultaneously (e.g., READ and RECOMMEND).
public struct SavedBook: Codable, Equatable {
    /// Reference to Book.id
    public let bookId: String
    /// The shelf this book is saved to
    public let shelf: BookShelf
    /// Unix timestamp (milliseconds) when the book was saved
    public let savedAt: Int64

    public init(bookId: String, shelf: BookShelf, savedAt: Int64) {
        self.bookId = bookId
        self.shelf = shelf
        self.savedAt = savedAt
    }
}
