import Foundation

/// Mapper for transforming Google Books API DTOs to domain models.
struct GoogleBooksMapper {
    
    /// Converts a Google Books VolumeItem to a Book domain model.
    static func toBook(from volumeItem: VolumeItem) -> Book {
        let info = volumeItem.volumeInfo
        
        let originalCoverUrl = info.imageLinks?.extraLarge
            ?? info.imageLinks?.large
            ?? info.imageLinks?.medium
            ?? info.imageLinks?.thumbnail
        
        let enhancedCoverUrl = ImageUrlEnhancer.enhance(originalCoverUrl)
        
        return Book(
            id: volumeItem.id,
            title: info.title,
            author: info.authors?.first ?? "Unknown Author",
            coverUrl: enhancedCoverUrl,
            description: info.description,
            publishedDate: info.publishedDate,
            pageCount: info.pageCount,
            isbn: extractIsbn13(from: info.industryIdentifiers)
                ?? extractIsbn10(from: info.industryIdentifiers),
            subjects: info.categories ?? []
        )
    }
    
    /// Extracts ISBN-13 from industry identifiers list.
    private static func extractIsbn13(from identifiers: [IndustryIdentifier]?) -> String? {
        return identifiers?.first { $0.type == "ISBN_13" }?.identifier
    }
    
    /// Extracts ISBN-10 from industry identifiers list.
    private static func extractIsbn10(from identifiers: [IndustryIdentifier]?) -> String? {
        return identifiers?.first { $0.type == "ISBN_10" }?.identifier
    }
}
