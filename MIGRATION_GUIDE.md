# Native iOS and Android Migration Guide

This document outlines the completed migration from Kotlin Multiplatform (KMP) to native iOS and Android applications.

## Migration Summary

**Completed:**
- ✅ Shared Kotlin business logic ported to native Swift for iOS
- ✅ Shared Kotlin business logic moved to Android app module
- ✅ KMP shared module removed
- ✅ Build configuration updated to remove KMP dependencies
- ✅ Both platforms now use native implementations

## iOS Migration (Completed)

### Native Swift Implementation

All shared logic has been rewritten in Swift and organized in the following structure:

```
iosApp/iosApp/
├── Models/
│   ├── Book.swift                 - Core book model
│   ├── BookCover.swift            - Cover image utilities  
│   ├── SavedBook.swift            - Saved book model
│   └── BookShelf.swift            - Shelf type enum
├── Data/
│   ├── Remote/
│   │   ├── GoogleBooksApi.swift        - Google Books API client
│   │   ├── GoogleBooksDto.swift        - API response DTOs
│   │   ├── OpenLibraryApi.swift        - Open Library API client
│   │   └── OpenLibraryDto.swift        - API response DTOs
│   ├── Mappers/
│   │   ├── GoogleBooksMapper.swift     - Maps Google Books DTOs to models
│   │   └── OpenLibraryMapper.swift     - Maps Open Library DTOs to models
│   ├── Repository/
│   │   ├── BookRepository.swift              - Main book data repository
│   │   ├── LocalBookShelfRepository.swift    - Local shelf management
│   │   └── LocalBookShelfStorage.swift       - UserDefaults persistence
│   ├── Cache/
│   │   └── BookCache.swift                   - In-memory LRU cache
│   └── FeedStrategy.swift                    - Feed query strategy
├── BuildConfig.swift               - Configuration management
├── Configuration.plist             - API keys configuration
├── FeedViewModel.swift            - Updated to use Swift repository
├── ShelfViewModel.swift           - Updated to use Swift repository
└── ...
```

### Next Steps for iOS (Requires macOS + Xcode)

**The Xcode project needs to be recreated for iOS 26+ without KMP dependencies:**

1. **On macOS with Xcode 15+:**
   ```bash
   cd iosApp
   # Backup the old project
   mv iosApp.xcodeproj iosApp.xcodeproj.kmp-backup
   ```

2. **Create new iOS project in Xcode:**
   - Open Xcode
   - File → New → Project
   - Choose "iOS" → "App"
   - Product Name: "iosApp"
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment: iOS 26.0
   - Save in: `iosApp/` directory

3. **Add all Swift files to project:**
   - In Xcode, right-click on iosApp folder
   - Add Files to "iosApp"...
   - Select all .swift files from iosApp/iosApp/
   - Ensure "Copy items if needed" is UNCHECKED (files already in place)
   - Ensure "Create groups" is selected
   - Add to target: iosApp

4. **Add Configuration.plist:**
   - Add Configuration.plist to project
   - In Build Settings, add to "Preprocessed Info.plist Files"

5. **Configure API Key:**
   - Create or update `local.properties` in project root:
     ```
     google.books.api.key=YOUR_API_KEY_HERE
     ```
   - Or set environment variable: `GOOGLE_BOOKS_API_KEY`

6. **Build and Test:**
   - Build the project (⌘B)
   - Run on simulator or device
   - Verify book feed loads and shelf management works

## Android Migration (Completed)

### Native Kotlin Implementation

The shared Kotlin code has been moved directly into the Android app module:

```
androidApp/src/main/java/com/browsy/
├── android/              - Android app components
│   ├── MainActivity.kt
│   ├── BrowsyApplication.kt
│   └── ui/               - Compose UI screens and ViewModels
├── config/
│   └── BuildConfig.kt    - Configuration management
└── data/                 - All data layer code (from shared module)
    ├── model/
    ├── remote/
    ├── repository/
    ├── cache/
    ├── feed/
    └── mapper/
```

### Changes Made:

1. **Removed KMP-specific code:**
   - Removed `expect`/`actual` declarations
   - Converted to standard Kotlin
   - `LocalBookShelfStorage` now uses SharedPreferences directly
   - `currentTimeMillis()` uses `System.currentTimeMillis()` directly

2. **Updated build configuration:**
   - Removed dependency on `:shared` module
   - Added Ktor dependencies directly to androidApp
   - Added Kotlin serialization plugin
   - Removed KMP plugins

3. **Build Configuration:**
   - Edit `androidApp/build.gradle.kts` if needed
   - API key management via `BuildConfig.kt` reads from:
     - System property: `google.books.api.key`
     - Environment variable: `GOOGLE_BOOKS_API_KEY`

### Testing Android Build:

```bash
# Build the Android app
./gradlew :androidApp:assembleDebug

# Run on device/emulator  
./gradlew :androidApp:installDebug

# Run tests
./gradlew :androidApp:test
```

## Configuration

### API Keys

Both platforms now require the Google Books API key:

**iOS:**
- Set in `iosApp/iosApp/Configuration.plist`
- Or via environment variable `GOOGLE_BOOKS_API_KEY`

**Android:**
- Create `local.properties`:
  ```properties
  google.books.api.key=YOUR_KEY_HERE
  ```
- Or set environment variable `GOOGLE_BOOKS_API_KEY`

## What Was Removed

- ✅ `shared/` module directory (deleted)
- ✅ KMP plugin references in `build.gradle.kts`
- ✅ `androidLibrary` plugin  
- ✅ `kotlinMultiplatform` plugin
- ✅ `buildkonfig` plugin
- ✅ Shared module from `settings.gradle.kts`
- ✅ KMP framework dependencies from iOS

## Benefits of Native Architecture

1. **No KMP Complexity:** Standard iOS and Android development
2. **iOS 26+ Support:** Can use latest iOS features without KMP limitations
3. **Better IDE Support:** Full native tooling without KMP quirks
4. **Easier Debugging:** Native stack traces and debugging tools
5. **Simpler Build:** No cross-platform framework coordination

## Verification Checklist

- [ ] iOS project builds successfully in Xcode (requires macOS)
- [ ] Android project builds: `./gradlew :androidApp:assembleDebug`
- [ ] Book feed loads on both platforms
- [ ] Shelf management (TBR, Read, Recommend) works
- [ ] No references to `shared` module in codebase
- [ ] No KMP plugins in build files

## Troubleshooting

### iOS Build Issues
- Ensure Xcode 15+ is installed
- Verify iOS SDK 26+ is available
- Check Configuration.plist is included in build
- Verify API key is set

### Android Build Issues  
- Run `./gradlew clean`
- Ensure API key is in local.properties or environment
- Check Kotlin version compatibility (2.0.0)

## Next Development

With native apps, you can now:
- Use Swift 6.0 features on iOS
- Use latest Android APIs without KMP compatibility concerns
- Leverage platform-specific libraries more easily
- Optimize for each platform independently
