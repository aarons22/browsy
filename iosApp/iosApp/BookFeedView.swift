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
        ZStack {
            // Book cover image
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
                        Color.gray.opacity(0.3)
                            .overlay(
                                VStack {
                                    Image(systemName: "book.closed")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    Text("Cover not available")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Fallback for books without cover URL
                Color.gray.opacity(0.3)
                    .overlay(
                        VStack {
                            Image(systemName: "book.closed")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No cover available")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }

            // Bottom overlay with title, author, and TBR button
            VStack {
                Spacer()

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(2)

                        Text(book.author)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }

                    Spacer()

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
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    BookFeedView()
}
