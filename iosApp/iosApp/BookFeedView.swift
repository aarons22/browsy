import SwiftUI
import shared

struct BookFeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        ZStack {
            if viewModel.books.isEmpty && !viewModel.isLoading {
                Text("Loading books...")
                    .foregroundColor(.gray)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.books.enumerated()), id: \.element.id) { index, book in
                            BookCoverCard(book: book, index: index, viewModel: viewModel)
                                .containerRelativeFrame(.vertical)
                                .onAppear {
                                    viewModel.onBookAppear(index: index)
                                }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
            }
        }
        .task {
            await viewModel.loadInitialBooks()
        }
    }
}

struct BookCoverCard: View {
    let book: Book
    let index: Int
    let viewModel: FeedViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Book cover image - extends into safe areas
                bookCoverImage
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                // Bottom overlay with title, author, and TBR button
                VStack {
                    Spacer()

                    HStack(alignment: .bottom, spacing: 12) {
                        // Title and author - constrained to prevent overflow
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.headline)
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .truncationMode(.tail)

                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // TBR button (non-functional for now - Phase 4 will implement)
                        Button(action: {
                            // Placeholder - will be implemented in Phase 4
                        }) {
                            Image(systemName: "heart")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .fixedSize()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 200)
                    )
                }
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var bookCoverImage: some View {
        if let coverUrl = book.coverUrl, let url = URL(string: coverUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.3)
                        .overlay(
                            ProgressView()
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderView(message: "Cover not available")
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            placeholderView(message: "No cover available")
        }
    }

    private func placeholderView(message: String) -> some View {
        Color.gray.opacity(0.3)
            .overlay(
                VStack {
                    Image(systemName: "book.closed")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            )
    }
}

#Preview {
    BookFeedView()
}
