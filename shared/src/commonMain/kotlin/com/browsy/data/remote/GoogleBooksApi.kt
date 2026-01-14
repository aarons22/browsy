package com.browsy.data.remote

import com.browsy.data.remote.dto.GoogleBooksResponse
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.get
import io.ktor.client.request.parameter
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json

/**
 * Client for Google Books API v1.
 *
 * This client provides methods to search for books and fetch book details from the
 * Google Books API. All methods return Result<T> for safe error handling without exceptions.
 *
 * API Documentation: https://developers.google.com/books/docs/v1/using
 *
 * Usage:
 * ```
 * val api = GoogleBooksApi(apiKey = "your-api-key")
 * val result = api.searchBooks("kotlin programming")
 * result.onSuccess { response ->
 *     response.items?.forEach { book -> println(book.volumeInfo.title) }
 * }
 * api.close() // Clean up when done
 * ```
 *
 * @property apiKey Google Books API key for authenticated requests
 */
class GoogleBooksApi(private val apiKey: String) {

    private val client = HttpClient {
        install(ContentNegotiation) {
            json(Json {
                ignoreUnknownKeys = true
                isLenient = true
            })
        }
    }

    private val baseUrl = "https://www.googleapis.com/books/v1/volumes"

    /**
     * Searches for books matching the given query.
     *
     * Query syntax supports various operators:
     * - Simple text: "kotlin programming"
     * - Title search: "intitle:kotlin"
     * - Author search: "inauthor:martin"
     * - ISBN search: "isbn:9781234567890"
     * - Subject: "subject:fiction"
     *
     * @param query Search query string (supports Google Books query syntax)
     * @param maxResults Maximum number of results to return (1-40, default 20)
     * @return Result containing GoogleBooksResponse on success, or exception on failure
     */
    suspend fun searchBooks(
        query: String,
        maxResults: Int = 20
    ): Result<GoogleBooksResponse> {
        return try {
            val response = client.get(baseUrl) {
                parameter("q", query)
                parameter("maxResults", maxResults)
                parameter("key", apiKey)
            }.body<GoogleBooksResponse>()
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Fetches book details by ISBN.
     *
     * This is a convenience method that performs an ISBN search with maxResults=1.
     * Accepts both ISBN-10 and ISBN-13 formats.
     *
     * @param isbn Book ISBN (10 or 13 digits, with or without hyphens)
     * @return Result containing GoogleBooksResponse with at most one item, or exception on failure
     */
    suspend fun getBookByIsbn(isbn: String): Result<GoogleBooksResponse> {
        return searchBooks("isbn:$isbn", maxResults = 1)
    }

    /**
     * Closes the HTTP client and releases resources.
     *
     * Call this when you're done using the API client to clean up connection pools
     * and other resources.
     */
    fun close() {
        client.close()
    }
}
