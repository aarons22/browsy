import Foundation

/// Represents the different shelves a user can save books to.
///
/// Each shelf serves a distinct purpose in the user's book organization:
/// - TBR: "To Be Read" wishlist for books the user wants to read
/// - RECOMMEND: User's public recommendations to share with others
/// - READ: Books the user has marked as completed
public enum BookShelf: String, Codable, CaseIterable {
    case tbr = "TBR"
    case recommend = "RECOMMEND"
    case read = "READ"
}
