/// Auto-generate skeleton/shimmer loading screens from your actual widget tree.
///
/// Just wrap your widget with [AutoSkeleton] and it creates a matching
/// placeholder shape automatically — no fake data needed.
///
/// ```dart
/// AutoSkeleton(
///   enabled: _isLoading,
///   child: MyActualWidget(),
/// )
/// ```
library auto_skeleton;

// Core widget
export 'src/smart_placeholder.dart';

// Builder (async data + auto skeleton)
export 'src/auto_skeleton_builder.dart';

// App-level wrapper
export 'src/auto_skeleton_app.dart';

// Configuration
export 'src/smart_placeholder_config.dart';

// Effects
export 'src/effects/placeholder_effect.dart';

// Annotations
export 'src/annotations/placeholder_annotations.dart';

// Bone painter (advanced usage)
export 'src/bone_painter.dart' show BoneRect, BoneType;

// Extensions
export 'src/extensions/widget_extensions.dart';

// Presets
export 'src/placeholder_presets.dart';
