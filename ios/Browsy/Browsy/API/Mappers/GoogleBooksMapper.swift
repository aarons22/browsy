import Foundation

/// Mapper for transforming Google Books API DTOs to domain models.
///
/// This provides functions to convert Google Books API response objects
/// (VolumeItem) into our app's Book domain model. The mapping handles missing data gracefully
/// with sensible defaults and fallback strategies.
///
/// Mapping strategies:
/// - Authors: Uses first author from list, falls back to "Unknown Author"
/// - Cover images: Prioritizes high quality with URL enhancement (extraLarge → large → medium → thumbnail + zoom optimization)
/// - ISBN: Prefers ISBN-13 over ISBN-10
/// - Subjects: Maps categories directly to subjects list
public struct GoogleBooksMapper {

    /// Converts a Google Books VolumeItem to a Book domain model.
    ///
    /// This mapping handles incomplete API data gracefully:
    /// - Missing authors default to "Unknown Author"
    /// - Cover URL selection prioritizes quality with enhancement (zoom optimization for Google Books URLs)
    /// - ISBN-13 is preferred over ISBN-10 when both are available
    /// - Empty arrays are used for missing subjects/categories
    ///
    /// - Parameter item: VolumeItem from API response
    /// - Returns: Book domain model populated from this VolumeItem
    public static func toBook(from item: VolumeItem) -> Book {
        let info = item.volumeInfo

        let originalCoverUrl = info.imageLinks?.extraLarge
            ?? info.imageLinks?.large
            ?? info.imageLinks?.medium
            ?? info.imageLinks?.thumbnail

        let enhancedCoverUrl = ImageUrlEnhancer.enhance(originalCoverUrl)?.toHttps()

        // Debug logging to track image quality improvements
        if let original = originalCoverUrl, let enhanced = enhancedCoverUrl, original != enhanced {
            print("GoogleBooks: Enhanced image URL for '\(info.title)'")
            print("  Original:  \(original)")
            print("  Enhanced:  \(enhanced)")
        }

        return Book(
            id: item.id,
            title: info.title,
            author: info.authors?.first ?? "Unknown Author",
            coverUrl: enhancedCoverUrl,
            description: info.description,
            publishedDate: info.publishedDate,
            pageCount: info.pageCount,
            isbn: extractIsbn13(from: info.industryIdentifiers) ?? extractIsbn10(from: info.industryIdentifiers),
            subjects: info.categories ?? []
        )
    }

    /// Extracts ISBN-13 from industry identifiers list.
    ///
    /// ISBN-13 is preferred over ISBN-10 as it's the modern standard and provides
    /// better global coverage.
    ///
    /// - Parameter identifiers: List of industry identifiers from API response
    /// - Returns: ISBN-13 string if found, nil otherwise
    private static func extractIsbn13(from identifiers: [IndustryIdentifier]?) -> String? {
        return identifiers?.first(where: { $0.type == "ISBN_13" })?.identifier
    }

    /// Extracts ISBN-10 from industry identifiers list.
    ///
    /// Used as fallback when ISBN-13 is not available.
    ///
    /// - Parameter identifiers: List of industry identifiers from API response
    /// - Returns: ISBN-10 string if found, nil otherwise
    private static func extractIsbn10(from identifiers: [IndustryIdentifier]?) -> String? {
        return identifiers?.first(where: { $0.type == "ISBN_10" })?.identifier
    }
}

extension String {
    /// Converts an HTTP URL to HTTPS.
    ///
    /// Google Books API sometimes returns HTTP URLs for cover images, which causes
    /// iOS App Transport Security (ATS) to block the request. This extension ensures
    /// all cover URLs use HTTPS.
    ///
    /// - Returns: URL with https:// scheme, or original if already HTTPS or not HTTP
    func toHttps() -> String {
        if self.hasPrefix("http://") {
            return self.replacingOccurrences(of: "http://", with: "https://", options: .anchored)
        } else {
            return self
        }
    }
}
