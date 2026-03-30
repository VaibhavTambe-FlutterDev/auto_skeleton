# auto_skeleton

[![pub package](https://img.shields.io/pub/v/auto_skeleton.svg)](https://pub.dev/packages/auto_skeleton)
[![License: BSD-3](https://img.shields.io/badge/license-BSD--3-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

Auto-generate skeleton/shimmer loading screens from your **actual widget tree**. No fake data needed — just wrap your widget and get a matching placeholder shape automatically.

## Screenshots

| Skeleton (Loading) | Loaded (Content) |
|:---:|:---:|
| <img src="https://raw.githubusercontent.com/VaibhavTambe-FlutterDev/auto_skeleton/main/screenshots/02_skeleton_top.png" width="280"/> | <img src="https://raw.githubusercontent.com/VaibhavTambe-FlutterDev/auto_skeleton/main/screenshots/01_loaded_top.png" width="280"/> |
| <img src="https://raw.githubusercontent.com/VaibhavTambe-FlutterDev/auto_skeleton/main/screenshots/03_skeleton_bottom.png" width="280"/> | <img src="https://raw.githubusercontent.com/VaibhavTambe-FlutterDev/auto_skeleton/main/screenshots/04_loaded_bottom.png" width="280"/> |

| Annotations (Skeleton) |
|:---:|
| <img src="https://raw.githubusercontent.com/VaibhavTambe-FlutterDev/auto_skeleton/main/screenshots/05_skeleton_annotations.png" width="280"/> |

> Toggle button switches between skeleton and real content. Annotations let you control which widgets get skeleton bones — `PlaceholderIgnore` hides the switches, `PlaceholderLeaf` treats icon boxes as solid bones.

## Why auto_skeleton?

Building skeleton loading UIs manually is tedious and goes out of sync with your real layouts. `auto_skeleton` solves this by **introspecting your widget tree** at render time and generating matching bone shapes for every content widget (Text, Image, Icon, Button, etc.).

### Key Differences from Other Packages

| Feature | auto_skeleton | skeletonizer | shimmer |
|---|---|---|---|
| Auto-detect widget shapes | ✅ | ✅ | ❌ |
| Zero fake data needed | ✅ | ❌ (needs mock data) | ❌ |
| Theme-aware colors | ✅ | ❌ | ❌ |
| Extension syntax `.withSkeleton()` | ✅ | ❌ | ❌ |
| Pre-built presets (food card, product card) | ✅ | ❌ | ❌ |
| Multiple effects (shimmer, pulse, solid) | ✅ | ✅ | Shimmer only |
| Annotation system | ✅ | ✅ | ❌ |
| Switch animation | ✅ | ✅ | ❌ |
| Dark mode auto-detection | ✅ | ✅ | ❌ |

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  auto_skeleton: ^0.1.0
```

Then run:

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
    minOpacity: 0.4,
    maxOpacity: 1.0,
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

Control how specific widgets are skeletonized using annotation wrappers:

### PlaceholderIgnore

Hide a widget completely during loading:

```dart
AutoSkeleton(
  enabled: _isLoading,
  child: Column(
    children: [
      Text('This gets a skeleton bone'),
      PlaceholderIgnore(
        child: Text('This is hidden during loading'),
      ),
    ],
  ),
)
```

### PlaceholderLeaf

Mark complex widgets (charts, maps, custom painters) as a single bone instead of traversing their children:

```dart
PlaceholderLeaf(
  borderRadius: BorderRadius.circular(12),
  child: MyComplexChartWidget(),
)
```

### PlaceholderReplace

Replace a widget with a custom placeholder:

```dart
PlaceholderReplace(
  replacement: Container(
    width: 48,
    height: 48,
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

### List Tile

```dart
SkeletonPresets.listTile(
  itemCount: 5,
  itemHeight: 72.0,
)
```

### Product Card (E-commerce)

```dart
SkeletonPresets.productCard(
  width: 160.0,
  imageHeight: 160.0,
)
```

### Food Card (Delivery Apps)

```dart
SkeletonPresets.foodCard()
```

### Horizontal Card Row

```dart
SkeletonPresets.horizontalCardRow(
  itemCount: 4,
  cardWidth: 140.0,
  cardHeight: 180.0,
)
```

## Global Configuration

Set defaults for your entire app using `AutoSkeletonConfig`:

```dart
AutoSkeletonConfig(
  data: AutoSkeletonConfigData(
    baseColor: Color(0xFFE8E8E8),
    highlightColor: Color(0xFFF8F8F8),
    textBorderRadius: 4.0,
    containerBorderRadius: 8.0,
    enableSwitchAnimation: true,
    switchAnimationDuration: Duration(milliseconds: 300),
    switchAnimationCurve: Curves.easeInOut,
    justifyMultiLineText: true,
  ),
  child: MaterialApp(...),
)
```

## Switch Animation

Smoothly transition from skeleton to content:

```dart
AutoSkeleton(
  enabled: _isLoading,
  enableSwitchAnimation: true,
  switchAnimationDuration: Duration(milliseconds: 500),
  switchAnimationCurve: Curves.easeOut,
  child: MyWidget(),
)
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
2. **Scan Phase**: After layout, `WidgetTreeScanner` walks the element tree and identifies content widgets (Text, Image, Icon, Button, etc.).
3. **Bone Generation**: For each content widget, a `BoneRect` is created matching its position and size in the layout.
4. **Paint Phase**: `BonePainter` renders the chosen effect (shimmer/pulse/solid) over each bone rectangle.
5. **Transition**: When loading completes, the skeleton fades out and real content fades in.

## Supported Widgets

The scanner automatically detects and creates bones for:

- `Text` & `RichText` (with multi-line support)
- `Image`
- `Icon`
- `CircleAvatar`
- `ElevatedButton`, `TextButton`, `OutlinedButton`, `IconButton`
- `FloatingActionButton`
- `Switch`, `Checkbox`, `Radio`
- `Chip`

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
