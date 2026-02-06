import Foundation

/// Utility model for handling book cover images at different sizes.
/// Non-serializable helper for multi-size cover image handling.
public struct BookCover: Equatable {
    public let small: String?
    public let medium: String?
    public let large: String?

    public init(small: String?, medium: String?, large: String?) {
        self.small = small
        self.medium = medium
        self.large = large
    }

    /// Create a BookCover from a single URL
    public static func fromUrl(_ url: String) -> BookCover {
        return BookCover(small: url, medium: url, large: url)
    }

    /// Empty BookCover with no images
    public static let empty = BookCover(small: nil, medium: nil, large: nil)
}
