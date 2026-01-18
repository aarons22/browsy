package com.browsy.data.feed

import kotlin.random.Random

/**
 * Reliable feed strategy focused on genre variety and quality results.
 *
 * After testing, Google Books API date operators ("newer:") and orderBy=newest
 * are unreliable - they often return old books or library catalogs. This approach
 * uses simple genre terms with relevance ordering to get quality, varied books
 * that users actually want to read.
 *
 * Strategy: Simple genre rotation with relevance-based ordering for consistent,
 * quality results that support discoverable browsing.
 */
object FeedStrategy {

    /**
     * Generates reliable queries focused on genre variety and quality.
     *
     * Uses simple genre terms with orderBy=relevance, which is more reliable than
     * orderBy=newest for returning actual readable books instead of catalog metadata.
     *
     * @param loadCount Number of times feed has been loaded (for rotation)
     * @return Pair of (query, orderBy) optimized for reliable, quality results
     */
    fun getSmartQuery(loadCount: Int = 0): Pair<String, String?> {
        return when (loadCount % 4) {
            // Simple, proven queries that work reliably
            0 -> Pair("fantasy", null)  // Original working query
            1 -> Pair("fiction", null)
            2 -> Pair("mystery", null)
            3 -> Pair("romance", null)

            else -> Pair("fantasy", null) // fallback to original
        }
    }
}