import Foundation

/// Mapper for transforming Open Library API DTOs to domain Book models.
///
/// Open Library-specific mapping logic:
/// - Combines title and subtitle with colon separator (e.g., "Foundation: A Novel")
/// - Uses first author from authors list (MVP: single author string)
/// - Prefers ISBN-13 from identifiers, falls back to ISBN-10 or query ISBN
/// - Extracts subject names from Subject objects for genre/vibe tagging
/// - Uses "OL:" ID prefix to distinguish from Google Books ("GB:") IDs
/// - Cover URL priority: large > medium > small
///
/// Notable differences from Google Books:
/// - Open Library doesn't provide description in Books API (field will be nil)
/// - publishDate format varies (can be year only like "1991" or full date)
/// - Cover URLs already included in API response (no need to construct)
public struct OpenLibraryMapper {

    /// Converts Open Library book data to domain Book model.
    ///
    /// - Parameters:
    ///   - data: OpenLibraryBookData from API response
    ///   - isbn: The ISBN used for the query (fallback if identifiers missing)
    /// - Returns: Book model with Open Library data
    public static func toBook(from data: OpenLibraryBookData, isbn: String) -> Book {
        let fullTitle = data.subtitle != nil ? "\(data.title): \(data.subtitle!)" : data.title

        let coverUrl = ImageUrlEnhancer.enhance(
            data.cover?.large ?? data.cover?.medium ?? data.cover?.small
        )

        let isbnValue = data.identifiers?.isbn13?.first
            ?? data.identifiers?.isbn10?.first
            ?? isbn

        return Book(
            id: "OL:\(isbn)",
            title: fullTitle,
            author: data.authors?.first?.name ?? "Unknown Author",
            coverUrl: coverUrl,
            description: nil, // Open Library doesn't provide description in Books API
            publishedDate: data.publishDate,
            pageCount: data.numberOfPages,
            isbn: isbnValue,
            subjects: data.subjects?.map { $0.name } ?? []
        )
    }
}
