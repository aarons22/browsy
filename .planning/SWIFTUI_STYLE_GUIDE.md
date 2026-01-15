# SwiftUI Style Guide

This style guide establishes coding standards and best practices for the iOS portion of Browsy. Following these guidelines ensures consistency, maintainability, and high-quality code.

## Table of Contents

1. [Naming Conventions](#naming-conventions)
2. [State Management](#state-management)
3. [View Composition](#view-composition)
4. [Async/Await Usage](#asyncawait-usage)
5. [Type Safety](#type-safety)
6. [MVVM Architecture](#mvvm-architecture)
7. [Code Organization](#code-organization)

---

## Naming Conventions

### Views & ViewModels

- Use descriptive `UpperCamelCase` for view names
- Name views based on their purpose: `FeedView`, `BookDetailView`, `SearchResultsView`
- ViewModels should always end with `ViewModel` suffix: `FeedViewModel`, `BookDetailViewModel`

### Properties & Variables

```swift
// Use lowerCamelCase for properties and variables
let backgroundColor: Color = .blue
var isLoading: Bool = false

// Use 'is', 'has', or 'can' prefixes for booleans
var isSelected: Bool = false
var hasError: Bool = false
var canShare: Bool = true

// Mark internal state as private
private var selectedIndex: Int = 0
```

### Methods

```swift
// Use verb-style names, lowerCamelCase
func fetchBooks() { }
func updateUserProfile() { }

// Factory methods start with 'make'
func makeViewModel() -> BookViewModel { }

// Use clear, descriptive names
func handleBookSelection(_ book: Book) { }  // Good
func onBook(_ book: Book) { }               // Bad
```

---

## State Management

### Property Wrapper Selection

| Wrapper | Use Case |
|---------|----------|
| `@State` | Local, simple state within a single view |
| `@StateObject` | Reference types owned by this view (initialize here) |
| `@ObservedObject` | Reference types received from parent (don't initialize here) |
| `@Binding` | Two-way connection to parent state |
| `@EnvironmentObject` | Shared state across view hierarchy |
| `@Environment` | Access system properties and custom keys |

### Examples

```swift
// @State: Local state
struct FeedView: View {
    @State private var isSearching: Bool = false
    @State private var searchText: String = ""
}

// @StateObject: Owned reference type
struct ContentView: View {
    @StateObject private var viewModel = FeedViewModel()
}

// @ObservedObject: Received from parent
struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel  // Don't initialize!
}

// @Binding: Two-way binding
struct SearchField: View {
    @Binding var searchText: String

    var body: some View {
        TextField("Search", text: $searchText)
    }
}
```

### Rules

1. **Always mark state as `private`** unless it needs to be accessed externally
2. **Never initialize `@ObservedObject`** in the view that uses it - let the parent pass it
3. **Only `@StateObject` ensures objects survive view redraws** - use it for objects you create

---

## View Composition

### Break Views Early

Extract subviews when they:
- Have distinct responsibilities
- Can be reused
- Make the parent view easier to read

### Extraction Techniques

**1. Computed Properties (for non-reusable parts):**
```swift
struct BookDetailsView: View {
    let book: Book

    var body: some View {
        VStack {
            headerSection
            metadataSection
        }
    }

    var headerSection: some View {
        VStack {
            Text(book.title).font(.title)
            Text(book.author).foregroundColor(.gray)
        }
    }

    var metadataSection: some View {
        HStack {
            Label("\(book.year)", systemImage: "calendar")
            Label(book.isbn, systemImage: "barcode")
        }
    }
}
```

**2. Separate Views (for reusable components):**
```swift
struct BookCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading) {
            Text(book.title).font(.headline)
            Text(book.author).font(.subheadline).foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}
```

**3. @ViewBuilder for Conditional Content:**
```swift
@ViewBuilder
var contentView: some View {
    if viewModel.isLoading {
        ProgressView()
    } else if let error = viewModel.errorMessage {
        ErrorView(message: error)
    } else {
        bookList
    }
}
```

---

## Async/Await Usage

### Structured Concurrency

```swift
// Use .task modifier for loading data
var body: some View {
    VStack { }
        .task {
            await viewModel.loadBooks()
        }
}

// Use @MainActor for ViewModels that update UI
@MainActor
class BookViewModel: ObservableObject {
    @Published var books: [Book] = []

    func loadBooks() async {
        // Network call happens off main thread
        let data = try await fetchFromAPI()
        // UI update happens on main thread (guaranteed by @MainActor)
        self.books = data
    }
}
```

### Error Handling

```swift
@MainActor
class BookViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var errorMessage: String?

    func loadBooks() async {
        do {
            books = try await fetchBooks()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### Avoid

```swift
// DON'T: Use DispatchQueue.main in async/await code
Task {
    let data = try await fetchData()
    DispatchQueue.main.async {  // Wrong!
        self.data = data
    }
}

// DO: Use @MainActor instead
@MainActor
func loadData() async {
    self.data = try await fetchData()
}

// DON'T: Unnecessary nested tasks
Task {
    Task {  // Unnecessary!
        await doWork()
    }
}

// DO: Flat structure
Task {
    await doWork()
}
```

---

## Type Safety

### Safe Optional Handling

```swift
// AVOID: Force unwrapping
let title = optionalBook!.title  // Can crash

// DO: Optional binding
if let book = optionalBook {
    let title = book.title
}

// DO: Guard statement
guard let book = optionalBook else {
    return
}

// DO: Nil coalescing
let title = optionalBook?.title ?? "Unknown"

// DO: Optional chaining
optionalBook?.author?.displayName
```

### Safe Type Casting

```swift
// AVOID: Force casting
let book = response as! Book  // Can crash

// DO: Safe casting with optional
if let book = response as? Book {
    // Safe to use
}

// DO: With guard
guard let book = response as? Book else {
    return
}
```

### Kotlin Interop Casting

When working with Kotlin Multiplatform types:

```swift
// Current pattern (works but verbose)
let bookList = try await repo.searchBooksOrThrow(query: "fantasy")
if let kotlinBooks = bookList as? [Book] {
    books = kotlinBooks
}

// Better: Use guard for early exit
guard let kotlinBooks = bookList as? [Book] else {
    print("Failed to cast book list")
    return
}
books = kotlinBooks
```

---

## MVVM Architecture

### Layer Responsibilities

| Layer | Responsibility |
|-------|---------------|
| **View** | UI only - display data, handle user interactions |
| **ViewModel** | State + logic - coordinate between View and Model |
| **Model** | Data structures and business logic |

### ViewModel Pattern

```swift
@MainActor
class FeedViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var books: [Book] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private let repository: BookRepository

    // MARK: - Initialization
    init(repository: BookRepository) {
        self.repository = repository
    }

    // MARK: - Public Methods
    func loadBooks() async {
        isLoading = true
        errorMessage = nil

        do {
            books = try await repository.searchBooks(query: "fantasy")
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
```

### View Pattern

```swift
struct FeedView: View {
    @StateObject private var viewModel: FeedViewModel

    init(repository: BookRepository) {
        _viewModel = StateObject(
            wrappedValue: FeedViewModel(repository: repository)
        )
    }

    var body: some View {
        content
            .task {
                await viewModel.loadBooks()
            }
    }

    @ViewBuilder
    var content: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let error = viewModel.errorMessage {
            ErrorView(message: error)
        } else {
            bookList
        }
    }

    var bookList: some View {
        List(viewModel.books, id: \.id) { book in
            BookRowView(book: book)
        }
    }
}
```

---

## Code Organization

### File Structure

```
iosApp/
├── App/
│   └── iOSApp.swift              # App entry point
├── Features/
│   ├── Feed/
│   │   ├── Views/
│   │   │   ├── BookFeedView.swift
│   │   │   └── BookCoverCard.swift
│   │   └── ViewModels/
│   │       └── FeedViewModel.swift
│   ├── BookDetail/
│   │   ├── Views/
│   │   └── ViewModels/
│   └── Search/
│       ├── Views/
│       └── ViewModels/
├── Shared/
│   ├── Components/
│   │   ├── ErrorView.swift
│   │   ├── LoadingView.swift
│   │   └── EmptyStateView.swift
│   ├── Extensions/
│   │   └── View+Extensions.swift
│   └── Theme/
│       ├── Colors.swift
│       └── Fonts.swift
└── Resources/
    └── Assets.xcassets/
```

### Within-File Organization

```swift
import Foundation
import SwiftUI

// MARK: - Type Definition
struct BookView: View {
    // MARK: - Properties
    @StateObject private var viewModel: BookViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Initialization
    init(viewModel: BookViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        VStack {
            headerSection
            contentSection
        }
    }

    // MARK: - Subviews
    var headerSection: some View {
        // ...
    }

    var contentSection: some View {
        // ...
    }

    // MARK: - Methods
    private func deleteBook(_ book: Book) {
        // ...
    }
}

// MARK: - Preview
#Preview {
    BookView(viewModel: BookViewModel())
}
```

---

## Summary Checklist

- [ ] Use descriptive names following Swift naming conventions
- [ ] Choose the correct state property wrapper for each use case
- [ ] Mark state properties as `private`
- [ ] Extract views into smaller, focused components
- [ ] Use `@MainActor` for ViewModels that update UI
- [ ] Handle errors explicitly in async code
- [ ] Never force unwrap optionals - use safe alternatives
- [ ] Never force cast - use `as?` with `if let` or `guard`
- [ ] Follow MVVM separation of concerns
- [ ] Organize files by feature, not by type
- [ ] Use MARK comments to organize code within files

---

## References

- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- [Managing User Interface State - Apple](https://developer.apple.com/documentation/swiftui/managing-user-interface-state)
