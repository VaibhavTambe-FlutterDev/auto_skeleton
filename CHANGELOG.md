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
