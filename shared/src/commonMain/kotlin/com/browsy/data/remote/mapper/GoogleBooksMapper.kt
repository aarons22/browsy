package com.browsy.data.remote.mapper

import com.browsy.data.model.Book
import com.browsy.data.remote.dto.IndustryIdentifier
import com.browsy.data.remote.dto.VolumeItem

/**
 * Mapper for transforming Google Books API DTOs to domain models.
 *
 * This object provides extension functions to convert Google Books API response objects
 * (VolumeItem) into our app's Book domain model. The mapping handles missing data gracefully
 * with sensible defaults and fallback strategies.
 *
 * Mapping strategies:
 * - Authors: Uses first author from list, falls back to "Unknown Author"
 * - Cover images: Prefers larger sizes (extraLarge → large → medium → thumbnail)
 * - ISBN: Prefers ISBN-13 over ISBN-10
 * - Subjects: Maps categories directly to subjects list
 */
object GoogleBooksMapper {

    /**
     * Converts a Google Books VolumeItem to a Book domain model.
     *
     * This mapping handles incomplete API data gracefully:
     * - Missing authors default to "Unknown Author"
     * - Cover URL selection prefers larger images for better quality
     * - ISBN-13 is preferred over ISBN-10 when both are available
     * - Empty lists are used for missing subjects/categories
     *
     * Example:
     * ```
     * val volumeItem = ... // from API response
     * val book = volumeItem.toBook()
     * ```
     *
     * @return Book domain model populated from this VolumeItem
     */
    fun VolumeItem.toBook(): Book {
        val info = volumeInfo
        return Book(
            id = id,
            title = info.title,
            author = info.authors?.firstOrNull() ?: "Unknown Author",
            coverUrl = (info.imageLinks?.extraLarge
                ?: info.imageLinks?.large
                ?: info.imageLinks?.medium
                ?: info.imageLinks?.thumbnail)?.toHttps(),
            description = info.description,
            publishedDate = info.publishedDate,
            pageCount = info.pageCount,
            isbn = extractIsbn13(info.industryIdentifiers)
                ?: extractIsbn10(info.industryIdentifiers),
            subjects = info.categories.orEmpty()
        )
    }

    /**
     * Extracts ISBN-13 from industry identifiers list.
     *
     * ISBN-13 is preferred over ISBN-10 as it's the modern standard and provides
     * better global coverage.
     *
     * @param identifiers List of industry identifiers from API response
     * @return ISBN-13 string if found, null otherwise
     */
    private fun extractIsbn13(identifiers: List<IndustryIdentifier>?): String? {
        return identifiers?.firstOrNull { it.type == "ISBN_13" }?.identifier
    }

    /**
     * Extracts ISBN-10 from industry identifiers list.
     *
     * Used as fallback when ISBN-13 is not available.
     *
     * @param identifiers List of industry identifiers from API response
     * @return ISBN-10 string if found, null otherwise
     */
    private fun extractIsbn10(identifiers: List<IndustryIdentifier>?): String? {
        return identifiers?.firstOrNull { it.type == "ISBN_10" }?.identifier
    }

    /**
     * Converts an HTTP URL to HTTPS.
     *
     * Google Books API sometimes returns HTTP URLs for cover images, which causes
     * iOS App Transport Security (ATS) to block the request. This extension ensures
     * all cover URLs use HTTPS.
     *
     * @return URL with https:// scheme, or original if already HTTPS or not HTTP
     */
    private fun String.toHttps(): String {
        return if (startsWith("http://")) {
            replaceFirst("http://", "https://")
        } else {
            this
        }
    }
}
