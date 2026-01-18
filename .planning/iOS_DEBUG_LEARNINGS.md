# iOS Debugging Learnings & Best Practices

*For architectural philosophy and iOS-first development principles, see [CLAUDE.md](../CLAUDE.md).*

## Core Lessons from FeedStrategy Integration Session

### 1. Swift/Kotlin Interop Challenges

**Problem**: Kotlin types don't map 1:1 to Swift types
- `String` becomes `NSString` requiring explicit casting
- `String?` becomes `NSString?` needing nil-safe conversion
- Default parameters may not work reliably across platform boundaries

**Solution Pattern**:
```kotlin
// Always provide explicit Swift-compatible overloads
suspend fun searchBooks(query: String, startIndex: Int = 0, orderBy: String? = null): Result<List<Book>>

// Add explicit overload for Swift
suspend fun searchBooks(query: String, startIndex: Int): Result<List<Book>> {
    return searchBooks(query, startIndex, null)
}
```

**Swift Implementation**:
```swift
// Always cast Kotlin strings explicitly
currentQuery = String(smartQuery.first!)
currentOrderBy = smartQuery.second != nil ? String(smartQuery.second!) : nil
```

### 2. iOS Build Process Best Practices

**Framework Build Order**:
1. First compile shared Kotlin frameworks: `./gradlew shared:compileKotlinIosArm64 shared:compileKotlinIosSimulatorArm64`
2. Then build iOS project: `xcodebuild -project iosApp.xcodeproj -scheme iosApp`
3. Use `CODE_SIGNING_ALLOWED=NO` for development builds to bypass team requirements

**Error Diagnosis Strategy**:
- Check Swift compilation errors first (type mismatches, missing methods)
- Verify shared framework is built and accessible
- Test API changes in isolation before full integration

### 3. Cross-Platform API Design Rules

**Default Approach**: Always create Swift-compatible overloads from the start
- Don't rely on default parameters across platform boundaries
- Provide explicit method signatures for each platform's needs
- Test iOS compilation after every API change

**Method Signature Strategy**:
```kotlin
// Full-featured method (used by Android, internal)
suspend fun methodName(param1: String, param2: Int = 0, param3: String? = null): Result<T>

// Swift-compatible overload (explicit parameters only)
suspend fun methodName(param1: String, param2: Int): Result<T> = methodName(param1, param2, null)

// Single-parameter overload if commonly used
suspend fun methodName(param1: String): Result<T> = methodName(param1, 0, null)
```

### 4. Development Workflow Optimization

**Testing Strategy**:
1. Make Kotlin API changes
2. Add Swift overloads immediately
3. Build shared frameworks
4. Update Swift code with explicit casting
5. Test iOS build before proceeding

**Common Pitfalls to Avoid**:
- ❌ Assuming default parameters work in Swift
- ❌ Not casting Kotlin strings to Swift String
- ❌ Adding new API methods without Swift overloads
- ❌ Testing only Android before iOS integration

### 5. Code Signing Workarounds

**Development Builds**:
```bash
xcodebuild -project iosApp.xcodeproj -scheme iosApp -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

**Alternative**: Configure Xcode project to use automatic signing with personal team for development.

### 6. Framework Integration Verification

**Quick Test Commands**:
```bash
# Verify shared framework builds
find . -name "*.framework" | grep -E "(iosArm64|iosSimulatorArm64)"

# Check framework is accessible to Xcode
ls shared/build/xcode-frameworks/Debug/
```

## Future Session Protocols

### Before Making API Changes:
1. ✅ Plan Swift overloads alongside Kotlin changes
2. ✅ Consider type conversion requirements
3. ✅ Test compile shared frameworks first

### When Adding New Methods:
1. ✅ Implement full Kotlin method
2. ✅ Add Swift-compatible overload immediately
3. ✅ Build frameworks: `./gradlew shared:compileKotlinIosArm64 shared:compileKotlinIosSimulatorArm64`
4. ✅ Update Swift code with explicit casting
5. ✅ Test iOS build: `xcodebuild ... CODE_SIGNING_ALLOWED=NO build`

### Debugging Failed iOS Builds:
1. ✅ Check Swift compiler errors first (type mismatches)
2. ✅ Verify shared framework compilation
3. ✅ Look for missing method overloads
4. ✅ Test with `CODE_SIGNING_ALLOWED=NO` to isolate issues

This proactive approach will prevent the type conversion and method compatibility issues we encountered, making iOS integration much smoother in future sessions.