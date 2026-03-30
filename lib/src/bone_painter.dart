import 'package:flutter/material.dart';
import 'effects/placeholder_effect.dart';

/// Custom painter that renders the shimmer/pulse effect over bone rectangles.
class BonePainter extends CustomPainter {
  final List<BoneRect> bones;
  final PlaceholderEffect effect;
  final Animation<double> animation;

  BonePainter({
    required this.bones,
    required this.effect,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (final bone in bones) {
      canvas.save();

      final rrect = RRect.fromRectAndRadius(
        bone.rect,
        Radius.circular(bone.borderRadius),
      );
      canvas.clipRRect(rrect);
      effect.paint(canvas, bone.rect, animation);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(BonePainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.bones != bones;
  }
}

/// Represents a single placeholder bone rectangle.
class BoneRect {
  final Rect rect;
  final double borderRadius;
  final BoneType type;

  const BoneRect({
    required this.rect,
    this.borderRadius = 4.0,
    this.type = BoneType.generic,
  });
}

/// The type of content this bone represents.
enum BoneType {
  text,
  image,
  icon,
  container,
  button,
  generic,
}
