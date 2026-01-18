package com.browsy.data.feed

import kotlin.random.Random

/**
 * Smart feed strategy for improving book discovery and relevance.
 *
 * Addresses the core issue where hardcoded "fantasy" queries return old, irrelevant books.
 * Implements a multi-strategy approach to balance fresh content, popular books, and discovery
 * while maintaining the calm, serendipitous browsing experience that defines Browsy.
 *
 * Strategy Mix:
 * - 40% Recent popular books (orderBy=newest with popular genres/authors)
 * - 30% High-quality classics and bestsellers (orderBy=relevance with curated queries)
 * - 30% Discovery and variety (rotating genres, hidden gems)
 *
 * This creates a feed that feels like browsing a well-curated bookstore with both
 * "new releases" and "staff picks" sections.
 */
object FeedStrategy {

    /**
     * Generates a smart query and orderBy combination for the current session.
     *
     * Uses rotation and randomization to ensure feed variety while maintaining quality.
     * The strategy balances recency, relevance, and discovery to avoid both staleness
     * and bestseller-only echo chambers.
     *
     * @param loadCount Number of times feed has been loaded (for rotation)
     * @return Pair of (query, orderBy) optimized for current load
     */
    fun getSmartQuery(loadCount: Int = 0): Pair<String, String?> {
        val strategy = when (loadCount % 10) {
            // Recent popular fiction (40% weight - loads 0,1,2,3)
            0, 1, 2, 3 -> getRecentPopularQuery()

            // High-quality classics and bestsellers (30% weight - loads 4,5,6)
            4, 5, 6 -> getHighQualityQuery()

            // Discovery and variety (30% weight - loads 7,8,9)
            7, 8, 9 -> getDiscoveryQuery()

            else -> getRecentPopularQuery() // fallback
        }

        return strategy
    }

    /**
     * Recent popular books strategy - emphasizes newer, relevant content.
     *
     * Targets books published in recent years with high engagement.
     * Uses orderBy=newest to prioritize freshness.
     */
    private fun getRecentPopularQuery(): Pair<String, String?> {
        val popularQueries = listOf(
            // Popular contemporary authors
            "inauthor:sanderson OR inauthor:martin OR inauthor:rothfuss",
            "inauthor:king OR inauthor:atwood OR inauthor:gaiman",
            "inauthor:obama OR inauthor:harris OR inauthor:colson",

            // Recent popular genres
            "subject:fiction",
            "subject:mystery",
            "subject:thriller",
            "subject:romance",
            "subject:sci-fi OR subject:fantasy",

            // Trending topics and themes
            "climate change fiction",
            "artificial intelligence fiction",
            "pandemic fiction",
        )

        val query = popularQueries[Random.nextInt(popularQueries.size)]
        return Pair(query, "newest")
    }

    /**
     * High-quality classics and bestsellers strategy.
     *
     * Focuses on well-regarded books that have stood the test of time.
     * Uses orderBy=relevance to get the most significant works.
     */
    private fun getHighQualityQuery(): Pair<String, String?> {
        val classicQueries = listOf(
            // Literary classics
            "inauthor:orwell OR inauthor:hemingway OR inauthor:steinbeck",
            "inauthor:toni morrison OR inauthor:maya angelou",
            "inauthor:tolkien OR inauthor:lewis",

            // Award winners and critical acclaim
            "pulitzer prize fiction",
            "national book award",
            "man booker prize",

            // Timeless genres with quality focus
            "subject:literary fiction",
            "subject:classic literature",
            "subject:biography memoir",

            // Well-curated collections
            "bestseller fiction",
            "new york times bestseller"
        )

        val query = classicQueries[Random.nextInt(classicQueries.size)]
        return Pair(query, "relevance")
    }

    /**
     * Discovery and variety strategy.
     *
     * Introduces serendipity and helps users discover unexpected gems.
     * Mixes different approaches to maintain the "browsing bookstore shelves" feel.
     */
    private fun getDiscoveryQuery(): Pair<String, String?> {
        val discoveryQueries = listOf(
            // Diverse voices and perspectives
            "inauthor:chimamanda OR inauthor:zadie smith OR inauthor:jhumpa lahiri",
            "inauthor:haruki murakami OR inauthor:elena ferrante",
            "inauthor:n.k. jemisin OR inauthor:becky chambers",

            // Emerging and varied genres
            "subject:graphic novels",
            "subject:poetry",
            "subject:short stories",
            "subject:historical fiction",
            "subject:magical realism",

            // Niche but quality topics
            "cooking memoirs",
            "travel writing",
            "nature writing",
            "art history",

            // International and translated works
            "translated fiction",
            "international literature"
        )

        val query = discoveryQueries[Random.nextInt(discoveryQueries.size)]
        // Mix of newest and relevance for discovery
        val orderBy = if (Random.nextBoolean()) "newest" else "relevance"
        return Pair(query, orderBy)
    }
}