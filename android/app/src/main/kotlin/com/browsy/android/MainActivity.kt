package com.browsy.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.browsy.android.ui.feed.BookFeedScreen
import com.browsy.android.ui.theme.BrowsyTheme
import com.browsy.android.viewmodels.FeedViewModel

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Get API key from resources or BuildConfig
        val apiKey = getString(R.string.google_books_api_key)

        setContent {
            BrowsyTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    // Create FeedViewModel with API key
                    val feedViewModel: FeedViewModel = viewModel(
                        factory = FeedViewModelFactory(
                            application = application,
                            googleBooksApiKey = apiKey
                        )
                    )
                    BookFeedScreen(viewModel = feedViewModel)
                }
            }
        }
    }
}
