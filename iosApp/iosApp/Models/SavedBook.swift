import Foundation

/// Represents a book saved to a user's shelf.
///
/// This model captures the relationship between a book and a shelf, including
/// when it was saved. The bookId references the Book.id from the data model.
struct SavedBook: Codable, Equatable {
    let bookId: String
    let shelf: BookShelfType
    let savedAt: Int64  // Unix timestamp in milliseconds
    
    init(bookId: String, shelf: BookShelfType, savedAt: Int64) {
        self.bookId = bookId
        self.shelf = shelf
        self.savedAt = savedAt
    }
}

/// Types of book shelves available
enum BookShelfType: String, Codable, CaseIterable {
    case tbr = "TBR"           // To Be Read - wishlist
    case recommend = "RECOMMEND"  // User's public recommendations
    case read = "READ"         // Books marked as read
}
