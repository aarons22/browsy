import Foundation

/// API client for Open Library Books API.
///
/// Open Library provides free access to book metadata and cover images.
class OpenLibraryApi {
    private let booksUrl = "https://openlibrary.org/api/books"
    private let coversUrl = "https://covers.openlibrary.org/b"
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }
    
    /// Fetches book metadata by ISBN from Open Library.
    func getBookByIsbn(_ isbn: String) async throws -> OpenLibraryBookData? {
        let bibkey = "ISBN:\(isbn)"
        
        var components = URLComponents(string: booksUrl)!
        components.queryItems = [
            URLQueryItem(name: "bibkeys", value: bibkey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "jscmd", value: "data")
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await session.data(from: url)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(OpenLibraryResponse.self, from: data)
        
        // Extract book data from dynamic key
        return response[bibkey]
    }
    
    /// Constructs Open Library cover image URL for given ISBN.
    func getCoverUrl(isbn: String, size: String = "L") -> String {
        // size: S (small), M (medium), L (large)
        return "\(coversUrl)/isbn/\(isbn)-\(size).jpg"
    }
    
    /// Closes the API client and releases resources.
    func close() {
        session.finishTasksAndInvalidate()
    }
}
