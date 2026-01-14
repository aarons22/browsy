package com.browsy.data.cache

/**
 * Android implementation of currentTimeMillis using System.currentTimeMillis().
 */
internal actual fun currentTimeMillis(): Long = System.currentTimeMillis()
