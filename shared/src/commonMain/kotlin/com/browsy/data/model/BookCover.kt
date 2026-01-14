package com.browsy.data.model

/**
 * Utility model for managing book cover image URLs at different sizes.
 *
 * This separates cover image concerns from the Book model, allowing API-specific
 * size handling without cluttering the domain model. Different book APIs provide
 * covers at various resolutions (Open Library: S/M/L, Google Books: thumbnail/small/large).
 *
 * This is NOT @Serializable - it's a utility for consuming APIs, not storing data.
 * Book model stores a single coverUrl string, which can be processed into a BookCover
 * when needed for display.
 *
 * Usage:
 * - BookCover.fromUrl(url) - Create from single URL (all sizes point to same image)
 * - BookCover.EMPTY - Represents missing cover (all nulls)
 */
data class BookCover(
    val small: String? = null,   // thumbnail size (~100-150px)
    val medium: String? = null,  // list/grid view (~200-300px)
    val large: String? = null    // full-screen display (~500-800px)
) {
    companion object {
        /**
         * Creates a BookCover with all sizes pointing to the same URL.
         * Useful when API provides only one cover size.
         */
        fun fromUrl(url: String): BookCover {
            return BookCover(
                small = url,
                medium = url,
                large = url
            )
        }

        /**
         * Represents a book with no cover image available.
         */
        val EMPTY = BookCover(
            small = null,
            medium = null,
            large = null
        )
    }
}
