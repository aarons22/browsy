import Foundation

/// Utility for managing book cover image URLs at different sizes.
///
/// This separates cover image concerns from the Book model, allowing API-specific
/// size handling without cluttering the domain model.
struct BookCover {
    let small: String?   // thumbnail size (~100-150px)
    let medium: String?  // list/grid view (~200-300px)
    let large: String?   // full-screen display (~500-800px)
    
    init(small: String? = nil, medium: String? = nil, large: String? = nil) {
        self.small = small
        self.medium = medium
        self.large = large
    }
    
    /// Creates a BookCover with all sizes pointing to the same URL.
    static func fromUrl(_ url: String) -> BookCover {
        return BookCover(small: url, medium: url, large: url)
    }
    
    /// Represents a book with no cover image available.
    static let empty = BookCover(small: nil, medium: nil, large: nil)
}

/// Utility for enhancing book cover image URLs to get the highest quality possible.
///
/// This addresses the issue where APIs (particularly Google Books) often return only
/// low-quality thumbnail images.
struct ImageUrlEnhancer {
    
    /// Enhances an image URL to get the highest quality version available.
    static func enhance(_ originalUrl: String?) -> String? {
        guard let url = originalUrl else { return nil }
        
        if url.contains("books.google.com/books/content") {
            return enhanceGoogleBooksUrl(url)
        } else if url.contains("covers.openlibrary.org") {
            return enhanceOpenLibraryUrl(url)
        }
        
        return url
    }
    
    /// Enhances Google Books cover URLs for higher quality.
    private static func enhanceGoogleBooksUrl(_ url: String) -> String {
        return url
            .replacingOccurrences(of: "zoom=5", with: "zoom=0")
            .replacingOccurrences(of: "zoom=1", with: "zoom=0")
            .replacingOccurrences(of: "&edge=curl", with: "")
            .replacingOccurrences(of: "edge=curl&", with: "")
            .replacingOccurrences(of: "http://", with: "https://")
    }
    
    /// Enhances Open Library cover URLs for highest quality.
    private static func enhanceOpenLibraryUrl(_ url: String) -> String {
        if url.contains("-S.jpg") {
            return url.replacingOccurrences(of: "-S.jpg", with: "-L.jpg")
        } else if url.contains("-M.jpg") {
            return url.replacingOccurrences(of: "-M.jpg", with: "-L.jpg")
        }
        return url
    }
}
