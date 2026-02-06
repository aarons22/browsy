import Foundation

/// iOS implementation of LocalBookShelfStorage using UserDefaults.
///
/// This implementation uses the standard user defaults, which is suitable for
/// small amounts of data like saved book shelves. For larger datasets,
/// consider migrating to Core Data or SQLite.
public actor LocalBookShelfStorage {
    private let userDefaults: UserDefaults
    private let key = "book_shelves"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Saves JSON data to UserDefaults
    public func save(_ data: String) {
        userDefaults.set(data, forKey: key)
    }

    /// Loads JSON data from UserDefaults
    public func load() -> String? {
        return userDefaults.string(forKey: key)
    }
}
