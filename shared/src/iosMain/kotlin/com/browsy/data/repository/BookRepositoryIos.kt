package com.browsy.data.repository

import com.browsy.data.model.Book

/**
 * iOS-friendly extension functions for BookRepository.
 *
 * These functions throw exceptions instead of returning Result,
 * which maps better to Swift's async/await error handling.
 */

/**
 * Searches for books matching the given query.
 * Throws an exception on failure instead of returning Result.
 */
@Throws(Exception::class)
suspend fun BookRepository.searchBooksOrThrow(query: String): List<Book> {
    return searchBooks(query).getOrThrow()
}

/**
 * Searches for books matching the given query with pagination support.
 * Throws an exception on failure instead of returning Result.
 *
 * @param query Search query string
 * @param startIndex Index of first result to return (for pagination)
 */
@Throws(Exception::class)
suspend fun BookRepository.searchBooksOrThrow(query: String, startIndex: Int): List<Book> {
    return searchBooks(query, startIndex).getOrThrow()
}

/**
 * Fetches book details by ISBN.
 * Throws an exception on failure instead of returning Result.
 */
@Throws(Exception::class)
suspend fun BookRepository.getBookByIsbnOrThrow(isbn: String): Book? {
    return getBookByIsbn(isbn).getOrThrow()
}
