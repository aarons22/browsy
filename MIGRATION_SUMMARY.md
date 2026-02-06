# KMP to Native Migration - Implementation Summary

## What Has Been Done

### 1. Initial Planning & Structure Created
- Comprehensive migration plan documented in `.planning/KMP_TO_NATIVE_MIGRATION_PLAN.md`
- Swift package structure created at `iosApp/BrowsyShared/`
- Package.swift configured for iOS 18+ with proper targets

### 2. Swift Data Models Created
The following Swift models have been created in `iosApp/BrowsyShared/Sources/BrowsyShared/Models/`:
- `Book.swift` - Core book model with Codable support
- `BookShelf.swift` - Enum for TBR/RECOMMEND/READ shelves
- `SavedBook.swift` - Model for saved books with shelf association
- `BookCover.swift` - Utility for managing cover URLs at different sizes

## What Needs to Be Done

### Immediate Next Steps (Phase 1)

#### 1. Complete Swift Shared Logic Implementation

All the detailed Swift implementations are documented in the migration plan. You need to create these files:

**API Layer** (`Sources/BrowsyShared/API/`):
- `DTOs/GoogleBooksDTO.swift` - All Google Books API response models
- `DTOs/OpenLibraryDTO.swift` - All Open Library API response models
- `GoogleBooksAPI.swift` - Native URLSession-based API client
- `OpenLibraryAPI.swift` - Native URLSession-based API client
- `Mappers/GoogleBooksMapper.swift` - Convert DTOs to Book model
- `Mappers/OpenLibraryMapper.swift` - Convert DTOs to Book model

**Utilities** (`Sources/BrowsyShared/Utilities/`):
- `ImageUrlEnhancer.swift` - Enhance cover image URLs for quality

**Cache** (`Sources/BrowsyShared/Cache/`):
- `BookCache.swift` - Actor-based in-memory cache with TTL

**Repository** (`Sources/BrowsyShared/Repository/`):
- `BookRepository.swift` - Main repository with dual-API fallback
- `LocalBookShelfStorage.swift` - UserDefaults-based storage
- `LocalBookShelfRepository.swift` - Business logic for shelf operations

**Feed** (`Sources/BrowsyShared/Feed/`):
- `FeedStrategy.swift` - Smart query rotation for feed variety

#### 2. Create New iOS Project

1. Open Xcode and create a new project:
   - Template: iOS App
   - Interface: SwiftUI
   - Language: Swift
   - Minimum deployment: iOS 18.0
   - Location: `iosApp/Browsy/`

2. Add the BrowsyShared package as a local dependency

3. Migrate existing SwiftUI views from `iosApp/iosApp/`:
   - Copy `BookFeedView.swift`, `BookInfoSheet.swift`, `ContentView.swift`
   - Remove `import shared` and replace with `import BrowsyShared`
   - Update ViewModels to use native Swift async/await APIs

4. Configure API key in xcconfig file:
   ```
   # Development.xcconfig
   GOOGLE_BOOKS_API_KEY = your_api_key_here
   ```

### Phase 2: Android Migration

1. **Create androidShared module**:
   ```
   mkdir -p androidShared/src/main/kotlin/com/browsy/shared
   ```

2. **Copy Kotlin code from KMP shared module**:
   - Copy all files from `shared/src/commonMain/kotlin/` to `androidShared/src/main/kotlin/`
   - Replace Ktor client configuration with OkHttp
   - Update storage to use Android SharedPreferences

3. **Update androidApp**:
   - Change dependency from `implementation(project(":shared"))` to `implementation(project(":androidShared"))`
   - No changes needed to ViewModels or UI code

4. **Update settings.gradle.kts**:
   - Add `include(":androidShared")`
   - Remove `include(":shared")`

### Phase 3: Cleanup

1. **Remove KMP infrastructure**:
   ```bash
   rm -rf shared/
   rm -rf iosApp/iosApp.xcodeproj/  # Old KMP Xcode project
   ```

2. **Update root Gradle files**:
   - Remove KMP plugins from `build.gradle.kts`
   - Remove KMP dependencies from `gradle/libs.versions.toml`

3. **Update documentation**:
   - Replace PROJECT_STRUCTURE.md content with native architecture
   - Update README.md with new build instructions
   - Update CLAUDE.md to remove KMP-specific guidance

## Key Implementation Tips

### For Swift Implementation

1. **Use modern Swift concurrency**:
   - Use `actor` for thread-safe repositories and caches
   - Use `async/await` for all API calls
   - Use `@MainActor` for ViewModels

2. **Error Handling**:
   - Use native Swift `throws` instead of Kotlin's `Result<T>`
   - Catch errors in ViewModels and expose as `@Published` properties

3. **Testing**:
   - Use XCTest for unit tests
   - Mock API clients with protocols
   - Test each layer independently

### For Android Migration

1. **Preserve Kotlin code structure**:
   - Keep the same file organization
   - Most code can be copy-pasted from shared/commonMain
   - Only platform-specific code needs updates

2. **Dependencies**:
   - Continue using Ktor for networking (but with OkHttp engine)
   - Continue using kotlinx.serialization
   - Add coroutines-android for lifecycle awareness

3. **Storage**:
   - Replace expect/actual pattern with direct SharedPreferences usage
   - Add Context parameter to storage classes

## Testing Strategy

### iOS Testing
1. Build Swift package: `swift build`
2. Run package tests: `swift test`
3. Build iOS app in Xcode
4. Test on iOS simulator
5. Verify all features work

### Android Testing
1. Build androidShared: `./gradlew :androidShared:build`
2. Build app: `./gradlew :androidApp:assembleDebug`
3. Install on emulator: `./gradlew :androidApp:installDebug`
4. Verify all features work

### Feature Parity Checklist
- [ ] Book search works
- [ ] Infinite scroll pagination works
- [ ] ISBN lookup works
- [ ] Cover images display correctly
- [ ] Feed strategy rotates queries
- [ ] Books can be saved to shelves
- [ ] Saved books persist across app restarts
- [ ] Book info displays correctly

## Estimated Effort

- **Swift shared logic**: 2-3 days
- **New iOS project & migration**: 2 days
- **Android migration**: 1-2 days
- **Cleanup & testing**: 1-2 days

**Total**: 6-9 days of focused development

## Important Notes

1. **API Key Management**: Both platforms need secure API key storage
   - iOS: Use xcconfig files (not committed to git)
   - Android: Use local.properties or BuildConfig

2. **Migration Path**: Can be done incrementally
   - Complete iOS migration first
   - Test thoroughly
   - Then migrate Android
   - This reduces risk

3. **Data Migration**: If users have existing data
   - iOS: May need to export from KMP UserDefaults and import to new format
   - Android: SharedPreferences key names should stay the same

4. **Rollback**: Keep KMP code on a branch until both migrations are confirmed working

## Reference

- Full detailed implementation: `.planning/KMP_TO_NATIVE_MIGRATION_PLAN.md`
- Current KMP shared code: `shared/src/commonMain/kotlin/`
- iOS KMP ViewModels: `iosApp/iosApp/FeedViewModel.swift`, `ShelfViewModel.swift`
- Android KMP ViewModels: `androidApp/src/main/java/com/browsy/android/ui/`
