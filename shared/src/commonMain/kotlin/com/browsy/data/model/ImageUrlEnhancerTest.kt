package com.browsy.data.model

/**
 * Manual test for ImageUrlEnhancer functionality.
 * Run this to verify URL enhancement is working correctly.
 */
fun main() {
    println("=== ImageUrlEnhancer Test ===")

    // Test Google Books URL enhancement
    val googleBooksUrls = listOf(
        "http://books.google.com/books/content?id=cj0lhuzFSloC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api",
        "http://books.google.com/books/content?id=cj0lhuzFSloC&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api"
    )

    println("\n--- Google Books URL Enhancement ---")
    googleBooksUrls.forEach { url ->
        val enhanced = ImageUrlEnhancer.enhance(url)
        println("Original:  $url")
        println("Enhanced:  $enhanced")
        println()
    }

    // Test Open Library URL enhancement
    val openLibraryUrls = listOf(
        "https://covers.openlibrary.org/b/id/14656855-S.jpg",
        "https://covers.openlibrary.org/b/id/14656855-M.jpg",
        "https://covers.openlibrary.org/b/id/14656855-L.jpg"
    )

    println("--- Open Library URL Enhancement ---")
    openLibraryUrls.forEach { url ->
        val enhanced = ImageUrlEnhancer.enhance(url)
        println("Original:  $url")
        println("Enhanced:  $enhanced")
        println()
    }

    // Test null and unknown URLs
    println("--- Edge Cases ---")
    println("null: ${ImageUrlEnhancer.enhance(null)}")
    println("unknown: ${ImageUrlEnhancer.enhance("https://example.com/image.jpg")}")
}