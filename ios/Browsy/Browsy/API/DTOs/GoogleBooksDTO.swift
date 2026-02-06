import Foundation

/// Data transfer objects for Google Books API responses.
///
/// These DTOs mirror the structure of the Google Books API v1 response format.
/// All fields are optional or have default values to handle partial API responses gracefully.
///
/// API Documentation: https://developers.google.com/books/docs/v1/reference/volumes

/// Root response object from Google Books API search.
public struct GoogleBooksResponse: Codable {
    /// List of volume items (books) matching the search query. Nil if no results.
    public let items: [VolumeItem]?
    /// Total number of items available (not just in this response).
    public let totalItems: Int

    public init(items: [VolumeItem]?, totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}

/// Individual book/volume item from Google Books API.
public struct VolumeItem: Codable {
    /// Unique identifier for this volume (Google Books ID).
    public let id: String
    /// Metadata about the book (title, authors, etc.).
    public let volumeInfo: VolumeInfo

    public init(id: String, volumeInfo: VolumeInfo) {
        self.id = id
        self.volumeInfo = volumeInfo
    }
}

/// Volume metadata containing book details.
public struct VolumeInfo: Codable {
    /// Book title (always present).
    public let title: String
    /// List of author names. Nil if not available.
    public let authors: [String]?
    /// Book description/summary. Nil if not available.
    public let description: String?
    /// Publication date in various formats (YYYY, YYYY-MM, YYYY-MM-DD). Nil if unknown.
    public let publishedDate: String?
    /// Number of pages. Nil if not available.
    public let pageCount: Int?
    /// List of categories/genres. Nil if not available.
    public let categories: [String]?
    /// Cover image URLs at different sizes. Nil if no covers available.
    public let imageLinks: ImageLinks?
    /// ISBN and other identifiers. Nil if not available.
    public let industryIdentifiers: [IndustryIdentifier]?

    public init(
        title: String,
        authors: [String]? = nil,
        description: String? = nil,
        publishedDate: String? = nil,
        pageCount: Int? = nil,
        categories: [String]? = nil,
        imageLinks: ImageLinks? = nil,
        industryIdentifiers: [IndustryIdentifier]? = nil
    ) {
        self.title = title
        self.authors = authors
        self.description = description
        self.publishedDate = publishedDate
        self.pageCount = pageCount
        self.categories = categories
        self.imageLinks = imageLinks
        self.industryIdentifiers = industryIdentifiers
    }
}

/// Cover image URLs at different resolutions.
///
/// Google Books provides multiple sizes for flexibility. All fields are optional
/// as availability varies by book.
public struct ImageLinks: Codable {
    /// ~128x128px
    public let thumbnail: String?
    /// ~80x80px (lower quality)
    public let smallThumbnail: String?
    /// ~300px height
    public let small: String?
    /// ~575px height
    public let medium: String?
    /// ~800px height
    public let large: String?
    /// ~1280px height
    public let extraLarge: String?

    public init(
        thumbnail: String? = nil,
        smallThumbnail: String? = nil,
        small: String? = nil,
        medium: String? = nil,
        large: String? = nil,
        extraLarge: String? = nil
    ) {
        self.thumbnail = thumbnail
        self.smallThumbnail = smallThumbnail
        self.small = small
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
    }
}

/// Book identifier (ISBN, ISSN, etc.).
public struct IndustryIdentifier: Codable {
    /// Identifier type (e.g., "ISBN_10", "ISBN_13", "ISSN").
    public let type: String
    /// The actual identifier value.
    public let identifier: String

    public init(type: String, identifier: String) {
        self.type = type
        self.identifier = identifier
    }
}
