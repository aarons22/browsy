package com.browsy.data.remote

import com.browsy.data.remote.dto.GoogleBooksResponse
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.HttpTimeout
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

        install(HttpTimeout) {
            requestTimeoutMillis = 30000
            connectTimeoutMillis = 10000
            socketTimeoutMillis = 30000
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
     * @param startIndex Index of first result to return (for pagination, default 0)
     * @param orderBy Sort order: "newest" or "relevance" (default null uses API default)
     * @return Result containing GoogleBooksResponse on success, or exception on failure
     */
    suspend fun searchBooks(
        query: String,
        maxResults: Int = 20,
        startIndex: Int = 0,
        orderBy: String? = null
    ): Result<GoogleBooksResponse> {
        return try {
            println("GoogleBooksApi: Searching for '$query' (maxResults=$maxResults, startIndex=$startIndex)")
            println("GoogleBooksApi: Making request to $baseUrl")

            val httpResponse = client.get(baseUrl) {
                parameter("q", query)
                parameter("maxResults", maxResults)
                parameter("startIndex", startIndex)
                if (orderBy != null) {
                    parameter("orderBy", orderBy)
                }
                parameter("key", apiKey)
            }

            println("GoogleBooksApi: Response status: ${httpResponse.status}")

            if (httpResponse.status.value !in 200..299) {
                val errorBody = httpResponse.body<String>()
                val message = "Google Books API error ${httpResponse.status.value}: $errorBody"
                println("GoogleBooksApi: $message")
                return Result.failure(Exception(message))
            }

            val response = httpResponse.body<GoogleBooksResponse>()
            println("GoogleBooksApi: Successfully loaded ${response.totalItems} total items, ${response.items?.size ?: 0} items returned")
            Result.success(response)
        } catch (e: Exception) {
            val detailedMessage = when {
                e.message?.contains("Unable to resolve host") == true ->
                    "DNS resolution failed for googleapis.com. Check internet connection and DNS settings."
                e.message?.contains("timeout") == true ->
                    "Request timed out. Check network connection."
                e.message?.contains("No address associated with hostname") == true ->
                    "Cannot resolve www.googleapis.com. Check network configuration."
                else -> "Network error: ${e.message}"
            }
            println("GoogleBooksApi: Exception during search - $detailedMessage")
            println("GoogleBooksApi: Original exception: ${e::class.simpleName}: ${e.message}")
            Result.failure(Exception(detailedMessage, e))
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
