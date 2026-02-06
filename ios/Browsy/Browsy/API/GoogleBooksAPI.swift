import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Client for Google Books API v1.
///
/// This client provides methods to search for books and fetch book details from the
/// Google Books API using native URLSession.
///
/// API Documentation: https://developers.google.com/books/docs/v1/using
///
/// Usage:
/// ```swift
/// let api = GoogleBooksAPI(apiKey: "your-api-key")
/// do {
///     let response = try await api.searchBooks(query: "kotlin programming")
///     response.items?.forEach { book in
///         print(book.volumeInfo.title)
///     }
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
public actor GoogleBooksAPI {
    private let apiKey: String
    private let baseURL = URL(string: "https://www.googleapis.com/books/v1/volumes")!
    private let session: URLSession

    /// Errors that can occur during API operations
    public enum APIError: Error {
        case invalidResponse
        case networkError(Error)
        case httpError(Int, String)
        case decodingError(Error)
    }

    public init(apiKey: String) {
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
    ///
    /// - Parameters:
    ///   - query: Search query string (supports Google Books query syntax)
    ///   - maxResults: Maximum number of results to return (1-40, default 20)
    ///   - startIndex: Index of first result to return (for pagination, default 0)
    ///   - orderBy: Sort order: "newest" or "relevance" (default nil uses API default)
    /// - Returns: GoogleBooksResponse on success
    /// - Throws: APIError on failure
    public func searchBooks(
        query: String,
        maxResults: Int = 20,
        startIndex: Int = 0,
        orderBy: String? = nil
    ) async throws -> GoogleBooksResponse {
        print("GoogleBooksAPI: Searching for '\(query)' (maxResults=\(maxResults), startIndex=\(startIndex))")
        print("GoogleBooksAPI: Making request to \(baseURL)")

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
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
            throw APIError.invalidResponse
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            print("GoogleBooksAPI: Response status: \(httpResponse.statusCode)")

            if !(200...299).contains(httpResponse.statusCode) {
                let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
                let message = "Google Books API error \(httpResponse.statusCode): \(errorBody)"
                print("GoogleBooksAPI: \(message)")
                throw APIError.httpError(httpResponse.statusCode, errorBody)
            }

            let decoder = JSONDecoder()
            do {
                let googleResponse = try decoder.decode(GoogleBooksResponse.self, from: data)
                print("GoogleBooksAPI: Successfully loaded \(googleResponse.totalItems) total items, \(googleResponse.items?.count ?? 0) items returned")
                return googleResponse
            } catch {
                print("GoogleBooksAPI: Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            let detailedMessage: String
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    detailedMessage = "No internet connection. Check network settings."
                case .timedOut:
                    detailedMessage = "Request timed out. Check network connection."
                case .cannotFindHost, .cannotConnectToHost:
                    detailedMessage = "Cannot connect to googleapis.com. Check network configuration."
                default:
                    detailedMessage = "Network error: \(urlError.localizedDescription)"
                }
            } else {
                detailedMessage = "Network error: \(error.localizedDescription)"
            }
            print("GoogleBooksAPI: Exception during search - \(detailedMessage)")
            print("GoogleBooksAPI: Original exception: \(type(of: error)): \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }

    /// Fetches book details by ISBN.
    ///
    /// This is a convenience method that performs an ISBN search with maxResults=1.
    /// Accepts both ISBN-10 and ISBN-13 formats.
    ///
    /// - Parameter isbn: Book ISBN (10 or 13 digits, with or without hyphens)
    /// - Returns: GoogleBooksResponse with at most one item
    /// - Throws: APIError on failure
    public func getBookByIsbn(_ isbn: String) async throws -> GoogleBooksResponse {
        return try await searchBooks(query: "isbn:\(isbn)", maxResults: 1)
    }
}
