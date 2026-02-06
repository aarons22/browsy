# Browsy - Project Structure

## Overview

Native iOS and Android applications with separate implementations of business logic on each platform.

## Architecture

Browsy uses a **native-first architecture** where iOS and Android apps maintain their own implementations of business logic:
- **iOS**: Pure Swift implementation
- **Android**: Pure Kotlin implementation
- **No shared code**: Each platform optimized independently

## Modules

### :androidApp
**Purpose:** Android application with native Kotlin business logic and Jetpack Compose UI

**Type:** Android Application
**Language:** Kotlin
**UI Framework:** Jetpack Compose with Material 3

**Structure:**
```
androidApp/src/main/java/com/browsy/
├── android/              - Android app components
│   ├── MainActivity.kt
│   ├── BrowsyApplication.kt
│   └── ui/               - Compose UI screens and ViewModels
├── config/               - Build configuration
└── data/                 - Business logic (models, repositories, APIs)
```

**Build output:**
- Debug APK: `androidApp/build/outputs/apk/debug/androidApp-debug.apk`
- Release APK: `androidApp/build/outputs/apk/release/androidApp-release.apk`

### iOS App
**Purpose:** iOS application with native Swift business logic and SwiftUI UI

**Type:** Native iOS Application
**Language:** Swift
**UI Framework:** SwiftUI
**Minimum iOS Version:** 26.0

**Structure:**
```
iosApp/iosApp/
├── Models/               - Data models
├── Data/                 - Business logic
│   ├── Remote/          - API clients
│   ├── Repository/      - Data repositories
│   ├── Cache/           - Caching layer
│   └── Mappers/         - DTO mappers
├── Views/               - SwiftUI views
└── ViewModels/          - View state management
```

## Version Information

| Component | Version |
|-----------|---------|
| Kotlin | 2.0.0 |
| Gradle | 8.5 |
| Android Gradle Plugin | 8.2.2 |
| Compose BOM | 2024.06.00 |
| iOS Deployment Target | 26.0 |
| Min Android SDK | 24 |
| Target Android SDK | 34 |
| Swift | 6.0 |
| Xcode | 15+ |

## Common Gradle Tasks

### Android App

```bash
# Build debug APK
./gradlew :androidApp:assembleDebug

# Build release APK
./gradlew :androidApp:assembleRelease

# Install debug APK on connected device/emulator
./gradlew :androidApp:installDebug

# Run Android unit tests
./gradlew :androidApp:test

# Run Android lint checks
./gradlew :androidApp:lint

# Clean build
./gradlew clean
```

### iOS App

```bash
# Open in Xcode (macOS only)
open iosApp/iosApp.xcodeproj

# Build from command line (macOS only)
xcodebuild -project iosApp/iosApp.xcodeproj -scheme iosApp -configuration Debug

# Run tests
xcodebuild test -project iosApp/iosApp.xcodeproj -scheme iosApp
```

## Project Architecture

```
browsy/
├── androidApp/          # Android app with native Kotlin
│   ├── src/
│   │   └── main/
│   │       ├── AndroidManifest.xml
│   │       └── java/com/browsy/
│   │           ├── android/      # UI layer
│   │           ├── config/       # Configuration
│   │           └── data/         # Business logic
│   └── build.gradle.kts
│
├── iosApp/              # iOS app with native Swift
│   ├── iosApp.xcodeproj/
│   └── iosApp/
│       ├── iOSApp.swift
│       ├── Models/
│       ├── Data/
│       └── Views/
│
├── gradle/
│   └── libs.versions.toml   # Version catalog
├── build.gradle.kts         # Root build configuration
├── settings.gradle.kts      # Project structure
└── gradle.properties        # Build settings
```

## Key Configuration Files

### `gradle/libs.versions.toml`
Centralized dependency version management for Android.

### `gradle.properties`
Build configuration and performance tuning:
- JVM memory settings
- Gradle build caching

### `local.properties`
Local environment configuration (not committed to git):
- `sdk.dir` - Android SDK location
- `google.books.api.key` - Google Books API key

## Development Notes

### iOS Development
- Requires macOS with Xcode 15+
- Uses Swift 6.0 language features
- SwiftUI for declarative UI
- URLSession for networking
- UserDefaults for local storage

### Android Development  
- Uses Kotlin coroutines for async operations
- Jetpack Compose for declarative UI
- Ktor for networking
- SharedPreferences for local storage
- Material 3 design system

## Build System Requirements

**For Android development:**
- JDK 17+
- Android SDK with API 34 installed
- Gradle 8.5 (included via wrapper)

**For iOS development (macOS only):**
- macOS 14+
- Xcode 15+
- iOS 26.0+ SDK
- Command Line Tools for Xcode

## API Keys

Both apps require a Google Books API key:

**Android:** Set in `local.properties`:
```properties
google.books.api.key=YOUR_KEY_HERE
```

**iOS:** Set in `Configuration.plist` or as environment variable `GOOGLE_BOOKS_API_KEY`

## Troubleshooting

**"SDK location not found" (Android)**
- Create `local.properties` in project root
- Add line: `sdk.dir=/path/to/android/sdk`

**iOS build requires macOS**
- iOS development requires macOS with Xcode
- Cannot build iOS apps on Linux/Windows

**Gradle daemon memory issues**
- Adjust `org.gradle.jvmargs` in `gradle.properties`
- Current setting: `-Xmx2048M`
