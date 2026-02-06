import Foundation

/// Core book model used throughout the app.
///
/// This model represents a book entity mapped from API responses (Open Library, Google Books, etc.).
/// All fields except id and title are optional to handle varying data completeness across APIs.
///
/// Design decisions:
/// - Single author string for MVP (will expand to multiple authors when needed)
/// - ISBN stored as optional string (prefer ISBN-13, fallback to ISBN-10)
/// - publishedDate as string in ISO format (YYYY-MM-DD) when available
/// - subjects array for genre/vibe tagging (empty if no subjects available)
/// - coverUrl points to API-provided cover images (processed via ImageUrlEnhancer)
public struct Book: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let author: String
    public let coverUrl: String?
    public let description: String?
    public let publishedDate: String?
    public let pageCount: Int?
    public let isbn: String?
    public let subjects: [String]

    public init(
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
