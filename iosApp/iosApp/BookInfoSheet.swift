import SwiftUI
import shared

struct BookInfoSheet: View {
    let book: Book
    @ObservedObject var shelfViewModel: ShelfViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Small cover image centered at top
                if let coverUrl = book.coverUrl, let url = URL(string: coverUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 200)
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)
                }

                // Title and Author
                Text(book.title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Pub date and genres
                if let pubDate = book.publishedDate {
                    Text("Published: \(pubDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !book.subjects.isEmpty {
                    Text(book.subjects.prefix(3).joined(separator: " • "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Description
                if let description = book.description_ {
                    Text(description)
                        .font(.body)
                        .lineLimit(nil)
                }

                Spacer().frame(height: 20)

                // Action buttons grid (2x2)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ActionButton(
                        title: "TBR",
                        icon: shelfViewModel.isOnTBR ? "heart.fill" : "heart",
                        isActive: shelfViewModel.isOnTBR
                    ) {
                        shelfViewModel.toggleTBR(bookId: book.id)
                    }

                    ActionButton(
                        title: "Recommend",
                        icon: shelfViewModel.isOnRecommend ? "star.fill" : "star",
                        isActive: shelfViewModel.isOnRecommend
                    ) {
                        shelfViewModel.toggleRecommend(bookId: book.id)
                    }

                    ActionButton(
                        title: "Read",
                        icon: shelfViewModel.isRead ? "checkmark.circle.fill" : "checkmark.circle",
                        isActive: shelfViewModel.isRead
                    ) {
                        shelfViewModel.toggleRead(bookId: book.id)
                    }

                    ActionButton(
                        title: "Buy",
                        icon: "cart",
                        isActive: false
                    ) {
                        openBuyOptions()
                    }
                }
            }
            .padding()
        }
        .onAppear {
            shelfViewModel.loadState(for: book.id)
        }
    }

    private func openBuyOptions() {
        // Open Amazon search for book title + author
        let query = "\(book.title) \(book.author)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://www.amazon.com/s?k=\(query)") {
            UIApplication.shared.open(url)
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isActive ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(isActive ? .accentColor : .primary)
            .cornerRadius(12)
        }
    }
}
