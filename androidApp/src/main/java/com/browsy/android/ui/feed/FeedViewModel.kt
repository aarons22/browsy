package com.browsy.android.ui.feed

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
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
 * API key note:
 * - Currently hardcoded for MVP (user provides their own key)
 * - Phase 5 will add proper secrets management
 *
 * @property repository BookRepository instance for fetching books
 * @property _books Mutable state holding the current list of books
 * @property books Public read-only StateFlow of books
 * @property _isLoading Mutable loading state flag
 * @property isLoading Public read-only StateFlow of loading state
 */
class FeedViewModel : ViewModel() {

    // TODO: Replace with user's own Google Books API key
    // Get your free API key at: https://console.cloud.google.com/
    private val repository = BookRepository.create(googleBooksApiKey = "YOUR_API_KEY_HERE")

    private val _books = MutableStateFlow<List<Book>>(emptyList())
    val books: StateFlow<List<Book>> = _books.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private var currentPage = 0
    private val pageSize = 20
    private val prefetchDistance = 5

    init {
        loadInitialBooks()
    }

    /**
     * Loads the first page of books on ViewModel creation.
     *
     * Uses "fantasy" as default search query for MVP.
     * Future phases will add user preferences and personalization.
     */
    private fun loadInitialBooks() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val result = repository.searchBooks("fantasy")
                result.onSuccess { bookList ->
                    _books.value = bookList
                    currentPage = 1
                }
                result.onFailure { error ->
                    // Log error - proper error UI in Phase 4
                    println("Error loading initial books: ${error.message}")
                }
            } catch (e: Exception) {
                println("Exception loading initial books: ${e.message}")
            } finally {
                _isLoading.value = false
            }
        }
    }

    /**
     * Loads the next page of books and appends to current list.
     *
     * Only loads if not currently loading to prevent race conditions.
     * Increments page counter and appends results to existing books.
     */
    fun loadMoreBooks() {
        if (_isLoading.value) return

        viewModelScope.launch {
            _isLoading.value = true
            try {
                // For MVP, continue loading fantasy books
                // Future: Use pagination offset or search with page parameter
                val result = repository.searchBooks("fantasy page:$currentPage")
                result.onSuccess { bookList ->
                    if (bookList.isNotEmpty()) {
                        _books.value = _books.value + bookList
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
