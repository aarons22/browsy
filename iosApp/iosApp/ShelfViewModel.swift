import SwiftUI
import shared

@MainActor
class ShelfViewModel: ObservableObject {
    private let repository: LocalBookShelfRepository

    @Published var isOnTBR: Bool = false
    @Published var isOnRecommend: Bool = false
    @Published var isRead: Bool = false

    init(repository: LocalBookShelfRepository = LocalBookShelfRepository()) {
        self.repository = repository
    }

    func loadState(for bookId: String) {
        isOnTBR = repository.isOnShelf(bookId: bookId, shelf: .tbr)
        isOnRecommend = repository.isOnShelf(bookId: bookId, shelf: .recommend)
        isRead = repository.isOnShelf(bookId: bookId, shelf: .read)
    }

    func toggleTBR(bookId: String) {
        if isOnTBR {
            repository.removeFromShelf(bookId: bookId, shelf: .tbr)
        } else {
            repository.addToShelf(bookId: bookId, shelf: .tbr)
        }
        isOnTBR.toggle()
    }

    func toggleRecommend(bookId: String) {
        if isOnRecommend {
            repository.removeFromShelf(bookId: bookId, shelf: .recommend)
        } else {
            repository.addToShelf(bookId: bookId, shelf: .recommend)
        }
        isOnRecommend.toggle()
    }

    func toggleRead(bookId: String) {
        if isRead {
            repository.removeFromShelf(bookId: bookId, shelf: .read)
        } else {
            repository.addToShelf(bookId: bookId, shelf: .read)
        }
        isRead.toggle()
    }
}
