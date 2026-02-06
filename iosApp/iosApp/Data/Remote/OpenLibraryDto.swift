import Foundation

// MARK: - Open Library API DTOs

/// Open Library response is a dictionary with dynamic keys based on bibkey
typealias OpenLibraryResponse = [String: OpenLibraryBookData]

/// Book data from Open Library jscmd=data response.
struct OpenLibraryBookData: Codable {
    let title: String
    let subtitle: String?
    let authors: [OLAuthor]?
    let publishers: [OLPublisher]?
    let publishDate: String?
    let numberOfPages: Int?
    let subjects: [OLSubject]?
    let cover: OLCover?
    let identifiers: OLIdentifiers?
    
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
}

/// Author with name and optional Open Library URL.
struct OLAuthor: Codable {
    let name: String
    let url: String?
}

/// Publisher name from Open Library.
struct OLPublisher: Codable {
    let name: String
}

/// Subject/genre with name and optional Open Library URL.
struct OLSubject: Codable {
    let name: String
    let url: String?
}

/// Cover image URLs at different sizes.
struct OLCover: Codable {
    let small: String?
    let medium: String?
    let large: String?
}

/// Book identifiers (ISBN-13, ISBN-10, OCLC, LCCN).
struct OLIdentifiers: Codable {
    let isbn13: [String]?
    let isbn10: [String]?
    let oclc: [String]?
    let lccn: [String]?
    
    enum CodingKeys: String, CodingKey {
        case isbn13 = "isbn_13"
        case isbn10 = "isbn_10"
        case oclc
        case lccn
    }
}
