package com.browsy.data.model

import kotlinx.serialization.Serializable

/**
 * Core book model used throughout the app.
 *
 * This model represents a book entity mapped from API responses (Open Library, Google Books, etc.).
 * All fields except id and title are nullable to handle varying data completeness across APIs.
 *
 * Design decisions:
 * - Single author string for MVP (will expand to List<String> when needed)
 * - ISBN stored as nullable string (prefer ISBN-13, fallback to ISBN-10)
 * - publishedDate as string in ISO format (YYYY-MM-DD) when available
 * - subjects list for genre/vibe tagging (empty if no subjects available)
 * - coverUrl points to API-provided cover images (processed via BookCover utility)
 */
@Serializable
data class Book(
    val id: String,
    val title: String,
    val author: String,
    val coverUrl: String? = null,
    val description: String? = null,
    val publishedDate: String? = null,
    val pageCount: Int? = null,
    val isbn: String? = null,
    val subjects: List<String> = emptyList()
)
