# Roadmap: Browsy

## Overview

Build a mobile book discovery app from the ground up using Kotlin Multiplatform with native UI. Start with project foundation and book data integration, then build the core swipe-based browsing experience (the heart of the app), add backend infrastructure and authentication, and finish with user profiles and feed personalization.

## Domain Expertise

None

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

- [ ] **Phase 1: Foundation** - KMP project structure, build config, shared/native module setup
- [ ] **Phase 2: Book Data Layer** - Open Library/Google Books API integration, data models, caching
- [ ] **Phase 3: Core UI - Main Feed** - Full-screen cover display, swipe gestures, smooth transitions
- [ ] **Phase 4: Book Info & Actions** - Info panel, TBR/Recommend/Read/Buy actions, local state
- [ ] **Phase 5: Backend Infrastructure** - GCP setup (Cloud Run/Firestore), API endpoints, schema
- [ ] **Phase 6: Authentication** - User accounts, Google/Apple/Email login via Firebase Auth
- [ ] **Phase 7: User Profile & Shelves** - Profile screen, shelf grid views, backend sync
- [ ] **Phase 8: Feed Personalization** - Genre/Vibe selection, feed filtering, basic algorithm

## Phase Details

### Phase 1: Foundation
**Goal**: Working KMP project with shared module and native UI shells (SwiftUI + Compose)
**Depends on**: Nothing (first phase)
**Research**: Likely (KMP project setup, SwiftUI/Compose integration patterns)
**Research topics**: Current KMP project structure, Gradle setup for multiplatform, native UI integration patterns, shared code architecture
**Plans**: TBD

### Phase 2: Book Data Layer
**Goal**: Fetch and display book metadata and covers from free APIs
**Depends on**: Phase 1
**Research**: Likely (external APIs)
**Research topics**: Open Library API, Google Books API, cover image retrieval, data models, caching strategy
**Plans**: TBD

### Phase 3: Core UI - Main Feed
**Goal**: The core browsing experience — full-screen covers, smooth swipe navigation, one book at a time
**Depends on**: Phase 2
**Research**: Unlikely (internal native UI work)
**Plans**: TBD

This is THE CORE VALUE. If this phase doesn't feel like browsing bookstore shelves, the app fails.

### Phase 4: Book Info & Actions
**Goal**: Tap/swipe reveals book details; TBR/Recommend/Read/Buy actions work locally
**Depends on**: Phase 3
**Research**: Unlikely (building on Phase 3 patterns)
**Plans**: TBD

### Phase 5: Backend Infrastructure
**Goal**: GCP backend with API endpoints for user data and book actions
**Depends on**: Phase 1 (can run parallel to Phases 2-4)
**Research**: Likely (GCP services setup)
**Research topics**: Cloud Run setup, Firestore schema design, API design patterns, GCP project configuration
**Plans**: TBD

### Phase 6: Authentication
**Goal**: Users can create accounts and log in with Google, Apple, or Email
**Depends on**: Phase 5
**Research**: Likely (Firebase Auth, OAuth)
**Research topics**: Firebase Auth setup, Google Sign-In, Apple Sign-In, Email/password auth, KMP auth integration
**Plans**: TBD

### Phase 7: User Profile & Shelves
**Goal**: Profile screen with TBR, Recommendations, and Read shelves synced to backend
**Depends on**: Phase 4, Phase 6
**Research**: Unlikely (internal patterns)
**Plans**: TBD

### Phase 8: Feed Personalization
**Goal**: Genre/Vibe selection during onboarding; feeds filtered by user preferences
**Depends on**: Phase 7
**Research**: Unlikely (internal algorithm logic)
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8

Note: Phase 5 (Backend) can potentially run in parallel with Phases 2-4 since they're independent.

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 3/3 | Complete | 2026-01-14 |
| 2. Book Data Layer | 4/4 | Complete | 2026-01-14 |
| 3. Core UI - Main Feed | 4/4 | Complete | 2026-01-15 |
| 4. Book Info & Actions | 0/TBD | Not started | - |
| 5. Backend Infrastructure | 0/TBD | Not started | - |
| 6. Authentication | 0/TBD | Not started | - |
| 7. User Profile & Shelves | 0/TBD | Not started | - |
| 8. Feed Personalization | 0/TBD | Not started | - |
