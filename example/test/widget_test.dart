import 'package:flutter_test/flutter_test.dart';

import 'package:auto_skeleton_example/main.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoSkeletonExampleApp());
    expect(find.text('AutoSkeleton Demo'), findsOneWidget);
  });
}
