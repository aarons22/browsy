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
 * Fetches book details by ISBN.
 * Throws an exception on failure instead of returning Result.
 */
@Throws(Exception::class)
suspend fun BookRepository.getBookByIsbnOrThrow(isbn: String): Book? {
    return getBookByIsbn(isbn).getOrThrow()
}
