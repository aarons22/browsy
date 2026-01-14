package com.browsy.data.remote

import com.browsy.data.remote.dto.OpenLibraryBookData
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.decodeFromJsonElement

/**
 * API client for Open Library Books API (https://openlibrary.org/dev/docs/api/books)
 *
 * Open Library provides free access to book metadata and cover images:
 * - No API key required
 * - Books API: https://openlibrary.org/api/books?bibkeys=ISBN:xyz&format=json&jscmd=data
 * - Covers API: https://covers.openlibrary.org/b/isbn/xyz-L.jpg
 *
 * Use cases:
 * - Fallback when Google Books has no results
 * - Backup for missing cover images
 * - ISBN-based book lookup
 *
 * Response handling:
 * - API returns dynamic keys based on bibkey (e.g., "ISBN:0451526538")
 * - We parse JsonObject and extract the book data using the known bibkey
 * - Returns null if book not found (empty response)
 *
 * Example usage:
 * ```
 * val api = OpenLibraryApi()
 * val result = api.getBookByIsbn("0451526538")
 * result.onSuccess { bookData ->
 *     if (bookData != null) {
 *         println("Found: ${bookData.title}")
 *     } else {
 *         println("Book not found")
 *     }
 * }
 * api.close()
 * ```
 */
class OpenLibraryApi {
    private val client = HttpClient {
        install(ContentNegotiation) {
            json(Json {
                ignoreUnknownKeys = true
                isLenient = true
            })
        }
    }

    private val booksUrl = "https://openlibrary.org/api/books"
    private val coversUrl = "https://covers.openlibrary.org/b"

    /**
     * Fetches book metadata by ISBN from Open Library.
     *
     * @param isbn ISBN-10 or ISBN-13 (hyphens optional)
     * @return Result with OpenLibraryBookData if found, null if not found, or failure on error
     */
    suspend fun getBookByIsbn(isbn: String): Result<OpenLibraryBookData?> {
        return try {
            val bibkey = "ISBN:$isbn"
            val response = client.get(booksUrl) {
                parameter("bibkeys", bibkey)
                parameter("format", "json")
                parameter("jscmd", "data")
            }.body<JsonObject>()

            // Extract book data from dynamic key
            // Response format: { "ISBN:xyz": { book data } }
            // Returns empty object {} if book not found
            val bookData = response[bibkey]?.let { element ->
                Json.decodeFromJsonElement<OpenLibraryBookData>(element)
            }

            Result.success(bookData)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Constructs Open Library cover image URL for given ISBN.
     *
     * @param isbn ISBN-10 or ISBN-13 (hyphens optional)
     * @param size Cover size: "S" (small ~100px), "M" (medium ~200px), "L" (large ~500px)
     * @return Cover image URL (may 404 if cover not available)
     *
     * Note: This URL may return 404 if no cover exists. Client should handle fallback.
     */
    fun getCoverUrl(isbn: String, size: String = "L"): String {
        // size: S (small), M (medium), L (large)
        return "$coversUrl/isbn/$isbn-$size.jpg"
    }

    /**
     * Closes the HTTP client. Call this when done with the API.
     */
    fun close() {
        client.close()
    }
}
