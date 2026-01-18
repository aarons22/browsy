---
created: 2026-01-18T09:07
title: Improve feed relevance algorithm
area: api
files:
  - shared/src/commonMain/kotlin/com/browsy/data/repository/BookRepository.kt
  - shared/src/commonMain/kotlin/com/browsy/data/api/GoogleBooksApi.kt
---

## Problem

Feed is showing very old books that feel irrelevant. The current implementation uses a hardcoded "fantasy" query to Google Books API, which returns books without any recency weighting or relevance scoring.

For Browsy's core value of recreating the bookstore browsing experience, the feed needs to feel fresh and discoverable — like walking through a "new releases" or "staff picks" section, not a dusty archive.

Key tensions to balance:
- Show newer/popular books that feel relevant
- Still enable discovery of hidden gems and older classics
- Avoid creating a "bestseller-only" echo chamber
- Maintain the calm, serendipitous browsing feel

## Solution

Research needed:
- Google Books API orderBy parameters (relevance vs newest)
- Mixing strategies: recent releases + curated classics + genre exploration
- Date filtering options in API queries
- Alternative APIs with better curation (Goodreads data, NYT bestsellers, indie bookstore APIs)
- Consider building a lightweight recommendation layer on backend (Phase 5+)

Note: Phase 8 (Feed Personalization) is planned but may need to address basic relevance earlier.
