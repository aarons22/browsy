import Foundation

/// ViewModel for managing the book feed with infinite scroll and smart content rotation.
///
/// This viewmodel handles loading book data from the BookRepository using native Swift
/// async/await patterns. It supports pagination with automatic prefetching and smart
/// query rotation for feed variety.
///
/// Key features:
/// - Infinite scroll with automatic prefetch based on scroll position
/// - Smart query rotation for feed variety (fantasy, fiction, mystery, romance)
/// - In-memory deduplication to prevent duplicate books
/// - Loading state management for UI feedback
@MainActor
class FeedViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading: Bool = false

    private var repository: BookRepository?
    private var currentPage = 0
    private let pageSize = 20
    private let prefetchThreshold = 5
    private var loadCount: Int = 0
    private var currentQuery = "fantasy"
    private var currentOrderBy: String? = nil

    init(googleBooksApiKey: String) {
        self.repository = BookRepository(googleBooksApiKey: googleBooksApiKey)
    }

    /// Loads the initial set of books for the feed.
    ///
    /// This should be called once when the feed view appears. Uses the smart query
    /// strategy to determine which genre to load based on rotation.
    func loadInitialBooks() async {
        print("Loading initial books")
        guard !isLoading else {
            print("Already loading, returning")
            return
        }

        isLoading = true
        currentPage = 0

        do {
            guard let repo = repository else {
                print("Repository not initialized")
                isLoading = false
                return
            }

            // Get smart query strategy for current load
            let smartQuery = FeedStrategy.getSmartQuery(loadCount: loadCount)
            currentQuery = smartQuery.0
            currentOrderBy = smartQuery.1

            print("iOS DEBUG - Load count: \(loadCount)")
            print("iOS DEBUG - Using smart query: '\(currentQuery)' with orderBy: \(currentOrderBy ?? "nil")")

            // Search books using native async/await
            let bookList = try await repo.searchBooks(
                query: currentQuery,
                startIndex: 0,
                orderBy: currentOrderBy
            )

            books = bookList
            loadCount += 1 // Increment for next smart query rotation
            print("loaded \(books.count) books!")
        } catch {
            print("Error loading initial books: \(error)")
        }

        isLoading = false
    }

    /// Loads more books for pagination.
    ///
    /// This is called automatically when the user scrolls near the bottom of the feed.
    /// Uses the same query as the initial load for consistency.
    func loadMoreBooks() async {
        guard !isLoading else { return }

        isLoading = true

        do {
            guard let repo = repository else {
                print("Repository not initialized")
                isLoading = false
                return
            }

            let startIndex = books.count
            print("Loading more books with query: '\(currentQuery)', startIndex: \(startIndex)")
            print("iOS DEBUG - More books orderBy: \(currentOrderBy ?? "nil")")

            // Search books using native async/await
            let bookList = try await repo.searchBooks(
                query: currentQuery,
                startIndex: startIndex,
                orderBy: currentOrderBy
            )

            // Filter out any books that are already in our list (deduplicate by ID)
            let existingIds = Set(books.map { $0.id })
            let newBooks = bookList.filter { !existingIds.contains($0.id) }
            books.append(contentsOf: newBooks)
            currentPage += 1
        } catch {
            print("Error loading more books: \(error)")
        }

        isLoading = false
    }

    /// Called when a book appears in the scroll view.
    ///
    /// Triggers automatic prefetching when the user scrolls near the bottom.
    ///
    /// - Parameter index: The index of the book that appeared
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
