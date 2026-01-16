package com.browsy.data.repository

import android.content.Context

/**
 * Public initializer for book shelf storage on Android.
 *
 * This object provides a public API for the Android app to initialize
 * the platform-specific storage, which is implemented internally.
 *
 * Usage in Application class:
 * ```kotlin
 * class BrowsyApplication : Application() {
 *     override fun onCreate() {
 *         super.onCreate()
 *         BookShelfStorageInitializer.init(applicationContext)
 *     }
 * }
 * ```
 */
object BookShelfStorageInitializer {
    /**
     * Initializes the book shelf storage with the application context.
     * Must be called once during app startup before any shelf operations.
     *
     * @param context Application context (not Activity context to avoid leaks)
     */
    fun init(context: Context) {
        LocalBookShelfStorage.init(context)
    }
}
