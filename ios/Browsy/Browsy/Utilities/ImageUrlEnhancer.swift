import Foundation

/// Utility for enhancing book cover image URLs to get the highest quality possible.
///
/// This addresses the issue where APIs (particularly Google Books) often return only
/// low-quality thumbnail images. The enhancer applies URL manipulation techniques
/// to extract higher resolution versions when possible.
///
/// Enhanced strategies:
/// - Google Books: Modify zoom parameter for larger images (zoom=1 → zoom=0)
/// - Open Library: Ensure we're using the Large (L) size variant
/// - URL optimization: Remove unnecessary parameters that may limit quality
public struct ImageUrlEnhancer {

    /// Enhances an image URL to get the highest quality version available.
    ///
    /// Applies source-specific optimization strategies:
    /// - Google Books: Reduces zoom parameter for larger image sizes
    /// - Open Library: Ensures Large (L) size is used
    /// - Generic: Removes common quality-limiting parameters
    ///
    /// - Parameter originalUrl: The original image URL from API response
    /// - Returns: Enhanced URL likely to provide higher quality image
    public static func enhance(_ originalUrl: String?) -> String? {
        guard let url = originalUrl else { return nil }

        if url.contains("books.google.com/books/content") {
            return enhanceGoogleBooksUrl(url)
        } else if url.contains("covers.openlibrary.org") {
            return enhanceOpenLibraryUrl(url)
        } else {
            return url // Return original if no enhancement strategy available
        }
    }

    /// Enhances Google Books cover URLs for higher quality.
    ///
    /// Google Books uses a zoom parameter where lower values = larger images:
    /// - zoom=5: ~80x80px (smallThumbnail)
    /// - zoom=1: ~128x128px (thumbnail)
    /// - zoom=0: ~256px+ (larger, better quality)
    ///
    /// Also removes edge=curl parameter which may limit image access.
    ///
    /// - Parameter url: Original Google Books image URL
    /// - Returns: URL modified for maximum quality
    private static func enhanceGoogleBooksUrl(_ url: String) -> String {
        return url
            // Change zoom to 0 for largest available size
            .replacingOccurrences(of: "zoom=5", with: "zoom=0")
            .replacingOccurrences(of: "zoom=1", with: "zoom=0")
            // Remove edge=curl which might limit access to larger versions
            .replacingOccurrences(of: "&edge=curl", with: "")
            .replacingOccurrences(of: "edge=curl&", with: "")
            // Ensure HTTPS for iOS App Transport Security compliance
            .replacingOccurrences(of: "http://", with: "https://")
    }

    /// Enhances Open Library cover URLs for highest quality.
    ///
    /// Open Library URL pattern:
    /// https://covers.openlibrary.org/b/id/{id}-{size}.jpg
    /// Where size is S (small), M (medium), L (large)
    ///
    /// Ensures we're using the Large (L) variant for best quality.
    ///
    /// - Parameter url: Original Open Library cover URL
    /// - Returns: URL modified to use Large size variant
    private static func enhanceOpenLibraryUrl(_ url: String) -> String {
        if url.contains("-S.jpg") {
            return url.replacingOccurrences(of: "-S.jpg", with: "-L.jpg")
        } else if url.contains("-M.jpg") {
            return url.replacingOccurrences(of: "-M.jpg", with: "-L.jpg")
        } else {
            return url // Already Large or different pattern
        }
    }
}
