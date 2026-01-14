package com.browsy

class Greeting {
    private val platform: Platform = getPlatform()

    fun greet(): String {
        return "Hello from ${platform.name}!"
    }
}
