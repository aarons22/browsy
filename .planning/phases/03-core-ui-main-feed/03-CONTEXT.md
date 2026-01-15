# Phase 3: Core UI - Main Feed - Context

**Gathered:** 2026-01-14
**Status:** Ready for planning

<vision>
## How This Should Work

When someone opens Browsy, they immediately see a full-screen book cover — no loading states, no empty screens, just dive straight into browsing. The experience should feel like TikTok but for book covers: swipe up vertically to see the next book, with covers sliding in from the bottom as the current one slides out.

Each book is displayed full-screen with crisp, high-resolution cover images that fill the screen perfectly. The covers should look as good as they do in a physical bookstore — no blurriness, proper scaling, beautiful presentation.

As you swipe, books snap into perfect center position. There's no "halfway between books" state — each cover is either fully visible or transitioning. The feed feels endless: just keep swiping and more books keep appearing, seamlessly loaded in the background.

While browsing, you can see the book title and author subtly displayed (small text, non-intrusive), and there's a quick action button (heart or bookmark icon) right on the cover to add books to your TBR/wishlist without breaking the browsing flow.

</vision>

<essential>
## What Must Be Nailed

- **High-quality cover display** — Crisp, high-resolution covers that fill the screen perfectly. No pixelation, no awkward cropping. The covers need to look *beautiful* — this is a visual browsing experience first and foremost.

- **Snap-to-position behavior** — Each book centers perfectly when you stop swiping. Never halfway between books, always a clean, centered full-screen cover in view.

- **Vertical swipe interaction** — Continuous vertical scrolling like TikTok/Instagram Reels. Swipe up to see next book, current cover slides out as next slides in from bottom.

</essential>

<specifics>
## Specific Ideas

**Interaction model:**
- Vertical swipe (up/down) for browsing books, like TikTok feed
- Current cover slides out of view while next one slides in from bottom
- Snap to center — books never rest halfway, always perfectly centered
- Infinite scroll — seamlessly load more books as user swipes, no "load more" button

**Visual presentation:**
- Full-screen book covers (fill the entire screen)
- High-resolution images from book data layer (prefer "large" size from APIs)
- Book title and author displayed subtly somewhere (small text overlay or bottom caption)
- Minimal chrome — no persistent navigation clutter, full immersion

**Actions:**
- Quick TBR/wishlist button visible on cover (heart icon or bookmark icon)
- Tap button to save book without leaving feed
- Keep browsing flow uninterrupted

**Opening behavior:**
- App opens directly to a full-screen cover, ready to browse immediately
- No loading screens or empty states on launch

</specifics>

<notes>
## Additional Context

This is THE CORE VALUE of Browsy. If the browsing experience doesn't feel like wandering through a physical bookstore — calm, visual, discovery-driven — then the app fails its core promise.

The user emphasized that **visual quality trumps smoothness**. While smooth animations are nice, the #1 priority is making covers look beautiful and crisp. A slightly slower transition is acceptable if it means covers look perfect.

Reference model: TikTok's vertical swipe feed, but for book covers instead of videos. The gesture and snap-to-position behavior should feel familiar to anyone who's used TikTok or Instagram Reels.

Priority hierarchy for this phase:
1. Beautiful, high-quality cover display
2. Snap-to-position behavior (perfect centering)
3. Infinite scroll / seamless pagination
4. Smooth vertical swipe transitions
5. Quick TBR action without breaking flow

</notes>

---

*Phase: 03-core-ui-main-feed*
*Context gathered: 2026-01-14*
