package com.browsy.android.ui.feed

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.browsy.config.BuildKonfig
import com.browsy.data.model.Book
import com.browsy.data.repository.BookRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * ViewModel managing book feed state and infinite scroll pagination.
 *
 * This ViewModel handles:
 * - Loading books from BookRepository
 * - Managing book list state with StateFlow for reactive UI
 * - Infinite scroll pagination with prefetch
 * - Loading state to prevent concurrent requests
 *
 * Pagination strategy:
 * - Loads 20 books per page
 * - Prefetches when user is 5 books from the end
 * - Prevents concurrent loads with isLoading flag
 *
 * @property repository BookRepository instance for fetching books
 * @property _books Mutable state holding the current list of books
 * @property books Public read-only StateFlow of books
 * @property _isLoading Mutable loading state flag
 * @property isLoading Public read-only StateFlow of loading state
 */
class FeedViewModel : ViewModel() {

    private val repository = BookRepository.create(googleBooksApiKey = BuildKonfig.GOOGLE_BOOKS_API_KEY)

    private val _books = MutableStateFlow<List<Book>>(emptyList())
    val books: StateFlow<List<Book>> = _books.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private var currentPage = 0
    private val pageSize = 20
    private val prefetchDistance = 5

    init {
        Log.d("FeedViewModel", "Initializing with API key: ${BuildKonfig.GOOGLE_BOOKS_API_KEY.take(8)}...")
        loadInitialBooks()
    }

    /**
     * Loads the first page of books on ViewModel creation.
     *
     * Uses "fantasy" as default search query for MVP.
     * Future phases will add user preferences and personalization.
     */
    private fun loadInitialBooks() {
        Log.d("FeedViewModel", "Starting initial book load...")
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val result = repository.searchBooks("fantasy")
                result.onSuccess { bookList ->
                    Log.d("FeedViewModel", "Successfully loaded ${bookList.size} books")
                    _books.value = bookList
                    currentPage = 1
                }
                result.onFailure { error ->
                    Log.e("FeedViewModel", "Error loading initial books: ${error.message}", error)
                }
            } catch (e: Exception) {
                Log.e("FeedViewModel", "Exception loading initial books: ${e.message}", e)
            } finally {
                _isLoading.value = false
                Log.d("FeedViewModel", "Initial load completed. Books count: ${_books.value.size}")
            }
        }
    }

    /**
     * Loads the next page of books and appends to current list.
     *
     * Only loads if not currently loading to prevent race conditions.
     * Uses startIndex parameter for proper pagination.
     */
    fun loadMoreBooks() {
        if (_isLoading.value) return

        viewModelScope.launch {
            _isLoading.value = true
            try {
                // For MVP, continue loading fantasy books
                // Use startIndex for proper pagination
                val startIndex = _books.value.size
                val result = repository.searchBooks("fantasy", startIndex = startIndex)
                result.onSuccess { bookList ->
                    if (bookList.isNotEmpty()) {
                        // Filter out any books that are already in our list (deduplicate by ID)
                        val existingIds = _books.value.map { it.id }.toSet()
                        val newBooks = bookList.filter { it.id !in existingIds }
                        _books.value = _books.value + newBooks
                        currentPage++
                    }
                }
                result.onFailure { error ->
                    println("Error loading more books: ${error.message}")
                }
            } catch (e: Exception) {
                println("Exception loading more books: ${e.message}")
            } finally {
                _isLoading.value = false
            }
        }
    }

    /**
     * Called when a book appears on screen.
     *
     * Triggers pagination when user is near the end of the current list.
     *
     * @param index The index of the book that just appeared
     */
    fun onBookAppear(index: Int) {
        val shouldLoadMore = index >= _books.value.size - prefetchDistance && !_isLoading.value
        if (shouldLoadMore) {
            loadMoreBooks()
        }
    }

    override fun onCleared() {
        super.onCleared()
        repository.close()
    }
}
