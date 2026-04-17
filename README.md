# auto_skeleton

[![pub package](https://img.shields.io/pub/v/auto_skeleton.svg)](https://pub.dev/packages/auto_skeleton)
[![License: BSD-3](https://img.shields.io/badge/license-BSD--3-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

Auto-generate skeleton/shimmer loading screens from your **actual widget tree**. No fake data needed — just wrap your widget and get a matching placeholder shape automatically.

## Screenshots

| Skeleton (Loading) | Loaded (Content) |
|:---:|:---:|
| <img src="https://raw.githubusercontent.com/VaibhavTambe-FlutterDev/auto_skeleton/main/screenshots/02_skeleton_top.png" width="280"/> | <img src="https://raw.githubusercontent.com/VaibhavTambe-FlutterDev/auto_skeleton/main/screenshots/01_loaded_top.png" width="280"/> |
| <img src="https://raw.githubusercontent.com/VaibhavTambe-FlutterDev/auto_skeleton/main/screenshots/03_skeleton_bottom.png" width="280"/> | <img src="https://raw.githubusercontent.com/VaibhavTambe-FlutterDev/auto_skeleton/main/screenshots/04_loaded_bottom.png" width="280"/> |

### Annotations: Fine-grained Control

| Annotation Skeleton | Annotation Loaded |
|:---:|:---:|
| <img src="https://raw.githubusercontent.com/VaibhavTambe-FlutterDev/auto_skeleton/main/screenshots/05_skeleton_annotations.png" width="280"/> | <img src="https://raw.githubusercontent.com/VaibhavTambe-FlutterDev/auto_skeleton/main/screenshots/04_loaded_bottom.png" width="280"/> |

- **`PlaceholderIgnore`** — the toggle switches are hidden during loading (not relevant to skeleton)
- **`PlaceholderLeaf`** — the colored icon boxes are treated as solid rectangles (no child traversal)

## Why auto_skeleton?

Building skeleton loading UIs manually is tedious and goes out of sync with your real layouts. `auto_skeleton` solves this by **introspecting your widget tree** at render time and generating matching bone shapes for every content widget (Text, Image, Icon, Button, etc.).

### How It Compares

| Feature | auto_skeleton | skeletonizer | shimmer |
|---|---|---|---|
| Auto-detect widget shapes | Yes | Yes | No |
| Zero fake data needed | Yes | No (needs mock data) | No |
| Async builder (no setState) | Yes | No | No |
| Future + Stream support | Yes | No | No |
| Theme-aware colors | Yes | No | No |
| Extension syntax `.withSkeleton()` | Yes | No | No |
| Pre-built presets | Yes | No | No |
| Multiple effects (shimmer, pulse, solid) | Yes | Yes | Shimmer only |
| Annotation system | Yes | Yes | No |
| Switch animation | Yes | Yes | No |
| Dark mode auto-detection | Yes | Yes | No |
| ListView/GridView support | Yes | Yes | Shimmer only |
| Bone caching (no rebuild) | Yes | No | No |
| App-level wrapper | Yes | No | No |

> *Comparison based on default features of each package as of April 2026. All packages are actively maintained and excellent in their own right.*

## Installation

```yaml
dependencies:
  auto_skeleton: ^0.3.0
```

```bash
flutter pub get
```

## Quick Start

### Basic Usage

Wrap any widget with `AutoSkeleton`:

```dart
AutoSkeleton(
  enabled: _isLoading,
  child: Card(
    child: ListTile(
      leading: CircleAvatar(child: Icon(Icons.person)),
      title: Text('John Doe'),
      subtitle: Text('Software Developer'),
      trailing: Icon(Icons.chevron_right),
    ),
  ),
)
```

That's it! When `enabled: true`, the package scans the widget tree and renders matching skeleton bones with a shimmer animation. When `enabled: false`, your actual content is shown.

Colors are **automatically derived from your app's theme** — works in both light and dark mode with zero configuration.

### List Skeleton — No Fake Data, No Mock Items

The most common skeleton problem: your list is empty while loading, so there's nothing to scan. Use `skeletonItem` + `skeletonItemCount` to provide one template widget — the package repeats it N times and scans that instead:

```dart
AutoSkeleton(
  enabled: _isLoading,
  skeletonItem: ListTile(
    leading: CircleAvatar(child: Icon(Icons.person)),
    title: Text('Name'),
    subtitle: Text('Description'),
  ),
  skeletonItemCount: 6,        // show 6 placeholder rows
  child: ListView.builder(     // real list — empty while loading is fine
    itemCount: items.length,
    itemBuilder: (_, i) => MyListTile(item: items[i]),
  ),
)
```

**No fake data needed.** The template is one real-looking widget with any text — the package replaces it with bones automatically.

| | skeletonizer | auto_skeleton |
|---|---|---|
| List loading — fake data required | Yes, N items | No — one template |
| Works when list is empty | No | Yes |
| Template repeated N times | No | Yes |

### AutoSkeletonBuilder — Zero setState

Handle async data loading with automatic skeleton. No `setState`, no `_isLoading` boolean:

```dart
AutoSkeletonBuilder<User>(
  future: fetchUser(),
  skeleton: ListTile(
    leading: CircleAvatar(child: Icon(Icons.person)),
    title: Text('Placeholder name'),
    subtitle: Text('Loading...'),
  ),
  builder: (context, user) => ListTile(
    leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
    title: Text(user.name),
    subtitle: Text(user.bio),
  ),
)
```

Works with `Stream` too:

```dart
AutoSkeletonBuilder<List<Post>>(
  stream: postStream(),
  skeleton: MyPostListSkeleton(),
  builder: (context, posts) => PostList(posts),
  errorBuilder: (context, error) => ErrorWidget(error),
)
```

### Extension Syntax

Even simpler — use the `.withSkeleton()` extension:

```dart
Card(
  child: ListTile(
    title: Text('Hello World'),
    subtitle: Text('This is a subtitle'),
  ),
).withSkeleton(loading: _isLoading)
```

## Migrating from Other Packages

### From `shimmer`

```dart
// Before (shimmer) — manual layout, no auto-detection
Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Column(
    children: [
      Container(width: 48, height: 48, color: Colors.white),
      Container(width: 200, height: 16, color: Colors.white),
      Container(width: 150, height: 14, color: Colors.white),
    ],
  ),
)

// After (auto_skeleton) — one line, auto-detected
AutoSkeleton(
  enabled: _isLoading,
  child: myActualWidget,  // your real widget, real data
)
```

### From `skeletonizer`

```dart
// Before (skeletonizer) — requires fake/mock data
Skeletonizer(
  enabled: _isLoading,
  child: ListTile(
    title: Text('Fake Name Here'),        // fake data!
    subtitle: Text('Fake email@test.com'), // fake data!
    leading: CircleAvatar(
      backgroundImage: NetworkImage('https://fake-url.com/img'), // fake!
    ),
  ),
)

// After (auto_skeleton) — zero fake data
AutoSkeleton(
  enabled: _isLoading,
  child: myActualWidget,  // same widget, real data, no mocks
)
```

**Key differences when migrating:**
- No fake data needed — use your actual widgets
- Colors are theme-aware by default (remove manual color setup)
- Use `.withSkeleton(loading: true)` for even cleaner syntax
- Use `AutoSkeletonBuilder` to eliminate `setState` + `_isLoading` boilerplate entirely

## Color Customization

### Layer 1: Theme-aware (zero config)

Colors are automatically derived from your app's `ColorScheme`. Just works in light and dark mode.

### Layer 2: Global override

Set colors once at the app root:

```dart
AutoSkeletonConfig(
  data: AutoSkeletonConfigData(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
  ),
  child: MaterialApp(...),
)
```

### Layer 3: Per-widget override

Override on a specific widget:

```dart
AutoSkeleton(
  enabled: _isLoading,
  effect: ShimmerEffect(baseColor: Colors.blue.shade200),
  child: myWidget,
)
```

## Effects

### Shimmer (Default)

```dart
AutoSkeleton(
  enabled: _isLoading,
  effect: ShimmerEffect(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    duration: Duration(milliseconds: 1500),
    direction: ShimmerDirection.ltr,
  ),
  child: MyWidget(),
)
```

### Pulse

A gentle breathing/fade animation:

```dart
AutoSkeleton(
  enabled: _isLoading,
  effect: PulseEffect(
    color: Colors.blue.shade100,
    duration: Duration(milliseconds: 1200),
  ),
  child: MyWidget(),
)
```

### Solid

Static placeholder with no animation:

```dart
AutoSkeleton(
  enabled: _isLoading,
  effect: SolidEffect(color: Colors.grey.shade200),
  child: MyWidget(),
)
```

## Annotations

Control how specific widgets are skeletonized:

### PlaceholderIgnore

Hide a widget completely during loading — useful for interactive elements (switches, buttons) that don't make sense in a skeleton:

```dart
AutoSkeleton(
  enabled: _isLoading,
  child: ListTile(
    title: Text('Notifications'),
    subtitle: Text('Push & email alerts'),
    trailing: PlaceholderIgnore(
      child: Switch(value: true, onChanged: (_) {}),
    ),
  ),
)
```

### PlaceholderLeaf

Mark complex widgets (charts, maps, custom painters) as a single solid bone instead of traversing their children:

```dart
PlaceholderLeaf(
  borderRadius: BorderRadius.circular(12),
  child: MyComplexChartWidget(),
)
```

### PlaceholderReplace

Replace a widget with a completely custom placeholder:

```dart
PlaceholderReplace(
  replacement: Container(
    width: 48, height: 48,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      shape: BoxShape.circle,
    ),
  ),
  child: CircleAvatar(
    backgroundImage: NetworkImage(user.avatarUrl),
  ),
)
```

## Pre-built Presets

Ready-to-use skeleton patterns for common UI layouts:

```dart
// List with avatar, title, subtitle
SkeletonPresets.listTile(itemCount: 5)

// E-commerce product card
SkeletonPresets.productCard(width: 160.0)

// Food delivery restaurant card
SkeletonPresets.foodCard()

// Horizontal scrollable card row
SkeletonPresets.horizontalCardRow(itemCount: 4)
```

## Global Configuration

Set defaults for your entire app:

```dart
AutoSkeletonConfig(
  data: AutoSkeletonConfigData(
    baseColor: Color(0xFFE8E8E8),
    highlightColor: Color(0xFFF8F8F8),
    textBorderRadius: 4.0,
    containerBorderRadius: 8.0,
    enableSwitchAnimation: true,
  ),
  child: MaterialApp(...),
)
```

## App-Level Wrapper (Zero Per-Widget Wrapping)

Wrap your entire app — every screen gets skeleton automatically:

```dart
final skeletonController = AutoSkeletonAppController();

MaterialApp(
  builder: AutoSkeletonApp.builder(
    controller: skeletonController,
  ),
  navigatorObservers: [skeletonController.observer],
  home: MyHomePage(),
)
```

Control it programmatically:

```dart
// Show skeleton
skeletonController.startLoading();

// Hide skeleton, show content
skeletonController.stopLoading();

// Toggle
skeletonController.toggle();
```

Or use a simple `ValueNotifier`:

```dart
final isLoading = ValueNotifier(true);

MaterialApp(
  builder: AutoSkeletonApp.builder(loadingNotifier: isLoading),
  home: MyHomePage(),
)

// Later...
isLoading.value = false; // skeleton disappears
```

## Sliver Support

For use inside `CustomScrollView`:

```dart
CustomScrollView(
  slivers: [
    SliverAutoSkeleton(
      enabled: _isLoading,
      child: MyListContent(),
    ),
  ],
)
```

## How It Works

1. **Layout Phase**: The child widget tree is built and laid out (invisibly on the first frame).
2. **Scan Phase**: `WidgetTreeScanner` walks the element tree and identifies content widgets.
3. **Bone Generation**: For each content widget, a `BoneRect` is created matching its position and size.
4. **Paint Phase**: `BonePainter` renders the chosen effect over each bone rectangle.
5. **Transition**: When loading completes, the skeleton fades out and real content fades in.

## Supported Widgets

The scanner automatically detects and creates bones for:

- `Text` & `RichText` (with multi-line support)
- `Image`, `Icon`, `CircleAvatar`
- `ElevatedButton`, `TextButton`, `OutlinedButton`, `IconButton`
- `FloatingActionButton`
- `Switch`, `Checkbox`, `Radio`, `Chip`

Containers (`Card`, `Container`, `Padding`, etc.) are traversed to find their content children.

## Example

Check the [example](example/) directory for a complete demo app showing all features.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

```
BSD 3-Clause License
Copyright (c) 2026, Vaibhav Tambe
```
