import 'package:flutter/material.dart';

/// Annotation widget to control how a child is skeletonized.
///
/// Wrap any widget with [Placeholder] annotations to customize
/// placeholder behavior for specific parts of your widget tree.

/// Marks a widget to be completely hidden during placeholder state.
/// The widget will not appear at all when loading.
class PlaceholderIgnore extends StatelessWidget {
  final Widget child;

  const PlaceholderIgnore({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

/// Replaces the child widget with a custom placeholder widget.
///
/// ```dart
/// PlaceholderReplace(
///   replacement: Container(width: 48, height: 48, color: Colors.grey),
///   child: CircleAvatar(backgroundImage: NetworkImage(url)),
/// )
/// ```
class PlaceholderReplace extends StatelessWidget {
  final Widget child;
  final Widget replacement;
  final double? width;
  final double? height;

  const PlaceholderReplace({
    super.key,
    required this.child,
    required this.replacement,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) => child;
}

/// Marks a widget as a "leaf" bone — it gets painted as a solid
/// placeholder rectangle instead of traversing its children.
///
/// Useful for complex widgets like charts, maps, or custom painters.
class PlaceholderLeaf extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const PlaceholderLeaf({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) => child;
}

/// Forces a specific shape for the placeholder bone.
///
/// By default, text becomes rounded rectangles and images become
/// squares/circles based on their aspect ratio. Use this to override.
class PlaceholderShape extends StatelessWidget {
  final Widget child;
  final BoxShape shape;
  final BorderRadius? borderRadius;

  const PlaceholderShape({
    super.key,
    required this.child,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) => child;
}
