package com.browsy.android

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.browsy.android.viewmodels.FeedViewModel

/**
 * Factory for creating FeedViewModel with custom constructor parameters.
 */
class FeedViewModelFactory(
    private val application: Application,
    private val googleBooksApiKey: String
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(FeedViewModel::class.java)) {
            return FeedViewModel(application, googleBooksApiKey) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
