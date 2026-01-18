package com.browsy.android.ui.feed

import android.app.Application
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.browsy.config.BuildKonfig
import com.browsy.data.feed.FeedStrategy
import com.browsy.data.model.Book
import com.browsy.data.repository.BookRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.net.InetAddress
import java.net.UnknownHostException

/**
 * ViewModel managing book feed state and infinite scroll pagination.
 *
 * This ViewModel handles:
 * - Loading books from BookRepository
 * - Managing book list state with StateFlow for reactive UI
 * - Infinite scroll pagination with prefetch
 * - Loading state to prevent concurrent requests
 * - Network connectivity diagnostics for troubleshooting
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
 * @property _errorMessage Mutable error message state
 * @property errorMessage Public read-only StateFlow of error messages
 */
class FeedViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = BookRepository.create(googleBooksApiKey = BuildKonfig.GOOGLE_BOOKS_API_KEY)

    private val _books = MutableStateFlow<List<Book>>(emptyList())
    val books: StateFlow<List<Book>> = _books.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private var currentPage = 0
    private val pageSize = 20
    private val prefetchDistance = 5
    private var loadCount = 0 // Track feed loads for smart query rotation
    private var currentQuery = "fantasy" // Store current query for pagination
    private var currentOrderBy: String? = null // Store current orderBy for pagination

    init {
        Log.d("FeedViewModel", "Initializing with API key: ${BuildKonfig.GOOGLE_BOOKS_API_KEY.take(8)}...")
        loadInitialBooks()
        // Delay network connectivity check to avoid NetworkOnMainThreadException in constructor
        viewModelScope.launch {
            checkNetworkConnectivity()
        }
    }

    /**
     * Checks network connectivity and DNS resolution.
     * Provides detailed diagnostics for troubleshooting network issues.
     * Must be called from a coroutine context to avoid NetworkOnMainThreadException.
     */
    private suspend fun checkNetworkConnectivity() {
        val connectivityManager = getApplication<Application>().getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = connectivityManager.activeNetwork
        val capabilities = connectivityManager.getNetworkCapabilities(network)

        Log.d("FeedViewModel", "Network check:")
        Log.d("FeedViewModel", "  - Active network: $network")
        Log.d("FeedViewModel", "  - Has internet: ${capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true}")
        Log.d("FeedViewModel", "  - Validated: ${capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED) == true}")
        Log.d("FeedViewModel", "  - Not metered: ${capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED) == true}")

        // Test DNS resolution for googleapis.com on IO thread to avoid NetworkOnMainThreadException
        withContext(Dispatchers.IO) {
            try {
                val address = InetAddress.getByName("www.googleapis.com")
                Log.d("FeedViewModel", "DNS resolution successful for www.googleapis.com: ${address.hostAddress}")
            } catch (e: UnknownHostException) {
                Log.e("FeedViewModel", "DNS resolution failed for www.googleapis.com: ${e.message}")
                _errorMessage.value = "Network connectivity issue: Cannot resolve www.googleapis.com. Check internet connection and DNS settings."
            }
        }
    }

    /**
     * Loads the first page of books on ViewModel creation.
     *
     * Uses smart feed strategy with rotation to provide fresh, relevant content
     * while maintaining discovery and variety. Balances recent popular books,
     * high-quality classics, and serendipitous discovery.
     */
    private fun loadInitialBooks() {
        Log.d("FeedViewModel", "Starting initial book load...")
        viewModelScope.launch {
            _isLoading.value = true
            _errorMessage.value = null
            try {
                // Get smart query strategy for current load
                val (query, orderBy) = FeedStrategy.getSmartQuery(loadCount)
                currentQuery = query
                currentOrderBy = orderBy
                Log.d("FeedViewModel", "Using smart query: '$query' with orderBy: $orderBy")

                val result = repository.searchBooks(query, orderBy = orderBy)
                result.onSuccess { bookList ->
                    Log.d("FeedViewModel", "Successfully loaded ${bookList.size} books")
                    _books.value = bookList
                    currentPage = 1
                    loadCount++ // Increment for next smart query rotation
                }
                result.onFailure { error ->
                    val errorMsg = "Failed to load books: ${error.message}"
                    Log.e("FeedViewModel", errorMsg, error)
                    _errorMessage.value = when {
                        error.message?.contains("Unable to resolve host") == true ->
                            "Cannot connect to Google Books API. Check your internet connection and DNS settings."
                        error.message?.contains("timeout") == true ->
                            "Request timed out. Check your internet connection."
                        error.message?.contains("401") == true || error.message?.contains("403") == true ->
                            "API authentication failed. Check your Google Books API key."
                        else -> "Network error: ${error.message}"
                    }
                }
            } catch (e: Exception) {
                val errorMsg = "Exception loading initial books: ${e.message}"
                Log.e("FeedViewModel", errorMsg, e)
                _errorMessage.value = "Unexpected error: ${e.message}"
            } finally {
                _isLoading.value = false
                Log.d("FeedViewModel", "Initial load completed. Books count: ${_books.value.size}")
            }
        }
    }

    /**
     * Loads the next page of books and appends to current list.
     *
     * Uses the same query and orderBy as the initial load to maintain consistency
     * within a browsing session. Only loads if not currently loading to prevent race conditions.
     */
    fun loadMoreBooks() {
        if (_isLoading.value) return

        viewModelScope.launch {
            _isLoading.value = true
            try {
                // Use same query and orderBy as initial load for consistency
                val startIndex = _books.value.size
                Log.d("FeedViewModel", "Loading more books with query: '$currentQuery', startIndex: $startIndex")

                val result = repository.searchBooks(
                    query = currentQuery,
                    startIndex = startIndex,
                    orderBy = currentOrderBy
                )
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
                    Log.e("FeedViewModel", "Error loading more books: ${error.message}", error)
                    _errorMessage.value = when {
                        error.message?.contains("Unable to resolve host") == true ->
                            "Cannot connect to Google Books API. Check your internet connection."
                        error.message?.contains("timeout") == true ->
                            "Request timed out. Check your internet connection."
                        else -> "Network error: ${error.message}"
                    }
                }
            } catch (e: Exception) {
                Log.e("FeedViewModel", "Exception loading more books: ${e.message}", e)
                _errorMessage.value = "Unexpected error loading more books: ${e.message}"
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

    /**
     * Retry loading books after a failure.
     * Clears error state and attempts to load books again.
     */
    fun retry() {
        Log.d("FeedViewModel", "Retrying book load...")
        _errorMessage.value = null
        viewModelScope.launch {
            checkNetworkConnectivity()
        }
        if (_books.value.isEmpty()) {
            loadInitialBooks()
        } else {
            loadMoreBooks()
        }
    }

    /**
     * Clear error message.
     */
    fun clearError() {
        _errorMessage.value = null
    }

    override fun onCleared() {
        super.onCleared()
        repository.close()
    }
}
