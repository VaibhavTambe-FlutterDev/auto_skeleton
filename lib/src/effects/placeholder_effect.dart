import 'package:flutter/material.dart';

/// Base class for all placeholder painting effects.
abstract class PlaceholderEffect {
  const PlaceholderEffect();

  /// Creates the animation controller for this effect.
  AnimationController createController(TickerProvider vsync);

  /// Paints the effect onto the given canvas area.
  void paint(Canvas canvas, Rect rect, Animation<double> animation);

  /// Returns a copy of this effect with theme-derived colors applied,
  /// only where the user hasn't explicitly set colors.
  PlaceholderEffect resolveWithTheme(ColorScheme colorScheme) => this;

  /// Flat fallback color used to paint a solid block before the first
  /// scan completes (prevents invisible-flash on first frame).
  Color fallbackColor(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return isDark ? const Color(0xFF2A2A2A) : colorScheme.surfaceContainerHighest;
  }
}

/// A shimmer effect that sweeps a highlight gradient across placeholder bones.
class ShimmerEffect extends PlaceholderEffect {
  /// Base color of the shimmer. If null, derived from the app's [ColorScheme].
  final Color? baseColor;

  /// Highlight color of the shimmer sweep. If null, derived from the app's [ColorScheme].
  final Color? highlightColor;

  final Duration duration;
  final ShimmerDirection direction;

  const ShimmerEffect({
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
  });

  @override
  PlaceholderEffect resolveWithTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return _ResolvedShimmerEffect(
      baseColor: baseColor ??
          (isDark ? const Color(0xFF2A2A2A) : colorScheme.surfaceContainerHighest),
      highlightColor: highlightColor ??
          (isDark ? const Color(0xFF3D3D3D) : colorScheme.surface),
      duration: duration,
      direction: direction,
    );
  }

  @override
  AnimationController createController(TickerProvider vsync) {
    return AnimationController(vsync: vsync, duration: duration)..repeat();
  }

  @override
  void paint(Canvas canvas, Rect rect, Animation<double> animation) {
    // Fallback colors when used without theme resolution.
    final base = baseColor ?? const Color(0xFFE0E0E0);
    final highlight = highlightColor ?? const Color(0xFFF5F5F5);
    _paintShimmer(canvas, rect, animation, base, highlight, direction);
  }
}

/// Internal resolved shimmer with concrete colors (after theme resolution).
class _ResolvedShimmerEffect extends PlaceholderEffect {
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  final ShimmerDirection direction;

  const _ResolvedShimmerEffect({
    required this.baseColor,
    required this.highlightColor,
    required this.duration,
    required this.direction,
  });

  @override
  AnimationController createController(TickerProvider vsync) {
    return AnimationController(vsync: vsync, duration: duration)..repeat();
  }

  @override
  void paint(Canvas canvas, Rect rect, Animation<double> animation) {
    _paintShimmer(canvas, rect, animation, baseColor, highlightColor, direction);
  }

  @override
  Color fallbackColor(ColorScheme colorScheme) => baseColor;
}

/// Shared shimmer painting logic.
void _paintShimmer(
  Canvas canvas,
  Rect rect,
  Animation<double> animation,
  Color baseColor,
  Color highlightColor,
  ShimmerDirection direction,
) {
  final paint = Paint();
  final double shimmerPosition = animation.value;

  final Alignment begin;
  final Alignment end;

  switch (direction) {
    case ShimmerDirection.ltr:
      begin = Alignment(-1.0 + 2.0 * shimmerPosition, 0.0);
      end = Alignment(1.0 + 2.0 * shimmerPosition, 0.0);
      break;
    case ShimmerDirection.rtl:
      begin = Alignment(1.0 - 2.0 * shimmerPosition, 0.0);
      end = Alignment(-1.0 - 2.0 * shimmerPosition, 0.0);
      break;
    case ShimmerDirection.ttb:
      begin = Alignment(0.0, -1.0 + 2.0 * shimmerPosition);
      end = Alignment(0.0, 1.0 + 2.0 * shimmerPosition);
      break;
    case ShimmerDirection.btt:
      begin = Alignment(0.0, 1.0 - 2.0 * shimmerPosition);
      end = Alignment(0.0, -1.0 - 2.0 * shimmerPosition);
      break;
  }

  final gradient = LinearGradient(
    begin: begin,
    end: end,
    colors: [baseColor, highlightColor, baseColor],
    stops: const [0.0, 0.5, 1.0],
  );

  paint.shader = gradient.createShader(rect);
  canvas.drawRect(rect, paint);
}

/// A pulse/fade effect that breathes the placeholder opacity.
class PulseEffect extends PlaceholderEffect {
  /// The pulse color. If null, derived from the app's [ColorScheme].
  final Color? color;

  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  const PulseEffect({
    this.color,
    this.duration = const Duration(milliseconds: 1200),
    this.minOpacity = 0.4,
    this.maxOpacity = 1.0,
  });

  @override
  PlaceholderEffect resolveWithTheme(ColorScheme colorScheme) {
    if (color != null) return this;
    final isDark = colorScheme.brightness == Brightness.dark;
    return PulseEffect(
      color: isDark ? const Color(0xFF2A2A2A) : colorScheme.surfaceContainerHighest,
      duration: duration,
      minOpacity: minOpacity,
      maxOpacity: maxOpacity,
    );
  }

  @override
  AnimationController createController(TickerProvider vsync) {
    return AnimationController(vsync: vsync, duration: duration)
      ..repeat(reverse: true);
  }

  @override
  void paint(Canvas canvas, Rect rect, Animation<double> animation) {
    final resolvedColor = color ?? const Color(0xFFE0E0E0);
    final double opacity =
        minOpacity + (maxOpacity - minOpacity) * animation.value;
    final paint = Paint()..color = resolvedColor.withValues(alpha: opacity);
    canvas.drawRect(rect, paint);
  }
}

/// A solid static color effect (no animation).
class SolidEffect extends PlaceholderEffect {
  /// The solid color. If null, derived from the app's [ColorScheme].
  final Color? color;

  const SolidEffect({
    this.color,
  });

  @override
  PlaceholderEffect resolveWithTheme(ColorScheme colorScheme) {
    if (color != null) return this;
    final isDark = colorScheme.brightness == Brightness.dark;
    return SolidEffect(
      color: isDark ? const Color(0xFF2A2A2A) : colorScheme.surfaceContainerHighest,
    );
  }

  @override
  AnimationController createController(TickerProvider vsync) {
    // No animation needed — return a stopped controller.
    return AnimationController(
      vsync: vsync,
      duration: Duration.zero,
    )..value = 1.0;
  }

  @override
  void paint(Canvas canvas, Rect rect, Animation<double> animation) {
    final paint = Paint()..color = color ?? const Color(0xFFE0E0E0);
    canvas.drawRect(rect, paint);
  }
}

/// Direction of the shimmer sweep.
enum ShimmerDirection { ltr, rtl, ttb, btt }
