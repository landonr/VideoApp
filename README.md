# VideoApp — Architecture & Decisions

This document summarizes the app’s architecture, key design choices, memory management approach, and how smooth view-to-view video transitions are achieved.

## Architecture approach
- SwiftUI-first UI with a lightweight MVVM-ish structure:
  - Models: `FeedElement` (list of videos) and `VideoElement` (single video URL + id).
  - Views: `RootView` (fetch + state machine), `FeedView` (paged vertical feed), `VideoPostView` (per-cell overlay/labels), `VideoPlaybackView` (SwiftUI wrapper for `AVPlayerViewController`).
  - Manager: `VideoPlayerManager` (`ObservableObject`) owns one `AVPlayer` per video and coordinates prefetch, play/pause, and cache trimming.
- Data flow:
  1) `RootView` loads a remote JSON feed via a small `URLSession` extension (`HTTPClient.swift`).
  2) On success, `FeedView` renders a vertically paged `ScrollView`/`LazyVStack` of posts.
  3) Each post uses `VideoPlayerManager.player(for:)` to get a dedicated `AVPlayer` and renders it via `VideoPlaybackView`.
  4) The feed tracks the visible item (`scrollPosition(id:)`) and tells the manager to `play(videoId:)` and `prefetch(around:in:)`.

## Key design decisions and trade-offs
- One AVPlayer per item (not a single shared player):
  - Pros: enables true prefetch/preroll of upcoming items; avoids retune/replacement glitches when paging; supports quick back-scroll with warm players.
  - Cons: higher memory/decoder resource use; requires explicit cache trimming.
- Use `AVPlayerViewController` via `UIViewControllerRepresentable`:
  - Pros: reliable playback, proper audio session handling, easy configuration; no custom controls needed (`showsPlaybackControls = false`).
  - Cons: more complicated than using SwiftUI’s built-in `VideoPlayer`, slightly heavier than a raw `AVPlayerLayer`.
- Vertical paging with `ScrollView` + `LazyVStack` + `.scrollTargetBehavior(.paging)`:
  - Pros: fine-grained control over ids/positions and lifecycle; works smoothly with SwiftUI.
  - Alternative: `TabView` with `.page` style is simpler but offers less control over item identity and prefetch hooks.
- Prefetch radius defaults to 2: balances smoothness vs. memory/network. This can be tuned per device/profile.
- Video gravity set to `.resizeAspectFill`:
  - Pros: fills the screen edge-to-edge for a feed look.
  - Cons: crops parts of the video; could be made user-configurable.

## Memory management
- Explicit player cache trimming:
  - `VideoPlayerManager` keeps `players: [UUID: AVPlayer]` and removes players that fall outside a sliding window (`trimCache(keeping:)`).
  - When trimming: pause, `replaceCurrentItem(with: nil)`, clear KVO and notification observers, and drop any pending preroll flags.
- Bound prefetching:
  - Only pre-warms players within `prefetchRadius`; everything else is released to keep the memory footprint predictable.
- Safe observer lifecycle:
  - KVO (`NSKeyValueObservation`) for `AVPlayerItem.status` is stored per id; invalidated on trim and in `deinit` to prevent leaks or KVO crashes.
  - Notification tokens for item-end looping are also removed on trim and in `deinit`.
- Avoid retain cycles:
  - Playback/preroll closures capture `self` and `player` weakly.
  - Non-active players are paused (and often reset to `.zero`) to reduce resource pressure.

## Strategy for smooth transitions
- Proactive prefetch + preroll:
  - On index change, `prefetch(around:in:)` warms players in a small window and calls `preroll(atRate:)` once the item is `readyToPlay` (observed via KVO).
  - `preferredForwardBufferDuration = 1` sec nudges the pipeline to keep a small buffer ahead.
- Minimize stalls during page changes:
  - `automaticallyWaitsToMinimizeStalling = true` and playing only the visible item helps keep CPU/decoder budget focused.
- Looping without flashes:
  - Each `AVPlayerItem` loops by seeking to `.zero` on `.AVPlayerItemDidPlayToEndTime`, avoiding a black frame if the user scrolls away and back quickly.
- Paged layout guarantees one active viewport:
  - Using `.scrollTargetBehavior(.paging)` with `scrollPosition(id:)` ensures we can deterministically pause others and play exactly one.

---

### Run locally
- Open `VideoApp.xcodeproj` in Xcode (iOS target) and run on a device or simulator. The default feed is a public JSON manifest.

### Future improvements (nice-to-have)
- Prevent scrolling to the next video until it's ready for
immediate playback to avoid black screens or loading states
- Add pull-to-refresh to reload the feed
- Support offline caching of videos
- Add error handling UI for video load failures

