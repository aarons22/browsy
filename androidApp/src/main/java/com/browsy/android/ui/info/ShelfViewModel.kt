package com.browsy.android.ui.info

import androidx.lifecycle.ViewModel
import com.browsy.data.model.BookShelf
import com.browsy.data.repository.LocalBookShelfRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * ViewModel for managing shelf state for a book.
 *
 * Provides observable state flows for each shelf type (TBR, Recommend, Read)
 * and toggle actions to add/remove books from shelves.
 *
 * Usage:
 * 1. Call loadState(bookId) when displaying book info
 * 2. Observe isOnTBR, isOnRecommend, isRead state flows
 * 3. Call toggle* methods to update shelf membership
 */
class ShelfViewModel : ViewModel() {
    private val repository = LocalBookShelfRepository()

    private val _isOnTBR = MutableStateFlow(false)
    val isOnTBR: StateFlow<Boolean> = _isOnTBR.asStateFlow()

    private val _isOnRecommend = MutableStateFlow(false)
    val isOnRecommend: StateFlow<Boolean> = _isOnRecommend.asStateFlow()

    private val _isRead = MutableStateFlow(false)
    val isRead: StateFlow<Boolean> = _isRead.asStateFlow()

    /**
     * Loads the current shelf state for a book.
     *
     * @param bookId The ID of the book to load state for
     */
    fun loadState(bookId: String) {
        _isOnTBR.value = repository.isOnShelf(bookId, BookShelf.TBR)
        _isOnRecommend.value = repository.isOnShelf(bookId, BookShelf.RECOMMEND)
        _isRead.value = repository.isOnShelf(bookId, BookShelf.READ)
    }

    /**
     * Toggles whether the book is on the TBR (To Be Read) shelf.
     *
     * @param bookId The ID of the book to toggle
     */
    fun toggleTBR(bookId: String) {
        if (_isOnTBR.value) {
            repository.removeFromShelf(bookId, BookShelf.TBR)
        } else {
            repository.addToShelf(bookId, BookShelf.TBR)
        }
        _isOnTBR.value = !_isOnTBR.value
    }

    /**
     * Toggles whether the book is on the Recommend shelf.
     *
     * @param bookId The ID of the book to toggle
     */
    fun toggleRecommend(bookId: String) {
        if (_isOnRecommend.value) {
            repository.removeFromShelf(bookId, BookShelf.RECOMMEND)
        } else {
            repository.addToShelf(bookId, BookShelf.RECOMMEND)
        }
        _isOnRecommend.value = !_isOnRecommend.value
    }

    /**
     * Toggles whether the book is on the Read shelf.
     *
     * @param bookId The ID of the book to toggle
     */
    fun toggleRead(bookId: String) {
        if (_isRead.value) {
            repository.removeFromShelf(bookId, BookShelf.READ)
        } else {
            repository.addToShelf(bookId, BookShelf.READ)
        }
        _isRead.value = !_isRead.value
    }
}
