package com.browsy.data.feed

/**
 * Test utility to demonstrate FeedStrategy query variety and rotation.
 * Run this to see the different query strategies in action.
 */
fun main() {
    println("=== FeedStrategy Test - Query Rotation ===")
    println()

    // Test 10 consecutive loads to see the strategy rotation
    for (loadCount in 0..9) {
        val (query, orderBy) = FeedStrategy.getSmartQuery(loadCount)
        val strategy = when (loadCount % 10) {
            in 0..3 -> "Recent Popular"
            in 4..6 -> "High Quality"
            in 7..9 -> "Discovery"
            else -> "Unknown"
        }

        println("Load $loadCount ($strategy): '$query' (orderBy: $orderBy)")
    }

    println()
    println("Strategy Distribution:")
    println("- Recent Popular: 40% (loads 0,1,2,3)")
    println("- High Quality: 30% (loads 4,5,6)")
    println("- Discovery: 30% (loads 7,8,9)")
    println()
    println("Each strategy uses randomized queries within its category for variety.")
}