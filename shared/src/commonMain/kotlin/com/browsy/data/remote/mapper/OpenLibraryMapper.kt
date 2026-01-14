package com.browsy.data.remote.mapper

import com.browsy.data.model.Book
import com.browsy.data.remote.dto.OpenLibraryBookData

/**
 * Mapper for transforming Open Library API DTOs to domain Book models.
 *
 * Open Library-specific mapping logic:
 * - Combines title and subtitle with colon separator (e.g., "Foundation: A Novel")
 * - Uses first author from authors list (MVP: single author string)
 * - Prefers ISBN-13 from identifiers, falls back to ISBN-10 or query ISBN
 * - Extracts subject names from Subject objects for genre/vibe tagging
 * - Uses "OL:" ID prefix to distinguish from Google Books ("GB:") IDs
 * - Cover URL priority: large > medium > small
 *
 * Notable differences from Google Books:
 * - Open Library doesn't provide description in Books API (field will be null)
 * - publishDate format varies (can be year only like "1991" or full date)
 * - Cover URLs already included in API response (no need to construct)
 */
object OpenLibraryMapper {
    /**
     * Converts Open Library book data to domain Book model.
     *
     * @param isbn The ISBN used for the query (fallback if identifiers missing)
     * @return Book model with Open Library data
     */
    fun OpenLibraryBookData.toBook(isbn: String): Book {
        return Book(
            id = "OL:$isbn",
            title = if (subtitle != null) "$title: $subtitle" else title,
            author = authors?.firstOrNull()?.name ?: "Unknown Author",
            coverUrl = cover?.large ?: cover?.medium ?: cover?.small,
            description = null, // Open Library doesn't provide description in Books API
            publishedDate = publishDate,
            pageCount = numberOfPages,
            isbn = identifiers?.isbn_13?.firstOrNull()
                ?: identifiers?.isbn_10?.firstOrNull()
                ?: isbn,
            subjects = subjects?.map { it.name }.orEmpty()
        )
    }
}
