package com.browsy.android.ui.feed

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.pager.VerticalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.AsyncImage
import com.browsy.android.ui.info.BookInfoBottomSheet
import com.browsy.android.ui.info.ShelfViewModel
import com.browsy.data.model.Book

/**
 * BookFeedScreen - Main vertical swipe feed for browsing books.
 *
 * Implements TikTok-style vertical paging with:
 * - Full-screen book covers using VerticalPager
 * - High-quality image display via Coil AsyncImage
 * - Snap-to-position behavior (built into VerticalPager)
 * - Infinite scroll with automatic pagination
 * - Title/author overlay with gradient background
 * - Quick TBR action button with shelf state
 * - Tap to show book info bottom sheet
 *
 * Priority #1: Visual quality - covers are displayed at original quality
 * with no downsampling, ensuring crisp beautiful presentation.
 *
 * @param viewModel FeedViewModel managing book state and pagination
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookFeedScreen(
    viewModel: FeedViewModel = viewModel()
) {
    val books by viewModel.books.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()

    // State for selected book and bottom sheet
    var selectedBook by remember { mutableStateOf<Book?>(null) }
    var showInfoSheet by remember { mutableStateOf(false) }

    // Create pager state with dynamic page count
    val pagerState = rememberPagerState(pageCount = { books.size })

    // Monitor page changes for pagination trigger
    LaunchedEffect(pagerState.currentPage) {
        if (books.isNotEmpty()) {
            viewModel.onBookAppear(pagerState.currentPage)
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        when {
            // Initial loading state - show spinner
            isLoading && books.isEmpty() -> {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        CircularProgressIndicator()
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "Loading books...",
                            style = MaterialTheme.typography.bodyLarge,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                    }
                }
            }

            // Empty state after loading - show error/retry
            !isLoading && books.isEmpty() -> {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Icon(
                            imageVector = Icons.Default.Warning,
                            contentDescription = "Error",
                            modifier = Modifier.size(48.dp),
                            tint = MaterialTheme.colorScheme.error
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "Unable to load books",
                            style = MaterialTheme.typography.bodyLarge,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "Check your internet connection",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }

            // Normal state - show pager
            books.isNotEmpty() -> {
                VerticalPager(
                    state = pagerState,
                    pageSpacing = 0.dp,
                    key = { books[it].id },
                    modifier = Modifier.fillMaxSize(),
                    pageContent = { page ->
                        BookCoverPage(
                            book = books[page],
                            onBookClick = {
                                selectedBook = books[page]
                                showInfoSheet = true
                            },
                            modifier = Modifier.fillMaxSize()
                        )
                    }
                )
            }
        }

        // Book info bottom sheet (outside the when block, always available)
        if (showInfoSheet && selectedBook != null) {
            BookInfoBottomSheet(
                book = selectedBook!!,
                onDismiss = {
                    showInfoSheet = false
                    selectedBook = null
                }
            )
        }
    }
}

/**
 * BookCoverPage - Individual page in the vertical pager.
 *
 * Displays:
 * - Full-screen book cover image (high quality, no downsampling)
 * - Bottom gradient overlay (transparent to black)
 * - Book title and author over gradient
 * - Floating TBR button with shelf state (filled heart when saved)
 * - Tap gesture to show book info
 *
 * Quality settings (from CONTEXT.md priority):
 * - ContentScale.Crop maintains aspect ratio and fills screen
 * - No size parameter = AsyncImage uses original quality
 * - Coil handles efficient loading and caching automatically
 *
 * @param book The book to display on this page
 * @param onBookClick Callback when book cover is tapped
 * @param modifier Modifier for the page container
 */
@Composable
fun BookCoverPage(
    book: Book,
    onBookClick: () -> Unit,
    modifier: Modifier = Modifier,
    shelfViewModel: ShelfViewModel = viewModel()
) {
    val isOnTBR by shelfViewModel.isOnTBR.collectAsState()

    // Load shelf state when book changes
    LaunchedEffect(book.id) {
        shelfViewModel.loadState(book.id)
    }

    Box(
        modifier = modifier.clickable { onBookClick() }
    ) {
        // Full-screen book cover image
        AsyncImage(
            model = book.coverUrl ?: "",
            contentDescription = "Cover of ${book.title}",
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )

        // Bottom gradient overlay for text readability
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(200.dp)
                .align(Alignment.BottomCenter)
                .background(
                    brush = Brush.verticalGradient(
                        colors = listOf(
                            Color.Transparent,
                            Color.Black.copy(alpha = 0.7f)
                        )
                    )
                )
        )

        // Book info overlay at bottom
        Column(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .padding(24.dp)
        ) {
            Text(
                text = book.title,
                style = MaterialTheme.typography.titleLarge,
                color = Color.White,
                maxLines = 2
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = book.author,
                style = MaterialTheme.typography.bodyMedium,
                color = Color.White.copy(alpha = 0.8f),
                maxLines = 1
            )
        }

        // TBR/Wishlist floating action button (top-right)
        FloatingActionButton(
            onClick = {
                shelfViewModel.toggleTBR(book.id)
            },
            modifier = Modifier
                .align(Alignment.TopEnd)
                .padding(16.dp)
        ) {
            Icon(
                imageVector = if (isOnTBR) Icons.Filled.Favorite else Icons.Filled.FavoriteBorder,
                contentDescription = if (isOnTBR) "Remove from TBR" else "Add to TBR"
            )
        }
    }
}
