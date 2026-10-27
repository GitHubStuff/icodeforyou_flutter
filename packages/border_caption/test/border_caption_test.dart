// packages/border_caption/test/border_caption_test.dart

import 'package:border_caption/border_caption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('border_caption barrel', () {
    test('exports BorderPosition', () {
      expect(BorderPosition.values, [BorderPosition.top, BorderPosition.bottom]);
    });

    testWidgets('exports BorderCaption', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BorderCaption(
                label: 'Label',
                child: SizedBox(width: 100, height: 50),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BorderCaption), findsOneWidget);
      expect(find.text('Label'), findsOneWidget);
    });
  });
}
