// test/tag_color_field/tag_color_field_interaction_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:since_when_widgets/since_when_widgets.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Finder _swatchFinder() => find.descendant(
  of: find.byType(TagColorField),
  matching: find.byType(ColoredBox),
);

void main() {
  group('TagColorField interaction', () {
    testWidgets('onChanged fires on mount', (tester) async {
      int? captured;

      await tester.pumpWidget(
        _wrap(TagColorField(onChanged: (v) => captured = v)),
      );
      await tester.pump();

      expect(captured, isNotNull);
    });

    testWidgets('onChanged fires with a non-zero int on mount', (tester) async {
      int? captured;

      await tester.pumpWidget(
        _wrap(TagColorField(onChanged: (v) => captured = v)),
      );
      await tester.pump();

      expect(captured, isNonZero);
    });

    testWidgets('onChanged fires on refresh tap', (tester) async {
      final captured = <int>[];

      await tester.pumpWidget(
        _wrap(TagColorField(onChanged: captured.add)),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(captured.length, 2);
    });

    testWidgets('refresh produces a different color', (tester) async {
      final captured = <int>[];

      await tester.pumpWidget(
        _wrap(TagColorField(onChanged: captured.add)),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(captured[0], isNot(captured[1]));
    });

    testWidgets('refresh never repeats a previously seen color', (
      tester,
    ) async {
      final captured = <int>[];

      await tester.pumpWidget(
        _wrap(TagColorField(onChanged: captured.add)),
      );
      await tester.pump();

      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();
      }

      final unique = captured.toSet();
      expect(unique.length, captured.length);
    });

    testWidgets('initial skipColors are never generated', (tester) async {
      final captured = <int>[];
      const skip = <int>[0xFF123456, 0xFF654321];

      await tester.pumpWidget(
        _wrap(
          TagColorField(
            onChanged: captured.add,
            skipColors: skip,
          ),
        ),
      );
      await tester.pump();

      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();
      }

      for (final color in captured) {
        expect(skip, isNot(contains(color)));
      }
    });

    testWidgets('didUpdateWidget merges new skipColors', (tester) async {
      final captured = <int>[];
      var extraSkip = <int>[];

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  TagColorField(
                    onChanged: captured.add,
                    skipColors: extraSkip,
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => extraSkip = [0xFF112233]),
                    child: const Text('update'),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('update'));
      await tester.pump();

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();
      }

      expect(captured, isNot(contains(0xFF112233)));
    });

    testWidgets('AnimatedSwitcher key changes on refresh', (tester) async {
      await tester.pumpWidget(
        _wrap(TagColorField(onChanged: (_) {})),
      );
      await tester.pumpAndSettle();

      final before = tester.firstWidget<ColoredBox>(_swatchFinder()).key;

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      final after = tester.firstWidget<ColoredBox>(_swatchFinder()).key;

      expect(before, isNot(after));
    });

    testWidgets('custom refresh widget triggers onChanged', (tester) async {
      final captured = <int>[];

      await tester.pumpWidget(
        _wrap(
          TagColorField(
            onChanged: captured.add,
            refresh: const Icon(Icons.autorenew),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.autorenew));
      await tester.pump();

      expect(captured.length, 2);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(
        _wrap(TagColorField(onChanged: (_) {})),
      );
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
