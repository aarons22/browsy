package com.browsy.data.feed

import kotlin.random.Random

/**
 * Date-focused feed strategy for maximum book discoverability.
 *
 * Uses Google Books API "newer:" operator to get recent releases across diverse genres
 * without limiting to specific authors. This approach maximizes serendipitous discovery
 * - the core value of Browsy's "bookstore browsing" experience.
 *
 * Strategy: Focus on recent books (last 1-2 years) across varied genres, letting users
 * discover new authors and unexpected gems rather than limiting to known names.
 */
object FeedStrategy {

    /**
     * Generates queries focused on recent releases for maximum discoverability.
     *
     * Uses "newer:YYYY" operator with diverse genres to surface fresh content from
     * unknown authors alongside established ones. Avoids author-specific queries
     * that limit discovery potential.
     *
     * @param loadCount Number of times feed has been loaded (for rotation)
     * @return Pair of (query, orderBy) optimized for recent, diverse discovery
     */
    fun getSmartQuery(loadCount: Int = 0): Pair<String, String?> {
        return when (loadCount % 8) {
            // Recent fiction across genres (2023+ for good variety)
            0 -> Pair("fiction newer:2025", "newest")
            1 -> Pair("fantasy newer:2025", "newest")
            2 -> Pair("mystery newer:2025", "newest")
            3 -> Pair("romance newer:2025", "newest")

            // Very recent releases (2024+ for cutting edge)
            4 -> Pair("novel newer:2024", "newest")
            5 -> Pair("bestseller newer:2024", "newest")

            // Mix relevance for established recent books
            6 -> Pair("fiction newer:2025", "relevance")
            7 -> Pair("bestseller newer:2025", "relevance")

            else -> Pair("fiction newer:2025", "newest") // fallback
        }
    }
}