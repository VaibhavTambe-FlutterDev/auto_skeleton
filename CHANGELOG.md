## 0.3.0

### List Skeleton — template-based bones (no fake data)
* `skeletonItem` + `skeletonItemCount` on `AutoSkeleton` — pass one template widget and the package repeats it N times to generate the skeleton. Solves the "empty list = nothing to scan" problem.
* `skeletonScrollable` — wraps the template column in a non-scrolling viewport when items exceed available height.

### Performance & Correctness
* **Memory leak fixed** — removed the global `_boneCache` map; each widget now owns its cache and releases it on dispose. `AutoSkeleton.clearCache()` is deprecated (no-op).
* **Cache hits without a `Key`** — previously, widgets without an explicit key re-scanned on every rebuild. Cache is now per-state and always active.
* **Theme change auto-invalidation** — switching light ↔ dark now rebuilds bones with the correct colors (previously stuck with stale colors until manual `clearCache()`).
* **Cache fingerprint** is now `size + themeBrightness` instead of object-identity `hashCode`, eliminating false misses on structurally identical rebuilds.

### UX
* **First-frame flash eliminated** — added `fallbackColor()` to `PlaceholderEffect`; the pre-scan frame now paints a solid shimmer-base rectangle instead of invisible content.

## 0.2.0

### ListView / GridView / CustomScrollView support
* Fixed widget tree scanner to handle scrollable widgets correctly
* Safe coordinate transforms for sliver-based layouts (no more overflow/wrong sizing)
* Bones are clipped to visible viewport bounds — offscreen items are skipped
* Handles `Stack`, `Wrap`, `IntrinsicHeight` via improved render tree traversal

### Bone caching
* Skeleton layout is cached and reused across rebuilds
* Cache invalidates automatically when widget size or child changes
* `AutoSkeleton.clearCache()` for manual invalidation

### App-level wrapper (zero per-widget wrapping)
* `AutoSkeletonApp.builder()` — wrap entire app, every screen gets skeleton automatically
* `AutoSkeletonAppController` — programmatic `startLoading()` / `stopLoading()` / `toggle()`
* `controller.observer` — `NavigatorObserver` that auto-shows skeleton during route transitions
* Works with `ValueNotifier<bool>` for simple reactive control

## 0.1.2

* Added `screenshots` field to pubspec.yaml for pub.dev gallery
* Updated `flutter_lints` to v5.0.0 for latest analysis rules
* Improved pub.dev scoring compliance

## 0.1.1

* **`AutoSkeletonBuilder`** — async data loading with automatic skeleton display
  * Supports `Future` and `Stream` data sources
  * Zero `setState` needed — skeleton shown while loading, content when done
  * Built-in `errorBuilder` for error states
  * `onData` / `onError` callbacks
* Added tests for builder (13 total tests passing)

## 0.1.0

* Initial release
* `AutoSkeleton` widget — wrap any widget tree to auto-generate skeleton placeholders
* `SliverAutoSkeleton` — sliver variant for CustomScrollView
* **Theme-aware colors** — auto-derives from your app's `ColorScheme` (light & dark)
* **3-layer color control** — theme auto-detect → global config → per-widget override
* **Effects:** `ShimmerEffect`, `PulseEffect`, `SolidEffect`
* **Annotations:** `PlaceholderIgnore`, `PlaceholderReplace`, `PlaceholderLeaf`, `PlaceholderShape`
* **Extension:** `.withSkeleton(loading: bool)` on any Widget
* **Presets:** `SkeletonPresets.listTile()`, `.productCard()`, `.foodCard()`, `.horizontalCardRow()`
* `AutoSkeletonConfig` for global configuration via InheritedWidget
* Switch animation (skeleton → content) with configurable duration and curve
