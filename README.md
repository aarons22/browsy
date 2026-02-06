# Browsy

A mobile book discovery app built with native iOS (Swift) and Android (Kotlin) implementations. Browse books with a TikTok-style swipe interface - full-screen covers, smooth vertical paging, and infinite scroll.

## Tech Stack

### iOS
- **Swift** - Native iOS implementation
- **SwiftUI** - Modern declarative UI framework
- **URLSession** - Native HTTP client
- **UserDefaults** - Local persistence
- **iOS 26.0+** - Minimum deployment target

### Android
- **Kotlin** - Native Android implementation
- **Jetpack Compose** - Modern declarative UI framework
- **Ktor** - HTTP client for API requests
- **SharedPreferences** - Local persistence
- **Android SDK 24+** - Minimum API level

### Backend
- **Firebase Functions** - Serverless backend
- **Firestore** - NoSQL database
- **TypeScript** - Backend language

### APIs
- **Google Books API** - Book metadata and cover images

## Project Structure

```
browsy/
├── ios/                      # Native iOS app (Swift + SwiftUI)
│   └── Browsy/               # Xcode project
│       ├── Models/           # Data models
│       ├── API/              # API clients and DTOs
│       ├── Repository/       # Data repositories
│       ├── ViewModels/       # ViewModels
│       └── Views/            # SwiftUI views
├── android/                  # Native Android app (Kotlin + Compose)
│   └── app/
│       └── src/main/kotlin/com/browsy/android/
│           ├── models/       # Data models
│           ├── api/          # API clients and DTOs
│           ├── repository/   # Data repositories
│           ├── viewmodels/   # ViewModels
│           └── ui/           # Compose UI components
├── backend/                  # Firebase Functions backend
│   └── src/                  # TypeScript backend code
├── .planning/                # Project documentation
└── wireframe_sketches/       # Design mockups
```

## Setup

### Prerequisites

**iOS Development:**
- macOS with Xcode 15+
- iOS 26.0+ SDK

**Android Development:**
- Android Studio with Android SDK 34
- Kotlin 2.0.0

**Backend:**
- Node.js 18+
- Firebase CLI

### 1. Clone the Repository

```bash
git clone <repository-url>
cd browsy
```

### 2. Configure API Keys

**iOS:**
```bash
cd ios/Browsy/Config
# Edit Debug.xcconfig and Release.xcconfig
# Replace YOUR_GOOGLE_BOOKS_API_KEY_HERE with your actual API key
```

**Android:**
```bash
cd android
cp local.properties.example local.properties
# Edit local.properties and add your Google Books API key
```

**Getting a Google Books API key:**
1. Visit https://console.cloud.google.com/
2. Create a new project or select existing
3. Enable "Books API" for your project
4. Create API key in Credentials section
5. Copy key to configuration files

**Free tier:** 1,000 requests/day (sufficient for development)

### 3. iOS Setup

```bash
cd ios/Browsy
open Browsy.xcodeproj
```

Then in Xcode:
1. Select a simulator or device target
2. Press ⌘R to build and run

### 4. Android Setup

```bash
cd android
./gradlew assembleDebug
# Or open in Android Studio and run
```

## Features

### Current

- ✅ Full-screen book cover display
- ✅ TikTok-style vertical swipe navigation
- ✅ Infinite scroll with pagination
- ✅ High-quality cover image loading
- ✅ Smooth snap-to-position behavior
- ✅ Book title and author overlay
- ✅ Book info panel with metadata
- ✅ TBR/Recommend/Read shelf actions
- ✅ Local shelf persistence
- ✅ Backend API for shelf sync

### Upcoming

- **Phase 6:** Authentication (Google, Apple, Email)
- **Phase 7:** User profile and shelves
- **Phase 8:** Feed personalization

## Development

### Build Commands

**iOS:**
```bash
cd ios/Browsy
xcodebuild -project Browsy.xcodeproj -scheme Browsy -configuration Debug build
```

**Android:**
```bash
cd android
./gradlew assembleDebug
```

**Backend:**
```bash
cd backend
npm install
npm run build
firebase deploy --only functions
```

## Architecture

### iOS Architecture

- **Models**: Swift structs conforming to `Codable`
- **API Layer**: Native `URLSession` with async/await
- **Repository**: Actor-based for thread safety
- **ViewModels**: `@MainActor` classes with `@Published` properties
- **Views**: SwiftUI with `StateFlow` observation
- **Storage**: `UserDefaults` for local persistence

### Android Architecture

- **Models**: Kotlin data classes with `@Serializable`
- **API Layer**: Ktor HTTP client with OkHttp engine
- **Repository**: Standard Kotlin classes with coroutines
- **ViewModels**: `AndroidViewModel` with `StateFlow`
- **Views**: Jetpack Compose with state hoisting
- **Storage**: `SharedPreferences` for local persistence

### Backend Architecture

- **Functions**: Express.js on Firebase Functions
- **Database**: Firestore with transaction-based updates
- **API**: RESTful endpoints for shelf operations

## Migration from KMP

This project was originally built with Kotlin Multiplatform (KMP) and has been migrated to fully native iOS and Android implementations. See `.planning/KMP_TO_NATIVE_MIGRATION_PLAN.md` for the complete migration strategy and history.

## Contributing

This is a personal project. The roadmap is defined in `.planning/ROADMAP.md`.

## License

TBD
