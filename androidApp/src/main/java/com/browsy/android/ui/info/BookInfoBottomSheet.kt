package com.browsy.android.ui.info

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.Star
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.SheetState
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.AsyncImage
import com.browsy.data.model.Book
import java.net.URLEncoder

/**
 * BookInfoBottomSheet - Modal bottom sheet displaying book details and actions.
 *
 * Shows:
 * - Centered book cover (smaller than feed view)
 * - Title and author
 * - Publication date (if available)
 * - Genres/subjects (first 3)
 * - Description (if available)
 * - 2x2 grid of action buttons: TBR, Recommend, Read, Buy
 *
 * Action buttons toggle shelf state with visual feedback:
 * - Filled icon and primary container color when active
 * - Outline icon and surface variant color when inactive
 *
 * Buy button opens Amazon search in external browser.
 *
 * @param book The book to display
 * @param onDismiss Callback when sheet is dismissed
 * @param sheetState State for the modal bottom sheet
 * @param shelfViewModel ViewModel managing shelf state
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookInfoBottomSheet(
    book: Book,
    onDismiss: () -> Unit,
    sheetState: SheetState = rememberModalBottomSheetState(),
    shelfViewModel: ShelfViewModel = viewModel()
) {
    val context = LocalContext.current
    val isOnTBR by shelfViewModel.isOnTBR.collectAsState()
    val isOnRecommend by shelfViewModel.isOnRecommend.collectAsState()
    val isRead by shelfViewModel.isRead.collectAsState()

    LaunchedEffect(book.id) {
        shelfViewModel.loadState(book.id)
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp)
                .padding(bottom = 32.dp)
        ) {
            // Cover image centered
            book.coverUrl?.let { url ->
                AsyncImage(
                    model = url,
                    contentDescription = "Cover of ${book.title}",
                    contentScale = ContentScale.Fit,
                    modifier = Modifier
                        .height(200.dp)
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(8.dp))
                )
                Spacer(modifier = Modifier.height(16.dp))
            }

            // Title
            Text(
                text = book.title,
                style = MaterialTheme.typography.titleLarge
            )
            Spacer(modifier = Modifier.height(4.dp))

            // Author
            Text(
                text = book.author,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(modifier = Modifier.height(8.dp))

            // Pub date
            book.publishedDate?.let {
                Text(
                    text = "Published: $it",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // Genres
            if (book.subjects.isNotEmpty()) {
                Text(
                    text = book.subjects.take(3).joinToString(" • "),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Description
            book.description?.let {
                Text(
                    text = it,
                    style = MaterialTheme.typography.bodyMedium
                )
                Spacer(modifier = Modifier.height(24.dp))
            }

            // Action buttons 2x2 grid
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                ActionButton(
                    title = "TBR",
                    icon = if (isOnTBR) Icons.Filled.Favorite else Icons.Filled.FavoriteBorder,
                    isActive = isOnTBR,
                    modifier = Modifier.weight(1f)
                ) {
                    shelfViewModel.toggleTBR(book.id)
                }
                ActionButton(
                    title = "Recommend",
                    icon = if (isOnRecommend) Icons.Filled.Star else Icons.Outlined.Star,
                    isActive = isOnRecommend,
                    modifier = Modifier.weight(1f)
                ) {
                    shelfViewModel.toggleRecommend(book.id)
                }
            }
            Spacer(modifier = Modifier.height(12.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                ActionButton(
                    title = "Read",
                    icon = if (isRead) Icons.Filled.CheckCircle else Icons.Filled.Check,
                    isActive = isRead,
                    modifier = Modifier.weight(1f)
                ) {
                    shelfViewModel.toggleRead(book.id)
                }
                ActionButton(
                    title = "Buy",
                    icon = Icons.Filled.ShoppingCart,
                    isActive = false,
                    modifier = Modifier.weight(1f)
                ) {
                    val query = URLEncoder.encode("${book.title} ${book.author}", "UTF-8")
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.amazon.com/s?k=$query"))
                    context.startActivity(intent)
                }
            }
        }
    }
}

/**
 * ActionButton - Individual action button in the 2x2 grid.
 *
 * @param title Label text below the icon
 * @param icon Vector icon to display
 * @param isActive Whether the action is currently active (affects styling)
 * @param modifier Modifier for the button
 * @param onClick Callback when button is tapped
 */
@Composable
private fun ActionButton(
    title: String,
    icon: ImageVector,
    isActive: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        modifier = modifier.height(64.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = if (isActive)
                MaterialTheme.colorScheme.primaryContainer
            else
                MaterialTheme.colorScheme.surfaceVariant
        ),
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = icon,
                contentDescription = title,
                tint = if (isActive)
                    MaterialTheme.colorScheme.primary
                else
                    MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = title,
                style = MaterialTheme.typography.labelSmall,
                color = if (isActive)
                    MaterialTheme.colorScheme.primary
                else
                    MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}
