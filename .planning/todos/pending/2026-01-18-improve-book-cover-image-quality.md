---
created: 2026-01-18T09:06
title: Improve book cover image quality
area: api
files:
  - shared/src/commonMain/kotlin/com/browsy/data/api/GoogleBooksApi.kt
  - shared/src/commonMain/kotlin/com/browsy/data/api/OpenLibraryApi.kt
---

## Problem

Book cover images displayed in the app are very poor quality. The core value proposition of Browsy is recreating the calm, visual experience of browsing in a physical bookstore with full-screen book covers. Low quality images undermine this experience significantly.

Current implementation uses Google Books API and Open Library API for cover images, with a preference order of large → medium → thumbnail. However, even "large" covers from these APIs may not be sufficient for full-screen display on modern high-resolution devices.

## Solution

- Investigate higher quality cover image sources (Amazon Product API, ISBNdb, direct publisher APIs)
- Consider caching and pre-fetching larger images
- Evaluate image upscaling techniques as a fallback
- May need to switch to a paid API service for better cover quality
- TBD - needs research into available APIs and their image quality/resolution
