import Foundation

/// Utility model for managing book cover image URLs at different sizes.
///
/// This separates cover image concerns from the Book model, allowing API-specific
/// size handling without cluttering the domain model. Different book APIs provide
/// covers at various resolutions (Open Library: S/M/L, Google Books: thumbnail/small/large).
///
/// Usage:
/// - BookCover.fromUrl(url) - Create from single URL (all sizes point to same image)
/// - BookCover.empty - Represents missing cover (all nulls)
public struct BookCover: Equatable {
    /// Thumbnail size (~100-150px)
    public let small: String?
    /// List/grid view (~200-300px)
    public let medium: String?
    /// Full-screen display (~500-800px)
    public let large: String?

    public init(small: String? = nil, medium: String? = nil, large: String? = nil) {
        self.small = small
        self.medium = medium
        self.large = large
    }

    /// Creates a BookCover with all sizes pointing to the same URL.
    /// Useful when API provides only one cover size.
    public static func fromUrl(_ url: String) -> BookCover {
        return BookCover(small: url, medium: url, large: url)
    }

    /// Represents a book with no cover image available.
    public static let empty = BookCover(small: nil, medium: nil, large: nil)
}
