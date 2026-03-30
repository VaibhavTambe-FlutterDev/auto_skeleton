import 'package:flutter/material.dart';
import 'effects/placeholder_effect.dart';

/// Global configuration for [AutoSkeleton] widgets.
///
/// Place this above your [MaterialApp] to set defaults for all
/// skeleton widgets in your app.
///
/// ```dart
/// AutoSkeletonConfig(
///   data: AutoSkeletonConfigData(
///     baseColor: Colors.grey.shade300,
///     highlightColor: Colors.grey.shade100,
///   ),
///   child: MaterialApp(...),
/// )
/// ```
class AutoSkeletonConfig extends InheritedWidget {
  final AutoSkeletonConfigData data;

  const AutoSkeletonConfig({
    super.key,
    required this.data,
    required super.child,
  });

  static AutoSkeletonConfigData? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AutoSkeletonConfig>()
        ?.data;
  }

  @override
  bool updateShouldNotify(AutoSkeletonConfig oldWidget) {
    return data != oldWidget.data;
  }
}

/// Configuration data for placeholder rendering.
class AutoSkeletonConfigData {
  /// The painting effect applied to placeholder bones.
  /// If not set, defaults to [ShimmerEffect].
  final PlaceholderEffect effect;

  /// Shorthand base color — applied to the default [ShimmerEffect].
  /// Ignored if a custom [effect] is provided.
  /// If null, colors are derived from the app's [ColorScheme] automatically.
  final Color? baseColor;

  /// Shorthand highlight color — applied to the default [ShimmerEffect].
  /// Ignored if a custom [effect] is provided.
  /// If null, colors are derived from the app's [ColorScheme] automatically.
  final Color? highlightColor;

  /// Border radius applied to text placeholder bones.
  final double textBorderRadius;

  /// Border radius applied to container placeholder bones.
  final double containerBorderRadius;

  /// Whether to ignore container background colors.
  final bool ignoreContainers;

  /// Duration of the switch animation (skeleton → content).
  final Duration switchAnimationDuration;

  /// Curve for the switch animation.
  final Curve switchAnimationCurve;

  /// Whether to enable the switch animation by default.
  final bool enableSwitchAnimation;

  /// Default text bone height when actual text metrics aren't available.
  final double defaultTextBoneHeight;

  /// Spacing between multi-line text bones.
  final double textBoneSpacing;

  /// Whether the last line of multi-line text should be shorter.
  final bool justifyMultiLineText;

  const AutoSkeletonConfigData({
    this.effect = const ShimmerEffect(),
    this.baseColor,
    this.highlightColor,
    this.textBorderRadius = 4.0,
    this.containerBorderRadius = 8.0,
    this.ignoreContainers = false,
    this.switchAnimationDuration = const Duration(milliseconds: 300),
    this.switchAnimationCurve = Curves.easeInOut,
    this.enableSwitchAnimation = true,
    this.defaultTextBoneHeight = 14.0,
    this.textBoneSpacing = 6.0,
    this.justifyMultiLineText = true,
  });

  /// Returns the resolved effect, applying [baseColor]/[highlightColor]
  /// shortcuts to the default ShimmerEffect if no custom effect was provided.
  PlaceholderEffect resolvedEffect(ColorScheme colorScheme) {
    // If user set baseColor/highlightColor shortcuts and is using the default effect,
    // create a ShimmerEffect with those colors.
    if (effect is ShimmerEffect) {
      final shimmer = effect as ShimmerEffect;
      // Apply config-level color overrides if the effect itself has no colors set.
      final merged = ShimmerEffect(
        baseColor: shimmer.baseColor ?? baseColor,
        highlightColor: shimmer.highlightColor ?? highlightColor,
        duration: shimmer.duration,
        direction: shimmer.direction,
      );
      return merged.resolveWithTheme(colorScheme);
    }
    return effect.resolveWithTheme(colorScheme);
  }
}
