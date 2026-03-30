import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'bone_painter.dart';
import 'effects/placeholder_effect.dart';
import 'smart_placeholder_config.dart';
import 'widget_tree_scanner.dart';

/// Wraps your actual widget tree and auto-generates a matching
/// skeleton/shimmer placeholder while [enabled] is true.
///
/// Unlike other skeleton packages, [AutoSkeleton] doesn't require
/// you to provide fake data — it introspects your widget tree's render
/// objects to create matching bone shapes.
///
/// ## Basic Usage
///
/// ```dart
/// AutoSkeleton(
///   enabled: _isLoading,
///   child: Card(
///     child: ListTile(
///       leading: CircleAvatar(child: Icon(Icons.person)),
///       title: Text('John Doe'),
///       subtitle: Text('Software Developer'),
///       trailing: Icon(Icons.chevron_right),
///     ),
///   ),
/// )
/// ```
///
/// ## Custom Effects
///
/// ```dart
/// AutoSkeleton(
///   enabled: _isLoading,
///   effect: PulseEffect(color: Colors.blue.shade100),
///   child: MyWidget(),
/// )
/// ```
class AutoSkeleton extends StatefulWidget {
  /// Whether the placeholder is active.
  final bool enabled;

  /// The actual content widget tree.
  final Widget child;

  /// Override the painting effect (shimmer, pulse, solid).
  /// Falls back to [AutoSkeletonConfig] or default [ShimmerEffect].
  final PlaceholderEffect? effect;

  /// Whether to animate the transition between skeleton and content.
  final bool? enableSwitchAnimation;

  /// Duration of the switch animation.
  final Duration? switchAnimationDuration;

  /// Curve of the switch animation.
  final Curve? switchAnimationCurve;

  const AutoSkeleton({
    super.key,
    required this.enabled,
    required this.child,
    this.effect,
    this.enableSwitchAnimation,
    this.switchAnimationDuration,
    this.switchAnimationCurve,
  });

  @override
  State<AutoSkeleton> createState() => _AutoSkeletonState();
}

class _AutoSkeletonState extends State<AutoSkeleton>
    with TickerProviderStateMixin {
  AnimationController? _effectController;
  AnimationController? _switchController;
  List<BoneRect> _bones = [];
  bool _hasScanned = false;
  final GlobalKey _childKey = GlobalKey();

  AutoSkeletonConfigData get _config {
    return AutoSkeletonConfig.of(context) ??
        const AutoSkeletonConfigData();
  }

  PlaceholderEffect get _effect {
    if (widget.effect != null) {
      // Per-widget override — still resolve with theme for null colors.
      return widget.effect!.resolveWithTheme(Theme.of(context).colorScheme);
    }
    // Use config's resolved effect (applies baseColor/highlightColor + theme).
    return _config.resolvedEffect(Theme.of(context).colorScheme);
  }

  bool get _enableSwitch =>
      widget.enableSwitchAnimation ?? _config.enableSwitchAnimation;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_effectController == null) {
      _initEffectController();
    }
  }

  void _initEffectController() {
    _effectController?.dispose();
    _effectController = _effect.createController(this);
  }

  @override
  void didUpdateWidget(AutoSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enabled && !widget.enabled && _enableSwitch) {
      // Transitioning from loading → content.
      _switchController?.dispose();
      _switchController = AnimationController(
        vsync: this,
        duration: widget.switchAnimationDuration ??
            _config.switchAnimationDuration,
      )..forward();
    }

    if (!oldWidget.enabled && widget.enabled) {
      // Transitioning from content → loading.
      _hasScanned = false;
      _bones = [];
      _initEffectController();
      _scheduleRescan();
    }
  }

  void _scheduleRescan() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.enabled) return;
      _scanTree();
    });
  }

  void _scanTree() {
    final childContext = _childKey.currentContext;
    if (childContext == null) return;

    final scanner = WidgetTreeScanner(
      textBorderRadius: _config.textBorderRadius,
      containerBorderRadius: _config.containerBorderRadius,
      ignoreContainers: _config.ignoreContainers,
      defaultTextBoneHeight: _config.defaultTextBoneHeight,
      textBoneSpacing: _config.textBoneSpacing,
      justifyMultiLineText: _config.justifyMultiLineText,
    );

    setState(() {
      _bones = scanner.scan(childContext);
      _hasScanned = true;
    });
  }

  @override
  void dispose() {
    _effectController?.dispose();
    _switchController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always build the child (needed for layout introspection).
    final child = KeyedSubtree(
      key: _childKey,
      child: widget.child,
    );

    if (!widget.enabled) {
      // Not loading — show content, optionally with fade-in.
      if (_switchController != null && _enableSwitch) {
        return AnimatedBuilder(
          animation: _switchController!,
          builder: (context, _) {
            final curve = widget.switchAnimationCurve ??
                _config.switchAnimationCurve;
            final value = curve.transform(_switchController!.value);
            return Opacity(opacity: value, child: child);
          },
        );
      }
      return child;
    }

    // Loading state — show skeleton overlay.
    if (!_hasScanned) {
      // First frame: build child invisibly to get layout, then scan.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.enabled) _scanTree();
      });

      return Opacity(
        opacity: 0.0,
        child: child,
      );
    }

    // We have bones — render the skeleton.
    return Stack(
      children: [
        // Keep child in tree (invisible) to maintain layout.
        Opacity(opacity: 0.0, child: child),
        // Overlay with skeleton.
        if (_effectController != null)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: BonePainter(
                  bones: _bones,
                  effect: _effect,
                  animation: _effectController!,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Variant for sliver widgets (CustomScrollView, etc.).
class SliverAutoSkeleton extends StatelessWidget {
  final bool enabled;
  final Widget child;
  final PlaceholderEffect? effect;

  const SliverAutoSkeleton({
    super.key,
    required this.enabled,
    required this.child,
    this.effect,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AutoSkeleton(
        enabled: enabled,
        effect: effect,
        child: child,
      ),
    );
  }
}
