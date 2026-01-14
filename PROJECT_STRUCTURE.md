# Browsy - Project Structure

## Overview

Kotlin Multiplatform Mobile (KMP) project with shared business logic and native UI layers for Android and iOS.

## Modules

### Root Project: Browsy
The root project coordinates builds across all subprojects.

### :shared
**Purpose:** Shared Kotlin Multiplatform module containing cross-platform business logic

**Targets:**
- `android` - Android library
- `iosArm64` - iOS devices (ARM64)
- `iosSimulatorArm64` - iOS simulator on Apple Silicon
- `iosX64` - iOS simulator on Intel Macs

**Build output:**
- Android: AAR library consumed by androidApp
- iOS: Static framework consumed by iosApp

**Source sets:**
- `commonMain/` - Platform-agnostic Kotlin code
- `androidMain/` - Android-specific implementations
- `iosMain/` - iOS-specific implementations (shared across all iOS targets)

### :androidApp
**Purpose:** Android application module with Jetpack Compose UI

**Type:** Android Application
**UI Framework:** Jetpack Compose with Material 3
**Dependencies:** Consumes :shared module as an AAR library

**Build output:**
- Debug APK: `androidApp/build/outputs/apk/debug/androidApp-debug.apk`
- Release APK: `androidApp/build/outputs/apk/release/androidApp-release.apk`

### :iosApp
**Purpose:** iOS application with SwiftUI UI

**Type:** Xcode project
**UI Framework:** SwiftUI
**Dependencies:** Consumes :shared module as a static framework via Gradle integration

**Build integration:**
- Xcode build phase runs `embedAndSignAppleFrameworkForXcode` Gradle task
- Framework search paths point to `shared/build/xcode-frameworks/`

## Version Information

| Component | Version |
|-----------|---------|
| Kotlin | 2.0.0 |
| Gradle | 8.5 |
| Android Gradle Plugin | 8.2.2 |
| Compose BOM | 2024.01.00 |
| iOS Deployment Target | 16.0 |
| Min Android SDK | 24 |
| Target Android SDK | 34 |

## Common Gradle Tasks

### Full Project

```bash
# Build everything (Android + shared module)
./gradlew build

# Clean all build outputs
./gradlew clean

# List all modules
./gradlew projects

# List all tasks
./gradlew tasks
```

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
```

### Shared Module

```bash
# Build shared module for all targets
./gradlew :shared:assemble

# Build iOS framework for specific target
./gradlew :shared:linkDebugFrameworkIosArm64         # Device
./gradlew :shared:linkDebugFrameworkIosSimulatorArm64 # Apple Silicon simulator
./gradlew :shared:linkDebugFrameworkIosX64            # Intel simulator

# Run shared module tests
./gradlew :shared:test
```

### iOS App

```bash
# Build iOS framework from command line (requires macOS)
./gradlew :shared:embedAndSignAppleFrameworkForXcode

# Open in Xcode (macOS only)
open iosApp/iosApp.xcodeproj
```

**Note:** iOS app builds require macOS. The Gradle tasks for iOS framework compilation (linkDebugFrameworkIos*) will be skipped on non-macOS platforms.

## Project Architecture

```
browsy/
├── androidApp/          # Android app with Compose UI
│   ├── src/
│   │   └── main/
│   │       ├── AndroidManifest.xml
│   │       └── java/com/browsy/android/
│   │           ├── MainActivity.kt
│   │           └── ui/theme/
│   └── build.gradle.kts
│
├── iosApp/              # iOS app with SwiftUI
│   ├── iosApp.xcodeproj/
│   └── iosApp/
│       ├── iOSApp.swift      # App entry point
│       ├── ContentView.swift  # Main view
│       └── Assets.xcassets/
│
├── shared/              # KMP shared module
│   ├── src/
│   │   ├── commonMain/kotlin/com/browsy/
│   │   │   ├── Platform.kt    # expect declarations
│   │   │   └── Greeting.kt    # Shared business logic
│   │   ├── androidMain/kotlin/com/browsy/
│   │   │   └── Platform.android.kt  # Android actuals
│   │   └── iosMain/kotlin/com/browsy/
│   │       └── Platform.ios.kt      # iOS actuals
│   └── build.gradle.kts
│
├── gradle/
│   └── libs.versions.toml   # Version catalog
├── build.gradle.kts         # Root build configuration
├── settings.gradle.kts      # Project structure
└── gradle.properties        # Build settings
```

## Key Configuration Files

### `gradle/libs.versions.toml`
Centralized dependency version management. All library versions are defined here and referenced in module build files.

### `gradle.properties`
Build configuration and performance tuning:
- JVM memory settings
- Gradle build caching
- Kotlin Native target settings

### `local.properties`
Local environment configuration (not committed to git):
- `sdk.dir` - Android SDK location

## Development Notes

### Platform-Specific Code
The expect/actual pattern allows platform-specific implementations:

```kotlin
// commonMain - declare interface
expect fun getPlatform(): Platform

// androidMain - Android implementation
actual fun getPlatform(): Platform = AndroidPlatform()

// iosMain - iOS implementation
actual fun getPlatform(): Platform = IOSPlatform()
```

### iOS Framework Integration
The iOS app consumes the shared Kotlin code as a static framework. Xcode automatically builds the framework via a build phase script that calls the Gradle task.

### Android Library Integration
The Android app consumes the shared module as a standard Android library (AAR) through Gradle dependency.

## Build System Requirements

**For Android development:**
- JDK 17+
- Android SDK with API 34 installed
- Gradle 8.5 (included via wrapper)

**For iOS development (macOS only):**
- Xcode 15+
- iOS 16.0+ SDK
- Command Line Tools for Xcode

## Troubleshooting

**"SDK location not found"**
- Create `local.properties` in project root
- Add line: `sdk.dir=/path/to/android/sdk`

**iOS framework build fails on Linux**
- This is expected. iOS compilation requires macOS with Xcode
- The project is configured correctly; builds will work on macOS

**Gradle daemon memory issues**
- Adjust `org.gradle.jvmargs` in `gradle.properties`
- Current setting: `-Xmx2048M`
