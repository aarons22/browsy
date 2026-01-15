package com.browsy.android.ui.feed

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.pager.VerticalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.AsyncImage

/**
 * BookFeedScreen - Main vertical swipe feed for browsing books.
 *
 * Implements TikTok-style vertical paging with:
 * - Full-screen book covers using VerticalPager
 * - High-quality image display via Coil AsyncImage
 * - Snap-to-position behavior (built into VerticalPager)
 * - Infinite scroll with automatic pagination
 * - Title/author overlay with gradient background
 * - Quick TBR action button (non-functional in this phase)
 *
 * Priority #1: Visual quality - covers are displayed at original quality
 * with no downsampling, ensuring crisp beautiful presentation.
 *
 * @param viewModel FeedViewModel managing book state and pagination
 */
@Composable
fun BookFeedScreen(
    viewModel: FeedViewModel = viewModel()
) {
    val books by viewModel.books.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()

    // Create pager state with dynamic page count
    val pagerState = rememberPagerState(pageCount = { books.size })

    // Monitor page changes for pagination trigger
    LaunchedEffect(pagerState.currentPage) {
        if (books.isNotEmpty()) {
            viewModel.onBookAppear(pagerState.currentPage)
        }
    }

    if (books.isEmpty() && !isLoading) {
        // Empty state - show loading or placeholder
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "Loading books...",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onBackground
            )
        }
    } else if (books.isNotEmpty()) {
        VerticalPager(
            state = pagerState,
            pageSpacing = 0.dp,
            key = { books[it].id },
            modifier = Modifier.fillMaxSize(),
            pageContent = { page ->
                BookCoverPage(
                    book = books[page],
                    modifier = Modifier.fillMaxSize()
                )
            }
        )
    }
}

/**
 * BookCoverPage - Individual page in the vertical pager.
 *
 * Displays:
 * - Full-screen book cover image (high quality, no downsampling)
 * - Bottom gradient overlay (transparent to black)
 * - Book title and author over gradient
 * - Floating TBR button (heart icon, top-right)
 *
 * Quality settings (from CONTEXT.md priority):
 * - ContentScale.Crop maintains aspect ratio and fills screen
 * - No size parameter = AsyncImage uses original quality
 * - Coil handles efficient loading and caching automatically
 *
 * @param book The book to display on this page
 * @param modifier Modifier for the page container
 */
@Composable
fun BookCoverPage(
    book: com.browsy.data.model.Book,
    modifier: Modifier = Modifier
) {
    Box(modifier = modifier) {
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
                // Non-functional for now - Phase 4 implements TBR functionality
            },
            modifier = Modifier
                .align(Alignment.TopEnd)
                .padding(16.dp)
        ) {
            Icon(
                imageVector = Icons.Default.Favorite,
                contentDescription = "Add to TBR"
            )
        }
    }
}
