import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'bone_painter.dart';
import 'annotations/placeholder_annotations.dart';

/// Scans the render tree after layout to extract bone rectangles
/// for each "content" widget (Text, Image, Icon, etc.).
class WidgetTreeScanner {
  final double textBorderRadius;
  final double containerBorderRadius;
  final bool ignoreContainers;
  final double defaultTextBoneHeight;
  final double textBoneSpacing;
  final bool justifyMultiLineText;

  const WidgetTreeScanner({
    this.textBorderRadius = 4.0,
    this.containerBorderRadius = 8.0,
    this.ignoreContainers = false,
    this.defaultTextBoneHeight = 14.0,
    this.textBoneSpacing = 6.0,
    this.justifyMultiLineText = true,
  });

  /// Scans the element tree rooted at [context] and returns
  /// a list of [BoneRect] representing placeholder bones.
  List<BoneRect> scan(BuildContext context) {
    final bones = <BoneRect>[];
    final rootRenderBox = context.findRenderObject() as RenderBox?;
    if (rootRenderBox == null) return bones;

    _visitElement(context as Element, rootRenderBox, bones);
    return bones;
  }

  void _visitElement(
    Element element,
    RenderBox rootRenderBox,
    List<BoneRect> bones,
  ) {
    final widget = element.widget;

    // Skip ignored widgets entirely.
    if (widget is PlaceholderIgnore) return;

    // Handle replacement annotations.
    if (widget is PlaceholderReplace) {
      final renderBox = element.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final offset = renderBox.localToGlobal(
          Offset.zero,
          ancestor: rootRenderBox,
        );
        bones.add(BoneRect(
          rect: Rect.fromLTWH(
            offset.dx,
            offset.dy,
            widget.width ?? renderBox.size.width,
            widget.height ?? renderBox.size.height,
          ),
          borderRadius: containerBorderRadius,
          type: BoneType.generic,
        ));
      }
      return; // Don't traverse children.
    }

    // Handle leaf annotations.
    if (widget is PlaceholderLeaf) {
      final renderBox = element.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final offset = renderBox.localToGlobal(
          Offset.zero,
          ancestor: rootRenderBox,
        );
        bones.add(BoneRect(
          rect: Rect.fromLTWH(
            offset.dx,
            offset.dy,
            widget.width ?? renderBox.size.width,
            widget.height ?? renderBox.size.height,
          ),
          borderRadius: widget.borderRadius?.topLeft.x ?? containerBorderRadius,
          type: BoneType.generic,
        ));
      }
      return; // Don't traverse children.
    }

    // Detect content widgets and create bones.
    if (_isContentWidget(widget)) {
      final renderBox = element.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final offset = renderBox.localToGlobal(
          Offset.zero,
          ancestor: rootRenderBox,
        );
        final size = renderBox.size;

        final boneType = _getBoneType(widget);
        final borderRadius = _getBorderRadius(widget, boneType);

        if (boneType == BoneType.text && widget is Text) {
          // Generate multi-line text bones.
          final textBones = _generateTextBones(
            offset: offset,
            availableWidth: size.width,
            widget: widget,
          );
          bones.addAll(textBones);
        } else {
          bones.add(BoneRect(
            rect: Rect.fromLTWH(
              offset.dx,
              offset.dy,
              size.width,
              size.height,
            ),
            borderRadius: borderRadius,
            type: boneType,
          ));
        }
      }
      return; // Content widgets are leaf nodes.
    }

    // Recurse into children.
    element.visitChildren((child) {
      _visitElement(child, rootRenderBox, bones);
    });
  }

  /// Generate placeholder bones for text content, simulating
  /// multi-line text layout.
  List<BoneRect> _generateTextBones({
    required Offset offset,
    required double availableWidth,
    required Text widget,
  }) {
    final bones = <BoneRect>[];
    final text = widget.data ?? '';
    final fontSize = widget.style?.fontSize ?? defaultTextBoneHeight;
    final maxLines = widget.maxLines ?? _estimateLineCount(text, availableWidth, fontSize);

    for (int i = 0; i < maxLines; i++) {
      final isLastLine = i == maxLines - 1;
      final lineWidth = (isLastLine && justifyMultiLineText && maxLines > 1)
          ? availableWidth * 0.7 // Last line is shorter
          : availableWidth;

      bones.add(BoneRect(
        rect: Rect.fromLTWH(
          offset.dx,
          offset.dy + (fontSize + textBoneSpacing) * i,
          lineWidth,
          fontSize,
        ),
        borderRadius: textBorderRadius,
        type: BoneType.text,
      ));
    }

    return bones;
  }

  int _estimateLineCount(String text, double width, double fontSize) {
    if (text.isEmpty) return 1;
    final charWidth = fontSize * 0.5;
    final charsPerLine = (width / charWidth).floor().clamp(1, 999);
    return (text.length / charsPerLine).ceil().clamp(1, 5);
  }

  bool _isContentWidget(Widget widget) {
    return widget is Text ||
        widget is RichText ||
        widget is Icon ||
        widget is Image ||
        widget is CircleAvatar ||
        widget is Switch ||
        widget is Checkbox ||
        widget is Radio ||
        widget is Chip ||
        widget is ElevatedButton ||
        widget is TextButton ||
        widget is OutlinedButton ||
        widget is IconButton ||
        widget is FloatingActionButton;
  }

  BoneType _getBoneType(Widget widget) {
    if (widget is Text || widget is RichText) return BoneType.text;
    if (widget is Image) return BoneType.image;
    if (widget is Icon) return BoneType.icon;
    if (widget is ElevatedButton ||
        widget is TextButton ||
        widget is OutlinedButton ||
        widget is IconButton) return BoneType.button;
    return BoneType.generic;
  }

  double _getBorderRadius(Widget widget, BoneType type) {
    switch (type) {
      case BoneType.text:
        return textBorderRadius;
      case BoneType.icon:
        return textBorderRadius;
      case BoneType.image:
        if (widget is CircleAvatar) return 100.0;
        return containerBorderRadius;
      case BoneType.button:
        return 20.0;
      case BoneType.container:
        return containerBorderRadius;
      case BoneType.generic:
        return containerBorderRadius;
    }
  }
}
