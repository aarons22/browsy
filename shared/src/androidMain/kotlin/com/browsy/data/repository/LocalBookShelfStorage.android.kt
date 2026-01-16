package com.browsy.data.repository

import android.content.Context
import android.content.SharedPreferences

/**
 * Android implementation of LocalBookShelfStorage using SharedPreferences.
 *
 * This implementation uses a singleton pattern with lazy initialization.
 * The Android app must call [init] with the application context during startup
 * before any shelf operations are performed.
 *
 * Usage in Application class:
 * ```kotlin
 * class BrowsyApplication : Application() {
 *     override fun onCreate() {
 *         super.onCreate()
 *         LocalBookShelfStorage.init(applicationContext)
 *     }
 * }
 * ```
 */
internal actual class LocalBookShelfStorage actual constructor() {

    actual fun save(data: String) {
        prefs.edit().putString(KEY, data).apply()
    }

    actual fun load(): String? {
        return prefs.getString(KEY, null)
    }

    companion object {
        private const val KEY = "book_shelves"
        private const val PREFS_NAME = "browsy"

        private lateinit var prefs: SharedPreferences

        /**
         * Initializes the storage with the application context.
         * Must be called once during app startup before any shelf operations.
         *
         * @param context Application context (not Activity context to avoid leaks)
         */
        fun init(context: Context) {
            prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        }
    }
}
