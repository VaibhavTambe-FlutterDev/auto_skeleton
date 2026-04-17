import 'package:flutter/material.dart';
import 'smart_placeholder.dart';
import 'effects/placeholder_effect.dart';

/// Pre-built placeholder patterns for common UI layouts.
///
/// These are ready-to-use loading skeletons for popular card/list styles.
class SkeletonPresets {
  SkeletonPresets._();

  /// A list tile style placeholder (avatar + 2 text lines + trailing icon).
  static Widget listTile({
    bool enabled = true,
    PlaceholderEffect? effect,
    int itemCount = 5,
    double itemHeight = 72.0,
  }) {
    return AutoSkeleton(
      enabled: enabled,
      effect: effect,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return SizedBox(
            height: itemHeight,
            child: const ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, color: Colors.transparent),
              ),
              title: Text(
                'Placeholder title text here',
                style: TextStyle(color: Colors.transparent),
              ),
              subtitle: Text(
                'Subtitle text',
                style: TextStyle(color: Colors.transparent),
              ),
              trailing: Icon(Icons.chevron_right,
                  color: Colors.transparent),
            ),
          );
        },
      ),
    );
  }

  /// A product card placeholder (image top + title + price).
  /// Common in e-commerce apps.
  static Widget productCard({
    bool enabled = true,
    PlaceholderEffect? effect,
    double width = 160.0,
    double imageHeight = 160.0,
  }) {
    return AutoSkeleton(
      enabled: enabled,
      effect: effect,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: width,
              height: imageHeight,
              color: Colors.transparent,
            ),
            const SizedBox(height: 8),
            const Text(
              'Product name here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.transparent,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '₹999',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.transparent,
              ),
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.star, size: 14, color: Colors.transparent),
                SizedBox(width: 4),
                Text(
                  '4.5 (200)',
                  style: TextStyle(fontSize: 12, color: Colors.transparent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A food/restaurant card placeholder (horizontal card with image).
  /// Common in food delivery apps.
  static Widget foodCard({
    bool enabled = true,
    PlaceholderEffect? effect,
  }) {
    return AutoSkeleton(
      enabled: enabled,
      effect: effect,
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurant name here',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.transparent,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cuisine • 30 mins',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.transparent,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.transparent),
                        SizedBox(width: 4),
                        Text(
                          '4.2',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.transparent,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '₹300 for two',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A horizontal scrollable card row placeholder.
  static Widget horizontalCardRow({
    bool enabled = true,
    PlaceholderEffect? effect,
    int itemCount = 4,
    double cardWidth = 140.0,
    double cardHeight = 180.0,
  }) {
    return AutoSkeleton(
      enabled: enabled,
      effect: effect,
      child: SizedBox(
        height: cardHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return Container(
              width: cardWidth,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: cardHeight * 0.65,
                    width: cardWidth,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card title',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.transparent,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Backward-compatible alias.
typedef PlaceholderPresets = SkeletonPresets;
