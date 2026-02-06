import Foundation

/// Client for Google Books API v1.
///
/// This client provides methods to search for books and fetch book details from the
/// Google Books API.
class GoogleBooksApi {
    private let apiKey: String
    private let baseUrl = "https://www.googleapis.com/books/v1/volumes"
    private let session: URLSession
    
    init(apiKey: String) {
        self.apiKey = apiKey
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }
    
    /// Searches for books matching the given query.
    ///
    /// Query syntax supports various operators:
    /// - Simple text: "kotlin programming"
    /// - Title search: "intitle:kotlin"
    /// - Author search: "inauthor:martin"
    /// - ISBN search: "isbn:9781234567890"
    /// - Subject: "subject:fiction"
    func searchBooks(
        query: String,
        maxResults: Int = 20,
        startIndex: Int = 0,
        orderBy: String? = nil
    ) async throws -> GoogleBooksResponse {
        var components = URLComponents(string: baseUrl)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "startIndex", value: "\(startIndex)"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        if let orderBy = orderBy {
            components.queryItems?.append(URLQueryItem(name: "orderBy", value: orderBy))
        }
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        print("GoogleBooksApi: Searching for '\(query)' (maxResults=\(maxResults), startIndex=\(startIndex))")
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("GoogleBooksApi: Response status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            let message = "Google Books API error \(httpResponse.statusCode): \(errorBody)"
            print("GoogleBooksApi: \(message)")
            throw NSError(domain: "GoogleBooksApi", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(GoogleBooksResponse.self, from: data)
        
        print("GoogleBooksApi: Successfully loaded \(result.totalItems) total items, \(result.items?.count ?? 0) items returned")
        
        return result
    }
    
    /// Fetches book details by ISBN.
    func getBookByIsbn(_ isbn: String) async throws -> GoogleBooksResponse {
        return try await searchBooks(query: "isbn:\(isbn)", maxResults: 1)
    }
    
    /// Closes the API client and releases resources.
    func close() {
        session.finishTasksAndInvalidate()
    }
}
