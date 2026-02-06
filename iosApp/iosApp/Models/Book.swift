import Foundation

/// Core book model used throughout the app.
///
/// This model represents a book entity mapped from API responses (Open Library, Google Books, etc.).
/// All fields except id and title are optional to handle varying data completeness across APIs.
struct Book: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let author: String
    let coverUrl: String?
    let description: String?
    let publishedDate: String?
    let pageCount: Int?
    let isbn: String?
    let subjects: [String]
    
    init(
        id: String,
        title: String,
        author: String,
        coverUrl: String? = nil,
        description: String? = nil,
        publishedDate: String? = nil,
        pageCount: Int? = nil,
        isbn: String? = nil,
        subjects: [String] = []
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.coverUrl = coverUrl
        self.description = description
        self.publishedDate = publishedDate
        self.pageCount = pageCount
        self.isbn = isbn
        self.subjects = subjects
    }
}
