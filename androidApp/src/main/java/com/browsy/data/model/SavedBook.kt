package com.browsy.data.model

import kotlinx.serialization.Serializable

/**
 * Represents a book saved to a user's shelf.
 *
 * This model captures the relationship between a book and a shelf, including
 * when it was saved. The bookId references the Book.id from the data model.
 *
 * Note: A book can be on multiple shelves simultaneously (e.g., READ and RECOMMEND).
 *
 * @property bookId Reference to Book.id
 * @property shelf The shelf this book is saved to
 * @property savedAt Unix timestamp (milliseconds) when the book was saved
 */
@Serializable
data class SavedBook(
    val bookId: String,
    val shelf: BookShelf,
    val savedAt: Long
)
