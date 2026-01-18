import SwiftUI
import shared

@MainActor
class ShelfViewModel: ObservableObject {
    private let repository: LocalBookShelfRepository

    @Published var isOnTBR: Bool = false
    @Published var isOnRecommend: Bool = false
    @Published var isRead: Bool = false
    @Published var shelfRefreshId = UUID()

    init(repository: LocalBookShelfRepository = LocalBookShelfRepository()) {
        self.repository = repository
    }

    func loadState(for bookId: String) {
        isOnTBR = repository.isOnShelf(bookId: bookId, shelf: .tbr)
        isOnRecommend = repository.isOnShelf(bookId: bookId, shelf: .recommend)
        isRead = repository.isOnShelf(bookId: bookId, shelf: .read)
    }

    func isBookOnTBR(bookId: String) -> Bool {
        return repository.isOnShelf(bookId: bookId, shelf: .tbr)
    }

    func isBookOnRecommend(bookId: String) -> Bool {
        return repository.isOnShelf(bookId: bookId, shelf: .recommend)
    }

    func isBookRead(bookId: String) -> Bool {
        return repository.isOnShelf(bookId: bookId, shelf: .read)
    }

    func toggleTBR(bookId: String) {
        let currentState = repository.isOnShelf(bookId: bookId, shelf: .tbr)
        if currentState {
            repository.removeFromShelf(bookId: bookId, shelf: .tbr)
        } else {
            repository.addToShelf(bookId: bookId, shelf: .tbr)
        }

        // Update current state if this is the loaded book
        if isOnTBR == currentState {
            isOnTBR.toggle()
        }

        // Trigger refresh for any views observing this change
        shelfRefreshId = UUID()
    }

    func toggleRecommend(bookId: String) {
        let currentState = repository.isOnShelf(bookId: bookId, shelf: .recommend)
        if currentState {
            repository.removeFromShelf(bookId: bookId, shelf: .recommend)
        } else {
            repository.addToShelf(bookId: bookId, shelf: .recommend)
        }

        // Update current state if this is the loaded book
        if isOnRecommend == currentState {
            isOnRecommend.toggle()
        }

        // Trigger refresh for any views observing this change
        shelfRefreshId = UUID()
    }

    func toggleRead(bookId: String) {
        let currentState = repository.isOnShelf(bookId: bookId, shelf: .read)
        if currentState {
            repository.removeFromShelf(bookId: bookId, shelf: .read)
        } else {
            repository.addToShelf(bookId: bookId, shelf: .read)
        }

        // Update current state if this is the loaded book
        if isRead == currentState {
            isRead.toggle()
        }

        // Trigger refresh for any views observing this change
        shelfRefreshId = UUID()
    }
}
