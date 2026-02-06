package com.browsy.data.model

/**
 * Utility for enhancing book cover image URLs to get the highest quality possible.
 *
 * This addresses the issue where APIs (particularly Google Books) often return only
 * low-quality thumbnail images. The enhancer applies URL manipulation techniques
 * to extract higher resolution versions when possible.
 *
 * Enhanced strategies:
 * - Google Books: Modify zoom parameter for larger images (zoom=1 → zoom=0)
 * - Open Library: Ensure we're using the Large (L) size variant
 * - URL optimization: Remove unnecessary parameters that may limit quality
 *
 * Usage:
 * ```
 * val enhancer = ImageUrlEnhancer()
 * val highQualityUrl = enhancer.enhance(originalUrl)
 * ```
 */
object ImageUrlEnhancer {

    /**
     * Enhances an image URL to get the highest quality version available.
     *
     * Applies source-specific optimization strategies:
     * - Google Books: Reduces zoom parameter for larger image sizes
     * - Open Library: Ensures Large (L) size is used
     * - Generic: Removes common quality-limiting parameters
     *
     * @param originalUrl The original image URL from API response
     * @return Enhanced URL likely to provide higher quality image
     */
    fun enhance(originalUrl: String?): String? {
        if (originalUrl == null) return null

        return when {
            originalUrl.contains("books.google.com/books/content") -> enhanceGoogleBooksUrl(originalUrl)
            originalUrl.contains("covers.openlibrary.org") -> enhanceOpenLibraryUrl(originalUrl)
            else -> originalUrl // Return original if no enhancement strategy available
        }
    }

    /**
     * Enhances Google Books cover URLs for higher quality.
     *
     * Google Books uses a zoom parameter where lower values = larger images:
     * - zoom=5: ~80x80px (smallThumbnail)
     * - zoom=1: ~128x128px (thumbnail)
     * - zoom=0: ~256px+ (larger, better quality)
     *
     * Also removes edge=curl parameter which may limit image access.
     *
     * @param url Original Google Books image URL
     * @return URL modified for maximum quality
     */
    private fun enhanceGoogleBooksUrl(url: String): String {
        return url
            // Change zoom to 0 for largest available size
            .replace("zoom=5", "zoom=0")
            .replace("zoom=1", "zoom=0")
            // Remove edge=curl which might limit access to larger versions
            .replace("&edge=curl", "")
            .replace("edge=curl&", "")
            // Ensure HTTPS for iOS App Transport Security compliance
            .replace("http://", "https://")
    }

    /**
     * Enhances Open Library cover URLs for highest quality.
     *
     * Open Library URL pattern:
     * https://covers.openlibrary.org/b/id/{id}-{size}.jpg
     * Where size is S (small), M (medium), L (large)
     *
     * Ensures we're using the Large (L) variant for best quality.
     *
     * @param url Original Open Library cover URL
     * @return URL modified to use Large size variant
     */
    private fun enhanceOpenLibraryUrl(url: String): String {
        return when {
            url.contains("-S.jpg") -> url.replace("-S.jpg", "-L.jpg")
            url.contains("-M.jpg") -> url.replace("-M.jpg", "-L.jpg")
            else -> url // Already Large or different pattern
        }
    }
}