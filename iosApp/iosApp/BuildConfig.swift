import Foundation

/// Build configuration constants.
///
/// This provides access to build-time configuration values like API keys.
/// For native iOS, we'll read from a Configuration.plist file.
struct BuildConfig {
    static let shared = BuildConfig()
    
    private let configuration: [String: Any]
    
    private init() {
        // Try to load from Configuration.plist
        if let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            configuration = dict
        } else {
            // Fall back to Info.plist
            configuration = Bundle.main.infoDictionary ?? [:]
        }
    }
    
    var googleBooksApiKey: String {
        if let key = configuration["GOOGLE_BOOKS_API_KEY"] as? String, !key.isEmpty {
            return key
        }
        // Fall back to environment variable or empty string
        return ProcessInfo.processInfo.environment["GOOGLE_BOOKS_API_KEY"] ?? ""
    }
}
