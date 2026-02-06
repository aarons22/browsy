import Foundation

// MARK: - Google Books API DTOs

/// Root response object from Google Books API search.
struct GoogleBooksResponse: Codable {
    let items: [VolumeItem]?
    let totalItems: Int
    
    enum CodingKeys: String, CodingKey {
        case items
        case totalItems
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([VolumeItem].self, forKey: .items)
        totalItems = try container.decodeIfPresent(Int.self, forKey: .totalItems) ?? 0
    }
}

/// Individual book/volume item from Google Books API.
struct VolumeItem: Codable {
    let id: String
    let volumeInfo: VolumeInfo
}

/// Volume metadata containing book details.
struct VolumeInfo: Codable {
    let title: String
    let authors: [String]?
    let description: String?
    let publishedDate: String?
    let pageCount: Int?
    let categories: [String]?
    let imageLinks: ImageLinks?
    let industryIdentifiers: [IndustryIdentifier]?
}

/// Cover image URLs at different resolutions.
struct ImageLinks: Codable {
    let thumbnail: String?
    let smallThumbnail: String?
    let small: String?
    let medium: String?
    let large: String?
    let extraLarge: String?
}

/// Book identifier (ISBN, ISSN, etc.).
struct IndustryIdentifier: Codable {
    let type: String
    let identifier: String
}
