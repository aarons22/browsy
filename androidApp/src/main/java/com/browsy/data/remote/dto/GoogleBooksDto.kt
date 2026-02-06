package com.browsy.data.remote.dto

import kotlinx.serialization.Serializable

/**
 * Data transfer objects for Google Books API responses.
 *
 * These DTOs mirror the structure of the Google Books API v1 response format.
 * All fields are nullable or have default values to handle partial API responses gracefully.
 *
 * API Documentation: https://developers.google.com/books/docs/v1/reference/volumes
 */

/**
 * Root response object from Google Books API search.
 *
 * @property items List of volume items (books) matching the search query. Null if no results.
 * @property totalItems Total number of items available (not just in this response).
 */
@Serializable
data class GoogleBooksResponse(
    val items: List<VolumeItem>? = null,
    val totalItems: Int = 0
)

/**
 * Individual book/volume item from Google Books API.
 *
 * @property id Unique identifier for this volume (Google Books ID).
 * @property volumeInfo Metadata about the book (title, authors, etc.).
 */
@Serializable
data class VolumeItem(
    val id: String,
    val volumeInfo: VolumeInfo
)

/**
 * Volume metadata containing book details.
 *
 * @property title Book title (always present).
 * @property authors List of author names. Null if not available.
 * @property description Book description/summary. Null if not available.
 * @property publishedDate Publication date in various formats (YYYY, YYYY-MM, YYYY-MM-DD). Null if unknown.
 * @property pageCount Number of pages. Null if not available.
 * @property categories List of categories/genres. Null if not available.
 * @property imageLinks Cover image URLs at different sizes. Null if no covers available.
 * @property industryIdentifiers ISBN and other identifiers. Null if not available.
 */
@Serializable
data class VolumeInfo(
    val title: String,
    val authors: List<String>? = null,
    val description: String? = null,
    val publishedDate: String? = null,
    val pageCount: Int? = null,
    val categories: List<String>? = null,
    val imageLinks: ImageLinks? = null,
    val industryIdentifiers: List<IndustryIdentifier>? = null
)

/**
 * Cover image URLs at different resolutions.
 *
 * Google Books provides multiple sizes for flexibility. All fields are nullable
 * as availability varies by book.
 *
 * @property thumbnail ~128x128px
 * @property smallThumbnail ~80x80px (lower quality)
 * @property small ~300px height
 * @property medium ~575px height
 * @property large ~800px height
 * @property extraLarge ~1280px height
 */
@Serializable
data class ImageLinks(
    val thumbnail: String? = null,
    val smallThumbnail: String? = null,
    val small: String? = null,
    val medium: String? = null,
    val large: String? = null,
    val extraLarge: String? = null
)

/**
 * Book identifier (ISBN, ISSN, etc.).
 *
 * @property type Identifier type (e.g., "ISBN_10", "ISBN_13", "ISSN").
 * @property identifier The actual identifier value.
 */
@Serializable
data class IndustryIdentifier(
    val type: String,
    val identifier: String
)
