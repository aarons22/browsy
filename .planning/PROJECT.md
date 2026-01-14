# Browsy

## What This Is

A mobile book discovery app that recreates the calm, visual experience of browsing in a physical bookstore. Users swipe through full-screen book covers one at a time, discovering books through curiosity and atmosphere rather than ratings or reviews. Built with Kotlin Multiplatform (shared logic) with native UI on iOS (SwiftUI) and Android (Jetpack Compose).

## Core Value

The swipe experience must feel like browsing shelves in a bookstore — full-screen covers, smooth transitions, one book at a time, never rushed. If the discovery algorithm is mediocre but browsing feels right, v1 still works.

## Requirements

### Validated

(None yet — ship to validate)

### Active

**Onboarding**
- [ ] User account creation (Google, Apple, Email login options)
- [ ] Genre selection screen (Fantasy, Sci-Fi, Romance, Mystery, Horror, Thriller, Historical, Biography, History, Self-Help, Cookbooks, True Crime, etc.)
- [ ] Vibe selection screen (start with ~5-10 vibes, expand iteratively)

**Main Feed**
- [ ] Full-screen book cover display — one book visible at a time, never halfway between
- [ ] Swipe up/down navigation between books with smooth transitions
- [ ] Feed selector dropdown (Main Feed / Genre / Vibe)
- [ ] Minimal UI — account icon, search icon, feed selector only
- [ ] Feeds feel abundant and never-ending — always fresh content on return

**Book Actions**
- [ ] TBR (To Be Read) — save to wishlist
- [ ] Recommend — add to public recommendation list
- [ ] Read — mark as read
- [ ] Buy — links to Amazon, Barnes & Noble, Bookshop.org, Library availability

**Book Info**
- [ ] Tap or swipe left/right reveals metadata panel
- [ ] Displays: Title, Author, Description, Pub Date, Genre, Cover
- [ ] Action buttons: TBR, Recommend, Read, Buy

**User Profile**
- [ ] TBR Shelf (grid view of saved books)
- [ ] Recommendation Shelf (public)
- [ ] Read Shelf
- [ ] User name and avatar

**Backend**
- [ ] User authentication and account management
- [ ] Book data sync (shelves, preferences)
- [ ] Book metadata and cover retrieval from free APIs

### Deferred (v2+)

- Following other users and seeing their recommendations/TBR
- "Best Cover Designs of 2025" curated collections
- Amazon login option
- Advanced personalization based on browsing behavior signals

### Out of Scope

- Star ratings or numerical scores — removes judgment, keeps discovery pure
- Written reviews or comments — users express taste through recommendations, not criticism
- Reading progress tracking — Browsy is for discovery, not reading management
- Badges, streaks, achievements — no gamification, keeps experience calm
- Notifications or alerts — users come when they want, no interruptions
- Subscription or paywalls — v1 is free, monetization through affiliate links only

## Context

**Problem**: Digital book discovery is overwhelmed by ratings, reviews, rankings, and lists. It feels transactional and judgment-heavy. Physical bookstore browsing is calm, visual, and discovery-driven — but that experience doesn't exist digitally.

**Solution**: A cover-first, visually immersive mobile app that encourages wandering. No pressure to evaluate, score, or compare. Just browse.

**User signals without judgment**: Users express taste positively through TBR and Recommend actions. No negative feedback collected. Algorithm personalization comes from (1) chosen vibes/genres and (2) behavior signals like TBR/Recommend/skim time.

**Vibes system**: "Browsy Vibes" are mood/theme tags beyond traditional genres — Coming of Age, Complex Family, Rom-Com, Messy Love, Grief and Loss, Supernatural, Horror Classics, etc. Start with a few, expand based on what resonates. Auto-tag using keyword mapping from book descriptions.

**Wireframes available**: `wireframe_sketches/` contains hand-drawn sketches showing:
1. Login + Genre/Vibe selection onboarding
2. Main feed with full-screen cover, minimal UI, TBR/Recommend buttons
3. Book info panel with metadata and actions
4. User profile with grid shelves

## Constraints

- **Tech stack**: Kotlin Multiplatform with native UI (SwiftUI on iOS, Jetpack Compose on Android) — non-negotiable for the experience quality
- **Book data**: Start with free APIs (Open Library, Google Books) — flexible to paid services later if needed
- **Backend**: GCP preferred (user is familiar) — but flexible

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| KMP + Native UI | Best UX for swipe-heavy, visual app; shared logic reduces duplication | — Pending |
| Free book APIs for MVP | Minimize costs while validating concept | — Pending |
| Social features deferred | Focus on core solo browsing experience first | — Pending |
| Vibes defined iteratively | Start small, expand based on what resonates with users | — Pending |
| No negative feedback | Keeps experience positive; users express taste through saves/recommends | — Pending |

---
*Last updated: 2026-01-14 after initialization*
