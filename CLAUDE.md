# Browsy Architectural Philosophy

## iOS-First Development Priority

Browsy's core value lies in recreating the **calm, visual experience of browsing books** through smooth, immersive interactions. This experience quality is non-negotiable and drives our architectural approach.

### Core Principle: iOS Testing Drives UI Decisions

When implementing UI concepts and interactions:

1. **Prototype iOS implementations first** for features involving user experience and visual interactions
2. **Test iOS build quality immediately** after any shared module API changes that affect the UI layer
3. **Use iOS user experience feedback** to guide cross-platform architectural decisions
4. **Validate UI smoothness on iOS** before considering implementation complete

### Why iOS-First for UI Work

- **Visual fidelity matters**: Browsy's book discovery experience depends on smooth swiping, beautiful cover displays, and seamless transitions
- **Touch interaction quality**: The swipe-through-books experience must feel natural and responsive - iOS provides immediate tactile feedback
- **Native performance validation**: SwiftUI performance characteristics help validate that shared architecture supports the required experience quality
- **Early integration feedback**: iOS build errors surface cross-platform API design issues faster than waiting for full integration

## Architectural Decision Framework

### When to Implement iOS-First

**Always start with iOS for:**
- New UI components (book cards, feed views, navigation)
- User interaction patterns (swipe gestures, transitions)
- Visual experience features (animations, layout changes)
- Performance-sensitive display logic (feed scrolling, cover rendering)

**Implement cross-platform simultaneously for:**
- Pure business logic (authentication, data processing)
- API integrations (book search, user accounts)
- Data models and structures
- Backend communication protocols

### iOS Feedback Integration Workflow

1. **Implement shared logic** with iOS-compatible API design patterns
2. **Build iOS implementation** using the shared module
3. **Test iOS experience quality** - does it feel like browsing a bookstore?
4. **Iterate architecture** based on iOS performance and interaction feedback
5. **Validate Android implementation** matches iOS experience quality

## Integration with Existing Development Systems

### Relationship to GSD Planning

This architectural philosophy **complements** the existing GSD planning system:
- **GSD phases handle project execution** - what to build and when
- **CLAUDE.md provides architectural approach** - how to prioritize iOS when building UI features
- **Use together**: Reference this philosophy during GSD phases involving UI work

### Connection to Technical Documentation

- **[iOS_DEBUG_LEARNINGS.md](.planning/iOS_DEBUG_LEARNINGS.md)**: Detailed Swift/Kotlin interop patterns and build troubleshooting
- **[SWIFTUI_STYLE_GUIDE.md](.planning/SWIFTUI_STYLE_GUIDE.md)**: Code standards and implementation best practices
- **[PROJECT.md](.planning/PROJECT.md)**: Feature requirements and project context
- **PROJECT_STRUCTURE.md**: Technical architecture and file organization

## Claude Implementation Guidelines

### For UI Feature Development

1. **Always validate iOS builds** after making changes to shared module APIs used by UI components
2. **Prioritize iOS experience smoothness** over cross-platform implementation speed for user-facing features
3. **Test swipe interactions on iOS** to ensure they meet the "bookstore browsing" quality standard
4. **Use iOS build errors** as early signals of cross-platform API design issues

### For Cross-Platform Architecture

- **Design shared APIs with iOS Swift interop in mind** (see iOS_DEBUG_LEARNINGS.md for specific patterns)
- **Create Swift-compatible method overloads** when adding new APIs that iOS will consume
- **Validate that shared architecture supports** the visual and interaction quality required on iOS
- **Balance iOS optimization with KMP shared logic goals** - don't sacrifice cross-platform benefits unnecessarily

### Decision Criteria

**When iOS-first approach applies:**
- Feature involves user interaction or visual experience
- Implementation affects app performance or responsiveness
- Changes touch the UI layer or user-facing APIs
- Quality of "bookstore browsing feeling" is at stake

**When simultaneous cross-platform approach applies:**
- Pure business logic with no UI impact
- Backend integrations or data processing
- Infrastructure or tooling improvements
- Features that don't affect user experience quality

---

*This architectural philosophy ensures Browsy delivers the calm, visual book discovery experience that defines its core value, while maintaining the benefits of Kotlin Multiplatform shared logic.*