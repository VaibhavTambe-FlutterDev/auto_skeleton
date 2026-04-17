import 'package:flutter/material.dart';
import 'bone_painter.dart';
import 'annotations/placeholder_annotations.dart';

/// Scans the render tree after layout to extract bone rectangles
/// for each "content" widget (Text, Image, Icon, etc.).
///
/// Handles scrollable widgets (ListView, GridView, CustomScrollView)
/// by detecting viewport boundaries and only generating bones for
/// visible children.
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

    // Get the visible bounds of the root widget for clipping.
    final rootSize = rootRenderBox.size;
    final visibleBounds = Rect.fromLTWH(0, 0, rootSize.width, rootSize.height);

    _visitElement(context as Element, rootRenderBox, bones, visibleBounds);
    return bones;
  }

  void _visitElement(
    Element element,
    RenderBox rootRenderBox,
    List<BoneRect> bones,
    Rect visibleBounds,
  ) {
    final widget = element.widget;

    // Skip ignored widgets entirely.
    if (widget is PlaceholderIgnore) return;

    // Handle replacement annotations.
    if (widget is PlaceholderReplace) {
      _addBoneFromElement(
        element: element,
        rootRenderBox: rootRenderBox,
        bones: bones,
        visibleBounds: visibleBounds,
        width: widget.width,
        height: widget.height,
        borderRadius: containerBorderRadius,
        type: BoneType.generic,
      );
      return;
    }

    // Handle leaf annotations.
    if (widget is PlaceholderLeaf) {
      _addBoneFromElement(
        element: element,
        rootRenderBox: rootRenderBox,
        bones: bones,
        visibleBounds: visibleBounds,
        width: widget.width,
        height: widget.height,
        borderRadius: widget.borderRadius?.topLeft.x ?? containerBorderRadius,
        type: BoneType.generic,
      );
      return;
    }

    // Detect content widgets and create bones.
    if (_isContentWidget(widget)) {
      final renderObject = element.findRenderObject();
      if (renderObject == null) return;

      // Get the actual RenderBox — may need to traverse for slivers.
      final renderBox = _findRenderBox(renderObject);
      if (renderBox == null || !renderBox.hasSize) return;

      final offset = _safeLocalToGlobal(renderBox, rootRenderBox);
      if (offset == null) return;

      final size = renderBox.size;
      final boneRect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);

      // Skip bones outside visible bounds.
      if (!visibleBounds.overlaps(boneRect)) return;

      // Clip bones to visible bounds.
      final clippedRect = boneRect.intersect(visibleBounds);

      final boneType = _getBoneType(widget);
      final borderRadius = _getBorderRadius(widget, boneType);

      if (boneType == BoneType.text && widget is Text) {
        final textBones = _generateTextBones(
          offset: Offset(clippedRect.left, clippedRect.top),
          availableWidth: clippedRect.width,
          widget: widget,
          visibleBounds: visibleBounds,
        );
        bones.addAll(textBones);
      } else {
        bones.add(BoneRect(
          rect: clippedRect,
          borderRadius: borderRadius,
          type: boneType,
        ));
      }
      return;
    }

    // For scrollable widgets, handle their children specially.
    if (_isScrollableWidget(widget)) {
      _visitScrollableChildren(element, rootRenderBox, bones, visibleBounds);
      return;
    }

    // Recurse into children.
    element.visitChildren((child) {
      _visitElement(child, rootRenderBox, bones, visibleBounds);
    });
  }

  /// Handles scanning children of scrollable widgets (ListView, GridView, etc.).
  /// These use RenderSliver internally, so we need to handle coordinate
  /// transforms differently.
  void _visitScrollableChildren(
    Element element,
    RenderBox rootRenderBox,
    List<BoneRect> bones,
    Rect visibleBounds,
  ) {
    // Traverse into the scrollable's children normally.
    // The key fix: we use _safeLocalToGlobal which handles the
    // sliver → box coordinate transform correctly.
    element.visitChildren((child) {
      _visitElement(child, rootRenderBox, bones, visibleBounds);
    });
  }

  /// Safely converts local coordinates to global, handling cases where
  /// the render object is inside a sliver (ListView, GridView, etc.).
  Offset? _safeLocalToGlobal(RenderBox renderBox, RenderBox ancestor) {
    try {
      // Check if the render box is attached to the render tree.
      if (!renderBox.attached) return null;

      final offset = renderBox.localToGlobal(Offset.zero, ancestor: ancestor);

      // Sanity check — reject extreme values that indicate broken transforms.
      if (offset.dx.isNaN || offset.dy.isNaN ||
          offset.dx.isInfinite || offset.dy.isInfinite ||
          offset.dx.abs() > 100000 || offset.dy.abs() > 100000) {
        return null;
      }

      return offset;
    } catch (_) {
      // localToGlobal can throw if the render objects are not in the same tree,
      // or if the ancestor relationship is broken (common with slivers).
      return null;
    }
  }

  /// Finds the nearest RenderBox from a RenderObject,
  /// traversing through RenderSliver wrappers if needed.
  RenderBox? _findRenderBox(RenderObject renderObject) {
    if (renderObject is RenderBox) return renderObject;

    // For sliver children, the actual RenderBox is the child of the sliver.
    RenderBox? result;
    renderObject.visitChildren((child) {
      if (result != null) return;
      if (child is RenderBox) {
        result = child;
      } else {
        result = _findRenderBox(child);
      }
    });
    return result;
  }

  /// Helper to add a bone from an element with proper bounds checking.
  void _addBoneFromElement({
    required Element element,
    required RenderBox rootRenderBox,
    required List<BoneRect> bones,
    required Rect visibleBounds,
    double? width,
    double? height,
    required double borderRadius,
    required BoneType type,
  }) {
    final renderObject = element.findRenderObject();
    if (renderObject == null) return;

    final renderBox = _findRenderBox(renderObject);
    if (renderBox == null || !renderBox.hasSize) return;

    final offset = _safeLocalToGlobal(renderBox, rootRenderBox);
    if (offset == null) return;

    final boneRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      width ?? renderBox.size.width,
      height ?? renderBox.size.height,
    );

    if (!visibleBounds.overlaps(boneRect)) return;

    bones.add(BoneRect(
      rect: boneRect.intersect(visibleBounds),
      borderRadius: borderRadius,
      type: type,
    ));
  }

  /// Generate placeholder bones for text content, simulating
  /// multi-line text layout.
  List<BoneRect> _generateTextBones({
    required Offset offset,
    required double availableWidth,
    required Text widget,
    required Rect visibleBounds,
  }) {
    final bones = <BoneRect>[];
    final text = widget.data ?? '';
    final fontSize = widget.style?.fontSize ?? defaultTextBoneHeight;
    final maxLines = widget.maxLines ?? _estimateLineCount(text, availableWidth, fontSize);

    for (int i = 0; i < maxLines; i++) {
      final isLastLine = i == maxLines - 1;
      final lineWidth = (isLastLine && justifyMultiLineText && maxLines > 1)
          ? availableWidth * 0.7
          : availableWidth;

      final lineRect = Rect.fromLTWH(
        offset.dx,
        offset.dy + (fontSize + textBoneSpacing) * i,
        lineWidth,
        fontSize,
      );

      // Skip text lines outside visible bounds.
      if (!visibleBounds.overlaps(lineRect)) continue;

      bones.add(BoneRect(
        rect: lineRect.intersect(visibleBounds),
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

  bool _isScrollableWidget(Widget widget) {
    return widget is ListView ||
        widget is GridView ||
        widget is CustomScrollView ||
        widget is SingleChildScrollView ||
        widget is NestedScrollView;
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
        widget is IconButton) {
      return BoneType.button;
    }
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
