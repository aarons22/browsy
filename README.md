# Browsy

A mobile book discovery app built with Kotlin Multiplatform. Browse books with a TikTok-style swipe interface - full-screen covers, smooth vertical paging, and infinite scroll.

## Tech Stack

- **Kotlin Multiplatform (KMP)** - Shared business logic across platforms
- **SwiftUI** - Native iOS UI
- **Jetpack Compose** - Native Android UI
- **Ktor** - HTTP client for API requests
- **Google Books API** - Book metadata and cover images
- **BuildKonfig** - Build-time configuration management

## Setup

### Prerequisites

- **Android:** Android Studio with Android SDK 34
- **iOS:** Xcode 15+ with iOS 16.0+ target
- **Gradle:** 8.5 or higher
- **Kotlin:** 2.0.0

### 1. Clone the Repository

```bash
git clone <repository-url>
cd browsy
```

### 2. Configure API Keys

Copy the example configuration:

```bash
cp local.properties.example local.properties
```

Edit `local.properties` and add your Google Books API key:

```properties
google.books.api.key=YOUR_ACTUAL_API_KEY
```

**Getting a Google Books API key:**

1. Visit https://console.cloud.google.com/
2. Create a new project or select existing
3. Enable "Books API" for your project
4. Create API key in Credentials section
5. Copy key to `local.properties`

**Free tier:** 1,000 requests/day (sufficient for development)

### 3. Android Setup

Configure your Android SDK location in `local.properties`:

```properties
sdk.dir=/path/to/your/android-sdk
```

Build and run:

```bash
./gradlew :androidApp:assembleDebug
# Or open in Android Studio and run
```

### 4. iOS Setup

Build the shared framework first:

```bash
./gradlew embedAndSignAppleFrameworkForXcode
```

Then open `iosApp/iosApp.xcodeproj` in Xcode and run the app.

## Project Structure

```
browsy/
├── shared/                    # Kotlin Multiplatform shared code
│   ├── src/
│   │   ├── commonMain/       # Platform-agnostic code
│   │   ├── androidMain/      # Android-specific implementations
│   │   └── iosMain/          # iOS-specific implementations
│   └── build.gradle.kts
├── androidApp/               # Android app (Jetpack Compose)
│   └── src/main/
│       └── java/com/browsy/android/
├── iosApp/                   # iOS app (SwiftUI)
│   └── iosApp/
└── gradle/                   # Gradle configuration
    └── libs.versions.toml    # Version catalog
```

## Features

### Current (Phase 3)

- ✅ Full-screen book cover display
- ✅ TikTok-style vertical swipe navigation
- ✅ Infinite scroll with pagination
- ✅ High-quality cover image loading
- ✅ Smooth snap-to-position behavior
- ✅ Book title and author overlay

### Upcoming

- **Phase 4:** Book info panel, TBR/Recommend/Read/Buy actions
- **Phase 5:** Backend infrastructure (GCP, Cloud Run, Firestore)
- **Phase 6:** Authentication (Google, Apple, Email)
- **Phase 7:** User profile and shelves
- **Phase 8:** Feed personalization

## Development

### Build Commands

```bash
# Build shared module
./gradlew :shared:build

# Build Android app
./gradlew :androidApp:assembleDebug

# Build iOS framework
./gradlew embedAndSignAppleFrameworkForXcode

# Clean all builds
./gradlew clean
```

### Configuration

The project uses BuildKonfig for compile-time configuration. Secrets are loaded from `local.properties` (development) or environment variables (CI/CD).

Add new config values in `shared/build.gradle.kts`:

```kotlin
buildkonfig {
    defaultConfigs {
        buildConfigField(STRING, "NEW_CONFIG_KEY", "value")
    }
}
```

Access in shared code:

```kotlin
import com.browsy.config.BuildKonfig
val apiKey = BuildKonfig.GOOGLE_BOOKS_API_KEY
```

## Testing

**Note:** Manual device testing is currently deferred due to lack of device access. Build verification confirms code generation and compilation work correctly.

## Architecture

### Data Layer

- **BookRepository** - Main data access interface
- **GoogleBooksApi** - Primary book data source
- **OpenLibraryApi** - Fallback data source
- **BookCache** - LRU cache with 30-minute TTL

### UI Layer

- **Android:** Compose VerticalPager with Coil image loading
- **iOS:** TabView with AsyncImage loading
- **ViewModels:** Platform-specific, manage state and pagination

## Contributing

This is a personal project. The roadmap is defined in `.planning/ROADMAP.md`.

## License

TBD
