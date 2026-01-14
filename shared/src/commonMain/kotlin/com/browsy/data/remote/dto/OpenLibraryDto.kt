package com.browsy.data.remote.dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonObject

/**
 * DTOs for Open Library Books API (https://openlibrary.org/dev/docs/api/books)
 *
 * Open Library API response structure:
 * - Uses dynamic keys based on bibkey (e.g., "ISBN:0451526538")
 * - Response format: { "ISBN:xyz": { book data } }
 * - We use JsonObject to handle dynamic keys, extract in mapper
 * - jscmd=data returns comprehensive book metadata including cover URLs
 *
 * Example response:
 * {
 *   "ISBN:0451526538": {
 *     "title": "Foundation",
 *     "authors": [{"name": "Isaac Asimov", "url": "/authors/OL34221A"}],
 *     "publishers": [{"name": "Del Rey"}],
 *     "publish_date": "1991",
 *     "number_of_pages": 296,
 *     "cover": {
 *       "small": "https://covers.openlibrary.org/b/id/123-S.jpg",
 *       "medium": "https://covers.openlibrary.org/b/id/123-M.jpg",
 *       "large": "https://covers.openlibrary.org/b/id/123-L.jpg"
 *     }
 *   }
 * }
 */
@Serializable
data class OpenLibraryResponse(
    // Dynamic key based on bibkey (e.g., "ISBN:0451526538")
    // Use JsonObject to handle dynamic keys, then extract in mapper
    val data: JsonObject
)

/**
 * Book data from Open Library jscmd=data response.
 * All fields except title are nullable to handle varying data completeness.
 */
@Serializable
data class OpenLibraryBookData(
    val title: String,
    val subtitle: String? = null,
    val authors: List<Author>? = null,
    val publishers: List<Publisher>? = null,
    @SerialName("publish_date")
    val publishDate: String? = null,
    @SerialName("number_of_pages")
    val numberOfPages: Int? = null,
    val subjects: List<Subject>? = null,
    val cover: Cover? = null,
    val identifiers: Identifiers? = null
)

/**
 * Author with name and optional Open Library URL.
 */
@Serializable
data class Author(
    val name: String,
    val url: String? = null
)

/**
 * Publisher name from Open Library.
 */
@Serializable
data class Publisher(
    val name: String
)

/**
 * Subject/genre with name and optional Open Library URL.
 */
@Serializable
data class Subject(
    val name: String,
    val url: String? = null
)

/**
 * Cover image URLs at different sizes.
 * Open Library provides small, medium, and large sizes.
 */
@Serializable
data class Cover(
    val small: String? = null,
    val medium: String? = null,
    val large: String? = null
)

/**
 * Book identifiers (ISBN-13, ISBN-10, OCLC, LCCN).
 * Open Library uses snake_case for these fields.
 */
@Serializable
data class Identifiers(
    val isbn_13: List<String>? = null,
    val isbn_10: List<String>? = null,
    val oclc: List<String>? = null,
    val lccn: List<String>? = null
)
