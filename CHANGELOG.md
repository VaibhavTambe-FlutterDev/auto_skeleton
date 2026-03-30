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
