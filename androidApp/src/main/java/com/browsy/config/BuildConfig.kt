package com.browsy.config

/**
 * Build configuration constants for Android app.
 *
 * This object provides access to build-time configuration values like API keys.
 */
object BuildConfig {
    /**
     * Google Books API key for authenticated requests.
     * This should be set via local.properties or environment variable.
     */
    val GOOGLE_BOOKS_API_KEY: String
        get() {
            // In production, this would be injected via BuildConfig from Gradle
            // For now, we'll read from system property or use empty string
            return System.getProperty("google.books.api.key") 
                ?: System.getenv("GOOGLE_BOOKS_API_KEY") 
                ?: ""
        }
}
