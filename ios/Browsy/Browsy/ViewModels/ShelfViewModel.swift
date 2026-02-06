import SwiftUI

/// ViewModel for managing book shelf state (TBR, Recommend, Read).
///
/// This viewmodel handles adding/removing books from shelves using the native Swift
/// LocalBookShelfRepository with async/await patterns. To support synchronous UI queries,
/// it maintains a local cache that mirrors the repository state.
///
/// The UI updates are handled through @Published properties that trigger view refreshes.
@MainActor
class ShelfViewModel: ObservableObject {
    private let repository: LocalBookShelfRepository

    @Published var isOnTBR: Bool = false
    @Published var isOnRecommend: Bool = false
    @Published var isRead: Bool = false
    @Published var shelfRefreshId = UUID()

    // Local cache for synchronous queries (mirrors repository state)
    private var cachedTBR: Set<String> = []
    private var cachedRecommend: Set<String> = []
    private var cachedRead: Set<String> = []

    init(repository: LocalBookShelfRepository = LocalBookShelfRepository()) {
        self.repository = repository
        // Initialize cache from repository
        Task {
            await refreshCache()
        }
    }

    /// Refreshes the local cache from the repository.
    private func refreshCache() async {
        let tbrBooks = await repository.getShelf(.tbr)
        let recommendBooks = await repository.getShelf(.recommend)
        let readBooks = await repository.getShelf(.read)

        cachedTBR = Set(tbrBooks.map { $0.bookId })
        cachedRecommend = Set(recommendBooks.map { $0.bookId })
        cachedRead = Set(readBooks.map { $0.bookId })
    }

    /// Loads the shelf state for a specific book.
    ///
    /// This should be called when displaying book details to show the current shelf state.
    ///
    /// - Parameter bookId: The ID of the book to load state for
    func loadState(for bookId: String) {
        isOnTBR = cachedTBR.contains(bookId)
        isOnRecommend = cachedRecommend.contains(bookId)
        isRead = cachedRead.contains(bookId)
    }

    /// Checks if a book is on the TBR shelf (synchronous).
    ///
    /// Uses local cache for immediate response. Cache is kept in sync with repository.
    ///
    /// - Parameter bookId: The ID of the book to check
    /// - Returns: true if the book is on TBR shelf
    func isBookOnTBR(bookId: String) -> Bool {
        return cachedTBR.contains(bookId)
    }

    /// Checks if a book is on the Recommend shelf (synchronous).
    ///
    /// Uses local cache for immediate response. Cache is kept in sync with repository.
    ///
    /// - Parameter bookId: The ID of the book to check
    /// - Returns: true if the book is on Recommend shelf
    func isBookOnRecommend(bookId: String) -> Bool {
        return cachedRecommend.contains(bookId)
    }

    /// Checks if a book has been marked as Read (synchronous).
    ///
    /// Uses local cache for immediate response. Cache is kept in sync with repository.
    ///
    /// - Parameter bookId: The ID of the book to check
    /// - Returns: true if the book is marked as Read
    func isBookRead(bookId: String) -> Bool {
        return cachedRead.contains(bookId)
    }

    /// Toggles a book's TBR shelf state.
    ///
    /// If the book is on TBR, removes it. If not, adds it.
    ///
    /// - Parameter bookId: The ID of the book to toggle
    func toggleTBR(bookId: String) {
        let currentState = cachedTBR.contains(bookId)

        Task {
            if currentState {
                await repository.removeFromShelf(bookId: bookId, shelf: .tbr)
                cachedTBR.remove(bookId)
            } else {
                await repository.addToShelf(bookId: bookId, shelf: .tbr)
                cachedTBR.insert(bookId)
            }

            // Update current state if this is the loaded book
            if isOnTBR == currentState {
                isOnTBR.toggle()
            }

            // Trigger refresh for any views observing this change
            shelfRefreshId = UUID()
        }
    }

    /// Toggles a book's Recommend shelf state.
    ///
    /// If the book is on Recommend, removes it. If not, adds it.
    ///
    /// - Parameter bookId: The ID of the book to toggle
    func toggleRecommend(bookId: String) {
        let currentState = cachedRecommend.contains(bookId)

        Task {
            if currentState {
                await repository.removeFromShelf(bookId: bookId, shelf: .recommend)
                cachedRecommend.remove(bookId)
            } else {
                await repository.addToShelf(bookId: bookId, shelf: .recommend)
                cachedRecommend.insert(bookId)
            }

            // Update current state if this is the loaded book
            if isOnRecommend == currentState {
                isOnRecommend.toggle()
            }

            // Trigger refresh for any views observing this change
            shelfRefreshId = UUID()
        }
    }

    /// Toggles a book's Read state.
    ///
    /// If the book is marked as Read, removes it. If not, adds it.
    ///
    /// - Parameter bookId: The ID of the book to toggle
    func toggleRead(bookId: String) {
        let currentState = cachedRead.contains(bookId)

        Task {
            if currentState {
                await repository.removeFromShelf(bookId: bookId, shelf: .read)
                cachedRead.remove(bookId)
            } else {
                await repository.addToShelf(bookId: bookId, shelf: .read)
                cachedRead.insert(bookId)
            }

            // Update current state if this is the loaded book
            if isRead == currentState {
                isRead.toggle()
            }

            // Trigger refresh for any views observing this change
            shelfRefreshId = UUID()
        }
    }
}
