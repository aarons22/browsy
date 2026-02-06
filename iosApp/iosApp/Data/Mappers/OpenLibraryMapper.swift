import Foundation

/// Mapper for transforming Open Library API DTOs to domain Book models.
struct OpenLibraryMapper {
    
    /// Converts Open Library book data to domain Book model.
    static func toBook(from bookData: OpenLibraryBookData, isbn: String) -> Book {
        let fullTitle = bookData.subtitle != nil 
            ? "\(bookData.title): \(bookData.subtitle!)" 
            : bookData.title
        
        let coverUrl = ImageUrlEnhancer.enhance(
            bookData.cover?.large ?? bookData.cover?.medium ?? bookData.cover?.small
        )
        
        let isbnValue = bookData.identifiers?.isbn13?.first
            ?? bookData.identifiers?.isbn10?.first
            ?? isbn
        
        return Book(
            id: "OL:\(isbn)",
            title: fullTitle,
            author: bookData.authors?.first?.name ?? "Unknown Author",
            coverUrl: coverUrl,
            description: nil,  // Open Library doesn't provide description in Books API
            publishedDate: bookData.publishDate,
            pageCount: bookData.numberOfPages,
            isbn: isbnValue,
            subjects: bookData.subjects?.map { $0.name } ?? []
        )
    }
}
