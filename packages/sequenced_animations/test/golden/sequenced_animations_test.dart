// packages/sequenced_animations/test/golden/sequenced_animations_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/sequenced_animations.dart' show SequencedAnimations;

void main() {
  /// Tag that keeps these tests out of the coverage run.
  const golden = ['golden'];

  testWidgets(
    'SequencedAnimations renders correctly',
    tags: golden,
    (tester) async {
      // 1. Set explicit surface size for consistent rendering across platforms
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // 2. Pump widget wrapped in MaterialApp
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SequencedAnimations(),
          ),
        ),
      );

      // 3. Ensure asynchronous image decoding completes in real-time execution
      await tester.runAsync(() async {
        final element = find.byType(SequencedAnimations).evaluate().first;
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
        find.byType(SequencedAnimations),
        matchesGoldenFile('goldens/sequenced_animations.png'),
      );
    },
  );
}
