import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'bone_painter.dart';
import 'effects/placeholder_effect.dart';
import 'smart_placeholder_config.dart';
import 'widget_tree_scanner.dart';

/// Global bone cache to avoid redundant scanning.
/// Keyed by widget identity for reuse across rebuilds.
final _boneCache = <Key, _CachedBones>{};

/// Cached bone data with size fingerprint for invalidation.
class _CachedBones {
  final List<BoneRect> bones;
  final Size size;
  final int childHashCode;

  const _CachedBones({
    required this.bones,
    required this.size,
    required this.childHashCode,
  });
}

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

  /// Clears the global bone cache. Call this if you need to force
  /// a rescan of all skeleton layouts (e.g., after a theme change).
  static void clearCache() => _boneCache.clear();

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
      return widget.effect!.resolveWithTheme(Theme.of(context).colorScheme);
    }
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
      _switchController?.dispose();
      _switchController = AnimationController(
        vsync: this,
        duration: widget.switchAnimationDuration ??
            _config.switchAnimationDuration,
      )..forward();
    }

    if (!oldWidget.enabled && widget.enabled) {
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

    final renderBox = childContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final currentSize = renderBox.size;
    final childHash = widget.child.hashCode;

    // Check cache — reuse bones if size and child haven't changed.
    if (widget.key != null) {
      final cached = _boneCache[widget.key!];
      if (cached != null &&
          cached.size == currentSize &&
          cached.childHashCode == childHash) {
        setState(() {
          _bones = cached.bones;
          _hasScanned = true;
        });
        return;
      }
    }

    final scanner = WidgetTreeScanner(
      textBorderRadius: _config.textBorderRadius,
      containerBorderRadius: _config.containerBorderRadius,
      ignoreContainers: _config.ignoreContainers,
      defaultTextBoneHeight: _config.defaultTextBoneHeight,
      textBoneSpacing: _config.textBoneSpacing,
      justifyMultiLineText: _config.justifyMultiLineText,
    );

    final scannedBones = scanner.scan(childContext);

    // Cache the result if we have a key.
    if (widget.key != null) {
      _boneCache[widget.key!] = _CachedBones(
        bones: scannedBones,
        size: currentSize,
        childHashCode: childHash,
      );
    }

    setState(() {
      _bones = scannedBones;
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
    final child = KeyedSubtree(
      key: _childKey,
      child: widget.child,
    );

    if (!widget.enabled) {
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

    if (!_hasScanned) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.enabled) _scanTree();
      });

      return Opacity(
        opacity: 0.0,
        child: child,
      );
    }

    return Stack(
      children: [
        Opacity(opacity: 0.0, child: child),
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
