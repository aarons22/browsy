import Foundation

/// Reliable feed strategy focused on genre variety and quality results.
///
/// After testing, Google Books API date operators ("newer:") and orderBy=newest
/// are unreliable - they often return old books or library catalogs. This approach
/// uses simple genre terms with relevance ordering to get quality, varied books
/// that users actually want to read.
///
/// Strategy: Simple genre rotation with relevance-based ordering for consistent,
/// quality results that support discoverable browsing.
public struct FeedStrategy {

    /// Generates reliable queries focused on genre variety and quality.
    ///
    /// Uses simple genre terms with orderBy=relevance, which is more reliable than
    /// orderBy=newest for returning actual readable books instead of catalog metadata.
    ///
    /// - Parameter loadCount: Number of times feed has been loaded (for rotation)
    /// - Returns: Tuple of (query, orderBy) optimized for reliable, quality results
    public static func getSmartQuery(loadCount: Int = 0) -> (String, String?) {
        switch loadCount % 4 {
        case 0:
            return ("fantasy", nil)  // Original working query
        case 1:
            return ("fiction", nil)
        case 2:
            return ("mystery", nil)
        case 3:
            return ("romance", nil)
        default:
            return ("fantasy", nil) // fallback to original
        }
    }
}
