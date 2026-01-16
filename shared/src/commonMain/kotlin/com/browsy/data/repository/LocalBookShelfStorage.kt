package com.browsy.data.repository

/**
 * Platform-specific storage for book shelf data.
 *
 * This expect class defines the contract for persistent storage of saved books.
 * Platform implementations use appropriate storage mechanisms:
 * - Android: SharedPreferences
 * - iOS: NSUserDefaults
 */
internal expect class LocalBookShelfStorage() {
    /**
     * Saves the JSON string representation of saved books.
     * @param data JSON string containing list of SavedBook objects
     */
    fun save(data: String)

    /**
     * Loads the previously saved JSON string.
     * @return JSON string if data exists, null otherwise
     */
    fun load(): String?
}
