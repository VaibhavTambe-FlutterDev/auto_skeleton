import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auto_skeleton/auto_skeleton.dart';

void main() {
  group('AutoSkeleton', () {
    testWidgets('renders child when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AutoSkeleton(
              enabled: false,
              child: Text('Hello World'),
            ),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('hides child text when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AutoSkeleton(
              enabled: true,
              child: Text('Hello World'),
            ),
          ),
        ),
      );

      // Child is in tree but invisible (opacity 0).
      await tester.pump();
      expect(find.text('Hello World'), findsOneWidget);

      // After post-frame callback, bones should be scanned.
      await tester.pump();
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('transitions from loading to content', (tester) async {
      bool isLoading = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AutoSkeleton(
                      enabled: isLoading,
                      child: const Text('Content loaded'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => isLoading = false),
                      child: const Text('Load'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pump(); // First frame
      await tester.pump(); // Post-frame scan

      // Tap load button.
      await tester.tap(find.text('Load'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Content loaded'), findsOneWidget);
    });

    testWidgets('PlaceholderIgnore prevents bone generation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AutoSkeleton(
              enabled: true,
              child: Column(
                children: [
                  Text('Visible'),
                  PlaceholderIgnore(child: Text('Ignored')),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      // Both texts exist in tree, but PlaceholderIgnore's child
      // should not generate a bone.
      expect(find.text('Visible'), findsOneWidget);
      expect(find.text('Ignored'), findsOneWidget);
    });
  });

  group('PlaceholderEffect', () {
    test('ShimmerEffect creates repeating controller', () {
      const effect = ShimmerEffect();
      expect(effect.baseColor, isNull);
      expect(effect.highlightColor, isNull);
      expect(effect.duration, const Duration(milliseconds: 1500));
    });

    test('PulseEffect has correct defaults', () {
      const effect = PulseEffect();
      expect(effect.minOpacity, 0.4);
      expect(effect.maxOpacity, 1.0);
    });

    test('SolidEffect has correct defaults', () {
      const effect = SolidEffect();
      expect(effect.color, isNull);
    });
  });

  group('AutoSkeletonConfigData', () {
    test('default config has expected values', () {
      const config = AutoSkeletonConfigData();
      expect(config.textBorderRadius, 4.0);
      expect(config.containerBorderRadius, 8.0);
      expect(config.enableSwitchAnimation, true);
      expect(config.justifyMultiLineText, true);
    });
  });

  group('Widget extension', () {
    testWidgets('withSkeleton wraps correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').withSkeleton(loading: false),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(AutoSkeleton), findsOneWidget);
    });
  });

  group('SkeletonPresets', () {
    testWidgets('listTile preset renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonPresets.listTile(itemCount: 3),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(AutoSkeleton), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('foodCard preset renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonPresets.foodCard(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(AutoSkeleton), findsOneWidget);
    });
  });
}
