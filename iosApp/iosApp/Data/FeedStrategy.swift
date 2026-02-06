import Foundation

/// Reliable feed strategy focused on genre variety and quality results.
struct FeedStrategy {
    
    /// Generates reliable queries focused on genre variety and quality.
    ///
    /// Uses simple genre terms with orderBy=relevance, which is more reliable than
    /// orderBy=newest for returning actual readable books instead of catalog metadata.
    static func getSmartQuery(loadCount: Int = 0) -> (String, String?) {
        switch loadCount % 4 {
        case 0:
            return ("fantasy", nil)
        case 1:
            return ("fiction", nil)
        case 2:
            return ("mystery", nil)
        case 3:
            return ("romance", nil)
        default:
            return ("fantasy", nil)
        }
    }
}
