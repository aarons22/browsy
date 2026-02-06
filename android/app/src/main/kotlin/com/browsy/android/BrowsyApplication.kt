package com.browsy.android

import android.app.Application
import com.browsy.data.repository.BookShelfStorageInitializer

/**
 * Application class for Browsy.
 *
 * Initializes global application state and services that need to run
 * before any Activities are created.
 */
class BrowsyApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        // Initialize platform-specific storage for book shelves
        BookShelfStorageInitializer.init(applicationContext)
    }
}
