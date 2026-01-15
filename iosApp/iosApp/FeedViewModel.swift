import Foundation
import shared

@MainActor
class FeedViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading: Bool = false

    private var repository: BookRepository?
    private var currentPage = 0
    private let pageSize = 20
    private let prefetchThreshold = 5

    init() {
        repository = BookRepository.companion.create(googleBooksApiKey: BuildKonfig.shared.GOOGLE_BOOKS_API_KEY)
    }

    deinit {
        repository?.close()
    }

    func loadInitialBooks() async {
        guard !isLoading else { return }

        isLoading = true
        currentPage = 0

        do {
            // Load first page with hardcoded "fantasy" query for MVP
            let result = try await repository?.searchBooks(query: "fantasy")

            switch result {
            case .success(let bookList):
                if let kotlinBooks = bookList as? [Book] {
                    books = kotlinBooks
                }
            case .failure(let error):
                print("Error loading initial books: \(error)")
            case .none:
                print("Repository not initialized")
            }
        } catch {
            print("Error loading initial books: \(error)")
        }

        isLoading = false
    }

    func loadMoreBooks() async {
        guard !isLoading else { return }

        isLoading = true
        currentPage += 1

        do {
            // Load next page of books
            // For MVP, we continue with "fantasy" query
            // In Phase 8 (Feed Personalization), this will use user preferences
            let result = try await repository?.searchBooks(query: "fantasy")

            switch result {
            case .success(let bookList):
                if let kotlinBooks = bookList as? [Book] {
                    books.append(contentsOf: kotlinBooks)
                }
            case .failure(let error):
                print("Error loading more books: \(error)")
                currentPage -= 1 // Rollback page increment on failure
            case .none:
                print("Repository not initialized")
                currentPage -= 1
            }
        } catch {
            print("Error loading more books: \(error)")
            currentPage -= 1 // Rollback page increment on failure
        }

        isLoading = false
    }

    func onBookAppear(index: Int) {
        // Check if we should load more books
        if shouldLoadMore(currentIndex: index) {
            Task {
                await loadMoreBooks()
            }
        }
    }

    private func shouldLoadMore(currentIndex: Int) -> Bool {
        return currentIndex >= books.count - prefetchThreshold && !isLoading
    }
}
