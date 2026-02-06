import Foundation

/// DTOs for Open Library Books API (https://openlibrary.org/dev/docs/api/books)
///
/// Open Library API response structure:
/// - Uses dynamic keys based on bibkey (e.g., "ISBN:0451526538")
/// - Response format: { "ISBN:xyz": { book data } }
/// - jscmd=data returns comprehensive book metadata including cover URLs

/// Book data from Open Library jscmd=data response.
/// All fields except title are optional to handle varying data completeness.
public struct OpenLibraryBookData: Codable {
    public let title: String
    public let subtitle: String?
    public let authors: [Author]?
    public let publishers: [Publisher]?
    public let publishDate: String?
    public let numberOfPages: Int?
    public let subjects: [Subject]?
    public let cover: Cover?
    public let identifiers: Identifiers?

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case authors
        case publishers
        case publishDate = "publish_date"
        case numberOfPages = "number_of_pages"
        case subjects
        case cover
        case identifiers
    }

    public init(
        title: String,
        subtitle: String? = nil,
        authors: [Author]? = nil,
        publishers: [Publisher]? = nil,
        publishDate: String? = nil,
        numberOfPages: Int? = nil,
        subjects: [Subject]? = nil,
        cover: Cover? = nil,
        identifiers: Identifiers? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.authors = authors
        self.publishers = publishers
        self.publishDate = publishDate
        self.numberOfPages = numberOfPages
        self.subjects = subjects
        self.cover = cover
        self.identifiers = identifiers
    }
}

/// Author with name and optional Open Library URL.
public struct Author: Codable {
    public let name: String
    public let url: String?

    public init(name: String, url: String? = nil) {
        self.name = name
        self.url = url
    }
}

/// Publisher name from Open Library.
public struct Publisher: Codable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

/// Subject/genre with name and optional Open Library URL.
public struct Subject: Codable {
    public let name: String
    public let url: String?

    public init(name: String, url: String? = nil) {
        self.name = name
        self.url = url
    }
}

/// Cover image URLs at different sizes.
/// Open Library provides small, medium, and large sizes.
public struct Cover: Codable {
    public let small: String?
    public let medium: String?
    public let large: String?

    public init(small: String? = nil, medium: String? = nil, large: String? = nil) {
        self.small = small
        self.medium = medium
        self.large = large
    }
}

/// Book identifiers (ISBN-13, ISBN-10, OCLC, LCCN).
public struct Identifiers: Codable {
    public let isbn13: [String]?
    public let isbn10: [String]?
    public let oclc: [String]?
    public let lccn: [String]?

    enum CodingKeys: String, CodingKey {
        case isbn13 = "isbn_13"
        case isbn10 = "isbn_10"
        case oclc
        case lccn
    }

    public init(
        isbn13: [String]? = nil,
        isbn10: [String]? = nil,
        oclc: [String]? = nil,
        lccn: [String]? = nil
    ) {
        self.isbn13 = isbn13
        self.isbn10 = isbn10
        self.oclc = oclc
        self.lccn = lccn
    }
}
