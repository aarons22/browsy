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
        print("Loading initial books")
        guard !isLoading else {
            print("Already loading, returning")
            return
        }

        isLoading = true
        currentPage = 0

        do {
            // Load first page with hardcoded "fantasy" query for MVP
            guard let repo = repository else {
                print("Repository not initialized")
                isLoading = false
                return
            }

            let bookList = try await repo.searchBooksOrThrow(query: "fantasy")
            if let kotlinBooks = bookList as? [Book] {
                books = kotlinBooks
                print("loaded \(books.count) books!")
            } else {
                print("Failed to cast book list to [Book]")
            }
        } catch {
            print("Error loading initial books: \(error)")
        }

        isLoading = false
    }

    func loadMoreBooks() async {
        guard !isLoading else { return }

        isLoading = true

        do {
            // Load next page of books using startIndex for pagination
            // For MVP, we continue with "fantasy" query
            // In Phase 8 (Feed Personalization), this will use user preferences
            guard let repo = repository else {
                print("Repository not initialized")
                isLoading = false
                return
            }

            let startIndex = Int32(books.count)
            let bookList = try await repo.searchBooksOrThrow(query: "fantasy", startIndex: startIndex)
            if let kotlinBooks = bookList as? [Book] {
                // Filter out any books that are already in our list (deduplicate by ID)
                let existingIds = Set(books.map { $0.id })
                let newBooks = kotlinBooks.filter { !existingIds.contains($0.id) }
                books.append(contentsOf: newBooks)
                currentPage += 1
            }
        } catch {
            print("Error loading more books: \(error)")
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
