import Foundation

/// API client for Open Library Books API (https://openlibrary.org/dev/docs/api/books)
///
/// Open Library provides free access to book metadata and cover images:
/// - No API key required
/// - Books API: https://openlibrary.org/api/books?bibkeys=ISBN:xyz&format=json&jscmd=data
/// - Covers API: https://covers.openlibrary.org/b/isbn/xyz-L.jpg
///
/// Use cases:
/// - Fallback when Google Books has no results
/// - Backup for missing cover images
/// - ISBN-based book lookup
///
/// Response handling:
/// - API returns dynamic keys based on bibkey (e.g., "ISBN:0451526538")
/// - We parse JSON and extract the book data using the known bibkey
/// - Returns nil if book not found (empty response)
///
/// Example usage:
/// ```swift
/// let api = OpenLibraryAPI()
/// do {
///     if let bookData = try await api.getBookByIsbn("0451526538") {
///         print("Found: \(bookData.title)")
///     } else {
///         print("Book not found")
///     }
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
public actor OpenLibraryAPI {
    private let booksURL = URL(string: "https://openlibrary.org/api/books")!
    private let coversURL = "https://covers.openlibrary.org/b"
    private let session: URLSession

    /// Errors that can occur during API operations
    public enum APIError: Error {
        case invalidResponse
        case networkError(Error)
        case httpError(Int, String)
        case decodingError(Error)
    }

    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    /// Fetches book metadata by ISBN from Open Library.
    ///
    /// - Parameter isbn: ISBN-10 or ISBN-13 (hyphens optional)
    /// - Returns: OpenLibraryBookData if found, nil if not found
    /// - Throws: APIError on network or parsing errors
    public func getBookByIsbn(_ isbn: String) async throws -> OpenLibraryBookData? {
        let bibkey = "ISBN:\(isbn)"

        var components = URLComponents(url: booksURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "bibkeys", value: bibkey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "jscmd", value: "data")
        ]

        guard let url = components.url else {
            throw APIError.invalidResponse
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if !(200...299).contains(httpResponse.statusCode) {
                let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
                throw APIError.httpError(httpResponse.statusCode, errorBody)
            }

            // Parse response as dictionary with dynamic key
            // Response format: { "ISBN:xyz": { book data } }
            // Returns empty object {} if book not found
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let bookDataDict = json[bibkey] as? [String: Any] else {
                // Book not found - API returns empty object
                return nil
            }

            // Convert the dictionary back to data and decode to OpenLibraryBookData
            let bookData = try JSONSerialization.data(withJSONObject: bookDataDict)
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(OpenLibraryBookData.self, from: bookData)
            } catch {
                print("OpenLibraryAPI: Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            print("OpenLibraryAPI: Network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }

    /// Constructs Open Library cover image URL for given ISBN.
    ///
    /// - Parameters:
    ///   - isbn: ISBN-10 or ISBN-13 (hyphens optional)
    ///   - size: Cover size: "S" (small ~100px), "M" (medium ~200px), "L" (large ~500px)
    /// - Returns: Cover image URL (may 404 if cover not available)
    ///
    /// Note: This URL may return 404 if no cover exists. Client should handle fallback.
    public func getCoverUrl(isbn: String, size: String = "L") -> String {
        return "\(coversURL)/isbn/\(isbn)-\(size).jpg"
    }
}
