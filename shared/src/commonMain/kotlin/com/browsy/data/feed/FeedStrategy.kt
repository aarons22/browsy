package com.browsy.data.feed

import kotlin.random.Random

/**
 * Simplified feed strategy focused on reliable queries that return actual books.
 *
 * Previous complex queries (like "inauthor:X OR inauthor:Y" and "subject:fiction")
 * were returning library catalogs instead of actual readable books. This simplified
 * approach uses proven query patterns that return real, relevant books.
 *
 * Strategy: Simple rotation between popular authors, genres, and recent releases
 * for fresh, discoverable content that supports Browsy's bookstore browsing experience.
 */
object FeedStrategy {

    /**
     * Generates a reliable book query that actually returns good results.
     *
     * Uses simple, tested query patterns instead of complex boolean logic that
     * confuses the Google Books API and returns catalog metadata instead of books.
     *
     * @param loadCount Number of times feed has been loaded (for rotation)
     * @return Pair of (query, orderBy) that reliably returns actual books
     */
    fun getSmartQuery(loadCount: Int = 0): Pair<String, String?> {
        return when (loadCount % 6) {
            // Popular authors that reliably return books
            0 -> Pair("Brandon Sanderson", "newest")
            1 -> Pair("Stephen King", "newest")
            2 -> Pair("Neil Gaiman", "newest")

            // Popular genres with simple terms
            3 -> Pair("fantasy novel", "relevance")
            4 -> Pair("mystery thriller", "relevance")

            // Recent releases
            5 -> Pair("bestseller 2024", "newest")

            else -> Pair("fantasy", "relevance") // fallback
        }
    }
}