import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'bone_painter.dart';
import 'effects/placeholder_effect.dart';
import 'smart_placeholder_config.dart';
import 'widget_tree_scanner.dart';

/// Cached bone data with size + theme fingerprint for invalidation.
/// Held per-state (not globally) — disposed widgets release their cache.
class _CachedBones {
  final List<BoneRect> bones;
  final Size size;
  final Brightness themeBrightness;

  const _CachedBones({
    required this.bones,
    required this.size,
    required this.themeBrightness,
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
/// ## List Skeleton (no fake data needed)
///
/// ```dart
/// AutoSkeleton(
///   enabled: _isLoading,
///   skeletonItem: MyListItemWidget(),
///   skeletonItemCount: 5,
///   child: ListView.builder(
///     itemCount: items.length,
///     itemBuilder: (_, i) => MyListItemWidget(data: items[i]),
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

  /// Template widget to repeat as skeleton rows while loading.
  ///
  /// When provided along with [skeletonItemCount], the skeleton is generated
  /// from [skeletonItemCount] copies of this widget — not from [child].
  /// This solves the "nothing to scan" problem for lists: real data isn't
  /// needed during loading.
  ///
  /// ```dart
  /// AutoSkeleton(
  ///   enabled: _isLoading,
  ///   skeletonItem: MyListTile(),
  ///   skeletonItemCount: 6,
  ///   child: realListView,
  /// )
  /// ```
  final Widget? skeletonItem;

  /// Number of [skeletonItem] rows to render as the skeleton.
  /// Defaults to 5 when [skeletonItem] is set.
  final int skeletonItemCount;

  /// When true, the skeleton column is wrapped in a [SingleChildScrollView].
  /// Useful when [skeletonItemCount] items exceed the available height.
  /// Defaults to false (items are clipped to available space).
  final bool skeletonScrollable;

  /// When true (debug only), overlays each detected bone with a red outline
  /// and type label. Useful for diagnosing "blank skeleton" problems —
  /// if no outlines appear, the scanner didn't find any leaves to replace.
  final bool debugShowBones;

  const AutoSkeleton({
    super.key,
    required this.enabled,
    required this.child,
    this.effect,
    this.enableSwitchAnimation,
    this.switchAnimationDuration,
    this.switchAnimationCurve,
    this.skeletonItem,
    this.skeletonItemCount = 5,
    this.skeletonScrollable = false,
    this.debugShowBones = false,
  });

  /// No-op. Kept for API compatibility; each [AutoSkeleton] now owns its
  /// own cache which is released when the widget is disposed. Theme
  /// changes and content changes invalidate automatically.
  @Deprecated('Cache is now per-widget and auto-invalidates. Safe to remove.')
  static void clearCache() {}

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
  // Separate key for the off-screen skeleton-item column.
  final GlobalKey _skeletonColumnKey = GlobalKey();
  // Per-state cache — disposed with the widget, no manual cleanup.
  _CachedBones? _cache;
  Brightness? _lastBrightness;

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
    // Invalidate cache and effect on theme brightness change
    // (light↔dark would otherwise keep stale colors).
    final brightness = Theme.of(context).colorScheme.brightness;
    if (_lastBrightness != null && _lastBrightness != brightness) {
      _cache = null;
      _initEffectController();
      if (widget.enabled) {
        _hasScanned = false;
        _bones = [];
        _scheduleRescan();
      }
    }
    _lastBrightness = brightness;
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

    // Invalidate scan + cache if template or child reference changes.
    final childChanged =
        !identical(oldWidget.child, widget.child) ||
            oldWidget.skeletonItem != widget.skeletonItem ||
            oldWidget.skeletonItemCount != widget.skeletonItemCount;
    if (childChanged) {
      _cache = null;
      if (widget.enabled) {
        _hasScanned = false;
        _bones = [];
        _scheduleRescan();
      }
    }
  }

  void _scheduleRescan() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.enabled) return;
      _scanTree();
    });
  }

  void _scanTree() {
    // When skeletonItem is provided, scan the off-screen column, not child.
    final scanKey =
        widget.skeletonItem != null ? _skeletonColumnKey : _childKey;
    final scanContext = scanKey.currentContext;
    if (scanContext == null) return;

    final renderBox = scanContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final currentSize = renderBox.size;
    final brightness = Theme.of(context).colorScheme.brightness;

    // Per-state cache: hit when size + theme match.
    final cached = _cache;
    if (cached != null &&
        cached.size == currentSize &&
        cached.themeBrightness == brightness) {
      if (!_hasScanned) {
        setState(() {
          _bones = cached.bones;
          _hasScanned = true;
        });
      }
      return;
    }

    final scanner = WidgetTreeScanner(
      textBorderRadius: _config.textBorderRadius,
      containerBorderRadius: _config.containerBorderRadius,
      ignoreContainers: _config.ignoreContainers,
      defaultTextBoneHeight: _config.defaultTextBoneHeight,
      textBoneSpacing: _config.textBoneSpacing,
      justifyMultiLineText: _config.justifyMultiLineText,
    );

    final scannedBones = scanner.scan(scanContext);

    // Fail loud in debug mode: empty scan is almost always a mistake
    // (template made of Containers with no Text/Icon/Image leaves).
    assert(() {
      if (scannedBones.isEmpty) {
        final source = widget.skeletonItem != null ? 'skeletonItem' : 'child';
        debugPrint(
          '⚠️  AutoSkeleton: scan produced 0 bones from $source.\n'
          '   The template has no introspectable leaves (Text / Icon / Image / '
          'CircleAvatar / Button / etc.).\n'
          '   Fix: pass a real widget (ListTile, Card with Text inside), or '
          'wrap custom widgets with PlaceholderLeaf.\n'
          '   Set debugShowBones: true to visualize what the scanner found.',
        );
      }
      return true;
    }());

    _cache = _CachedBones(
      bones: scannedBones,
      size: currentSize,
      themeBrightness: brightness,
    );

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

  Widget _buildSkeletonColumn() {
    final items = List.generate(
      widget.skeletonItemCount,
      (_) => widget.skeletonItem!,
    );
    final column = KeyedSubtree(
      key: _skeletonColumnKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
    return widget.skeletonScrollable
        ? SingleChildScrollView(physics: const NeverScrollableScrollPhysics(), child: column)
        : ClipRect(child: column);
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

    // Skeleton column stays in the layout tree (opacity 0, not Offstage) so
    // the scanner can read real RenderBox sizes from it.
    final skeletonColumn = widget.skeletonItem != null
        ? Opacity(opacity: 0.0, child: _buildSkeletonColumn())
        : null;

    if (!_hasScanned) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.enabled) _scanTree();
      });

      // Paint a solid fallback on the pre-scan frame so the user never
      // sees empty/invisible content before bones appear.
      final fallback = _effect.fallbackColor(Theme.of(context).colorScheme);

      return Stack(
        children: [
          Opacity(opacity: 0.0, child: child),
          if (skeletonColumn != null) skeletonColumn,
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: fallback),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Opacity(opacity: 0.0, child: child),
        if (skeletonColumn != null) skeletonColumn,
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
        if (widget.debugShowBones)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DebugBonePainter(bones: _bones),
              ),
            ),
          ),
      ],
    );
  }
}

/// Debug painter: outlines each scanned bone in red with a type label.
/// Only used when [AutoSkeleton.debugShowBones] is true.
class _DebugBonePainter extends CustomPainter {
  final List<BoneRect> bones;

  _DebugBonePainter({required this.bones});

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = const Color(0xFFFF3366)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final bone in bones) {
      canvas.drawRect(bone.rect, outline);

      final label = bone.type.name;
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Color(0xFFFF3366),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(bone.rect.left + 2, bone.rect.top + 2),
      );
    }

    // Corner count badge.
    final badge = TextPainter(
      text: TextSpan(
        text: '${bones.length} bones',
        style: const TextStyle(
          color: Color(0xFFFF3366),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    badge.paint(canvas, const Offset(4, 4));
  }

  @override
  bool shouldRepaint(_DebugBonePainter old) => !identical(old.bones, bones);
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
