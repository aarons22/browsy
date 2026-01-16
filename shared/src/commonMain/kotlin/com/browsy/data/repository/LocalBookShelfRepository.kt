package com.browsy.data.repository

import com.browsy.data.cache.currentTimeMillis
import com.browsy.data.model.BookShelf
import com.browsy.data.model.SavedBook
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

/**
 * Repository for managing local book shelf storage.
 *
 * This repository provides CRUD operations for saving books to shelves (TBR, RECOMMEND, READ).
 * Data is persisted locally using platform-specific storage mechanisms.
 *
 * Note: A book can be on multiple shelves simultaneously. For example, a user might
 * mark a book as READ and also RECOMMEND it to others.
 *
 * Thread safety: This class is designed for single-threaded access in KMP commonMain.
 * For concurrent access, external synchronization is required.
 */
class LocalBookShelfRepository {
    private val storage: LocalBookShelfStorage = LocalBookShelfStorage()
    private val json = Json { ignoreUnknownKeys = true }
    private var cache: MutableMap<String, SavedBook> = mutableMapOf()

    init {
        loadFromStorage()
    }

    /**
     * Adds a book to a shelf.
     *
     * If the book is already on the specified shelf, this updates the savedAt timestamp.
     *
     * @param bookId The ID of the book to save
     * @param shelf The shelf to add the book to
     */
    fun addToShelf(bookId: String, shelf: BookShelf) {
        val saved = SavedBook(bookId, shelf, currentTimeMillis())
        cache[cacheKey(bookId, shelf)] = saved
        persist()
    }

    /**
     * Removes a book from a shelf.
     *
     * If the book is not on the specified shelf, this is a no-op.
     *
     * @param bookId The ID of the book to remove
     * @param shelf The shelf to remove the book from
     */
    fun removeFromShelf(bookId: String, shelf: BookShelf) {
        cache.remove(cacheKey(bookId, shelf))
        persist()
    }

    /**
     * Checks if a book is on a specific shelf.
     *
     * @param bookId The ID of the book to check
     * @param shelf The shelf to check
     * @return true if the book is on the shelf, false otherwise
     */
    fun isOnShelf(bookId: String, shelf: BookShelf): Boolean =
        cache.containsKey(cacheKey(bookId, shelf))

    /**
     * Gets all saved books on a specific shelf.
     *
     * @param shelf The shelf to retrieve books from
     * @return List of SavedBook entries, sorted by savedAt descending (most recent first)
     */
    fun getShelf(shelf: BookShelf): List<SavedBook> =
        cache.values.filter { it.shelf == shelf }.sortedByDescending { it.savedAt }

    /**
     * Gets all shelves that a book is on.
     *
     * @param bookId The ID of the book to check
     * @return List of BookShelf values the book is saved to
     */
    fun getShelves(bookId: String): List<BookShelf> =
        BookShelf.entries.filter { isOnShelf(bookId, it) }

    /**
     * Toggles a book's presence on a shelf.
     *
     * If the book is on the shelf, removes it. If not, adds it.
     *
     * @param bookId The ID of the book
     * @param shelf The shelf to toggle
     * @return true if the book is now on the shelf, false if removed
     */
    fun toggleShelf(bookId: String, shelf: BookShelf): Boolean {
        return if (isOnShelf(bookId, shelf)) {
            removeFromShelf(bookId, shelf)
            false
        } else {
            addToShelf(bookId, shelf)
            true
        }
    }

    private fun cacheKey(bookId: String, shelf: BookShelf) = "$bookId:$shelf"

    private fun loadFromStorage() {
        storage.load()?.let { data ->
            try {
                val list = json.decodeFromString<List<SavedBook>>(data)
                cache = list.associateBy { cacheKey(it.bookId, it.shelf) }.toMutableMap()
            } catch (e: Exception) {
                // If data is corrupted, start fresh
                cache = mutableMapOf()
            }
        }
    }

    private fun persist() {
        val data = json.encodeToString(cache.values.toList())
        storage.save(data)
    }
}
