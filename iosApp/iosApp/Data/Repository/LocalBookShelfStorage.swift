import Foundation

/// Platform-specific storage for book shelf data using UserDefaults.
class LocalBookShelfStorage {
    private let userDefaults = UserDefaults.standard
    private let storageKey = "saved_books_data"
    
    /// Saves the JSON string representation of saved books.
    func save(_ data: String) {
        userDefaults.set(data, forKey: storageKey)
    }
    
    /// Loads the previously saved JSON string.
    func load() -> String? {
        return userDefaults.string(forKey: storageKey)
    }
}
