import SwiftUI

/// Main entry point for the Browsy iOS app.
///
/// This app uses native Swift implementations of all business logic previously
/// handled by Kotlin Multiplatform shared module. The architecture includes:
///
/// - **Models**: Native Swift structs with Codable conformance
/// - **API Clients**: URLSession-based actors with async/await
/// - **Repositories**: Actor-isolated data access with caching
/// - **ViewModels**: @MainActor ObservableObject classes for UI state
/// - **Views**: SwiftUI views with native async/await support
///
/// Configuration:
/// - Requires GOOGLE_BOOKS_API_KEY to be set (via xcconfig or environment)
/// - Uses UserDefaults for local book shelf persistence
/// - Supports iOS 17.0+
@main
struct BrowsyApp: App {
    // API Key configuration - will be replaced with xcconfig-based approach
    // For now, using a placeholder that should be replaced at build time
    private let googleBooksApiKey: String = {
        // Try to load from environment first (for local development)
        if let envKey = ProcessInfo.processInfo.environment["GOOGLE_BOOKS_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        // Fall back to build configuration (from xcconfig)
        // This will need to be configured in Xcode build settings
        #if DEBUG
        return "YOUR_DEBUG_API_KEY_HERE"
        #else
        return "YOUR_RELEASE_API_KEY_HERE"
        #endif
    }()

    var body: some Scene {
        WindowGroup {
            BookFeedView(googleBooksApiKey: googleBooksApiKey)
        }
    }
}
