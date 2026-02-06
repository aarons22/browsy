import Foundation

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

    init() {
        repository = BookRepository.create(googleBooksApiKey: BuildConfig.shared.googleBooksApiKey)
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

            // Use simple version without orderBy (iOS doesn't support orderBy yet)
            let result = await repo.searchBooks(
                query: currentQuery,
                startIndex: 0
            )
            
            switch result {
            case .success(let bookList):
                books = bookList
                loadCount += 1 // Increment for next smart query rotation
                print("loaded \(books.count) books!")
            case .failure(let error):
                print("Error loading initial books: \(error)")
            }
        }

        isLoading = false
    }

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

            // Use simple version without orderBy
            let result = await repo.searchBooks(
                query: currentQuery,
                startIndex: startIndex
            )
            
            switch result {
            case .success(let bookList):
                // Filter out any books that are already in our list (deduplicate by ID)
                let existingIds = Set(books.map { $0.id })
                let newBooks = bookList.filter { !existingIds.contains($0.id) }
                books.append(contentsOf: newBooks)
                currentPage += 1
            case .failure(let error):
                print("Error loading more books: \(error)")
            }
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
