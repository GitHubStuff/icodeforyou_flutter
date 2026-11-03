// packages/place_holder_widget/test/golden/place_holder_widget_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/place_holder_widget.dart' show PlaceHolderWidget;

void main() {
  /// Tag that keeps these tests out of the coverage run.
  const golden = ['golden'];

  testWidgets(
    'PlaceHolderWidget renders correctly',
    tags: golden,
    (tester) async {
      // 1. Set explicit surface size for consistent rendering across platforms
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // 2. Pump widget wrapped in MaterialApp
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlaceHolderWidget(),
          ),
        ),
      );

      // 3. Ensure asynchronous image decoding completes in real-time execution
      await tester.runAsync(() async {
        final element = find.byType(PlaceHolderWidget).evaluate().first;
        final imageElement = find.descendant(
          of: find.byWidget(element.widget),
          matching: find.byType(Image),
        );

        if (imageElement.evaluate().isNotEmpty) {
          final Image image = tester.widget(imageElement.first);
          await precacheImage(image.image, element);
        }
      });

      await tester.pumpAndSettle();

      // 4. Compare golden file
      await expectLater(
        find.byType(PlaceHolderWidget),
        matchesGoldenFile('goldens/place_holder_widget.png'),
      );
    },
  );
}
