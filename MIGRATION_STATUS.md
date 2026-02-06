# Migration from Kotlin Multiplatform to Native iOS and Android

## What I've Accomplished

### 1. Created Comprehensive Migration Plan

I've created a detailed, step-by-step migration plan in **`.planning/KMP_TO_NATIVE_MIGRATION_PLAN.md`** that includes:

- Complete code examples for every Swift file you'll need
- Detailed instructions for creating the new iOS project (iOS 26+)
- Android migration strategy with new project approach
- Testing checklists for both platforms
- Timeline estimates (6-9 days of focused work)
- Risk mitigation strategies
- Success criteria

### 2. Updated Plan Based on Feedback

**iOS 26.0 target**: Updated all references from iOS 18 to iOS 26
**No separate Swift package**: Removed Swift Package Manager approach - all shared logic integrated directly into iOS app target
**New Android project**: Updated to use clean slate approach (Option A) with all code in single app module

### 3. Documentation Structure

Created three key documents:
- **`.planning/KMP_TO_NATIVE_MIGRATION_PLAN.md`**: Comprehensive technical plan
- **`MIGRATION_SUMMARY.md`**: Quick reference guide
- **`MIGRATION_STATUS.md`**: This status document

## What You Need to Do Next

### Phase 1: Create New iOS Project (iOS 26+)

1. **Create Xcode project**:
   - Template: iOS App, SwiftUI, Swift
   - Minimum deployment: iOS 26.0
   - Location: `iosApp/Browsy/`

2. **Create directory structure** within the project:
   ```
   Browsy/
   ├── Models/
   ├── API/DTOs/, API/Mappers/, API files
   ├── Cache/
   ├── Repository/
   ├── Feed/
   ├── Utilities/
   ├── Views/
   └── ViewModels/
   ```

3. **Implement Swift code** using examples from migration plan:
   - All shared logic in same target as app code
   - No imports needed between components
   - Uses native Swift async/await

### Phase 2: Create New Android Project

1. **Create new project in Android Studio**:
   - Template: Empty Activity (Compose)
   - Create outside existing repo initially
   - Minimum SDK: 24

2. **Copy code**:
   - Kotlin shared logic from `shared/src/commonMain/`
   - UI code from `androidApp/src/main/`
   - All in single app module, organized by package

3. **Update imports** from `com.browsy.` to `com.browsy.android.`

### Phase 3: Remove KMP Infrastructure

Once both new projects are working:
- Delete `shared/` module
- Delete old `androidApp/`
- Delete old `iosApp/iosApp.xcodeproj/`
- Update documentation

## Key Decisions Made

✅ **iOS target**: iOS 26.0 minimum
✅ **iOS architecture**: Direct integration (no Swift package)
✅ **Android approach**: New project (clean slate)
✅ **Android architecture**: Single app module (no shared module)

## Questions & Decisions Needed

### 1. Repository Structure

**Question**: How do you want to organize the two separate native projects?

**Options**:
- **A**: Keep both in same repo with structure like:
  ```
  browsy/
  ├── ios/Browsy/           # iOS project
  ├── android/              # Android project
  └── docs/                 # Shared documentation
  ```
- **B**: Create two separate repositories:
  - `browsy-ios` - iOS app
  - `browsy-android` - Android app
- **C**: Keep in existing repo structure:
  ```
  browsy/
  ├── iosApp/Browsy/        # New iOS project here
  ├── browsy-android/       # Android project here
  └── .planning/            # Keep existing docs
  ```

**Recommendation**: Option C keeps things simple and preserves existing documentation.

### 2. API Key Management

**Question**: How should API keys be managed for both platforms?

**Current approach**:
- iOS: xcconfig files (gitignored)
- Android: local.properties (gitignored)

**Should we**:
- Keep separate config files? ✅ (Recommended - platform-standard approach)
- Move to environment variables?
- Use a shared secrets management service?

### 3. Shared Documentation

**Question**: Should we have shared documentation between projects?

**Options**:
- Keep design docs, wireframes, and API docs in shared location
- Duplicate relevant docs in each project
- Create a separate docs repo

**Recommendation**: Keep `.planning/`, `wireframe_sketches/`, and high-level docs in a shared location in the repo.

### 4. Backend Integration

**Question**: The `backend/` directory in the current repo - should it stay?

**Options**:
- Keep backend in same repo structure
- Move backend to separate repository
- Document backend separately but keep in same repo for now

**Recommendation**: Keep in same repo for now, can split later if needed.

### 5. Version Synchronization

**Question**: How should we keep version numbers in sync between platforms?

**Options**:
- Manual coordination
- Shared version file that both projects reference
- Independent versioning (iOS and Android can have different versions)

**Recommendation**: Start with independent versioning, coordinate major releases manually.

### 6. Testing Strategy

**Question**: Should we aim for feature parity before removing KMP, or migrate one platform at a time?

**Options**:
- **A**: Complete iOS first, test thoroughly, then do Android
- **B**: Do both in parallel, remove KMP when both are ready
- **C**: iOS first, keep Android on KMP until iOS is production-ready

**Recommendation**: Option A (iOS first) - reduces risk, validates approach before duplicating effort.

### 7. Data Migration

**Question**: If users have data saved in the current KMP version, how should we handle migration?

**Considerations**:
- iOS uses UserDefaults - keys might change
- Android uses SharedPreferences - should be compatible if we use same keys
- Need migration scripts?

**Action needed**: Review current data storage keys and plan migration if needed.

## Next Actions Needed from You

1. **Confirm architectural decisions** above
2. **Answer questions** about repository structure, versioning, migration approach
3. **Decide**: Start with iOS or do both in parallel?
4. **Review** the detailed migration plan and ask any questions

Once these are answered, you'll have a complete roadmap ready to execute.
