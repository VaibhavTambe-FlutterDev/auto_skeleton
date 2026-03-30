import 'package:flutter/material.dart';
import '../smart_placeholder.dart';
import '../effects/placeholder_effect.dart';

/// Extension on [Widget] for convenient skeleton wrapping.
///
/// ```dart
/// myWidget.withSkeleton(loading: _isLoading)
/// ```
extension AutoSkeletonExtension on Widget {
  /// Wraps this widget with an [AutoSkeleton].
  Widget withSkeleton({
    required bool loading,
    PlaceholderEffect? effect,
    bool? enableSwitchAnimation,
    Key? key,
  }) {
    return AutoSkeleton(
      key: key,
      enabled: loading,
      effect: effect,
      enableSwitchAnimation: enableSwitchAnimation,
      child: this,
    );
  }

  /// Alias for [withSkeleton] — wraps this widget with an [AutoSkeleton].
  Widget withPlaceholder({
    required bool loading,
    PlaceholderEffect? effect,
    bool? enableSwitchAnimation,
    Key? key,
  }) {
    return withSkeleton(
      loading: loading,
      effect: effect,
      enableSwitchAnimation: enableSwitchAnimation,
      key: key,
    );
  }
}
