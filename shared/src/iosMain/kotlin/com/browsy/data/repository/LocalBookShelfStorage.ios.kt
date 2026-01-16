package com.browsy.data.repository

import platform.Foundation.NSUserDefaults

/**
 * iOS implementation of LocalBookShelfStorage using NSUserDefaults.
 *
 * This implementation uses the standard user defaults, which is suitable for
 * small amounts of data like saved book shelves. For larger datasets,
 * consider migrating to Core Data or SQLite.
 */
internal actual class LocalBookShelfStorage actual constructor() {
    private val defaults = NSUserDefaults.standardUserDefaults

    actual fun save(data: String) {
        defaults.setObject(data, KEY)
    }

    actual fun load(): String? {
        return defaults.stringForKey(KEY)
    }

    private companion object {
        private const val KEY = "book_shelves"
    }
}
