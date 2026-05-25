// test/src/_settings_layout_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_widget/src/_settings_direction.dart';
import 'package:settings_widget/src/_settings_layout.dart';

Widget _wrap(
  SettingsDirection direction, {
  double edgeGap = 16,
}) =>
    MaterialApp(
      home: Scaffold(
        body: SettingsLayout(
          direction: direction,
          edgeGap: edgeGap,
          child: const SizedBox(width: 100, height: 100),
        ),
      ),
    );

Material _findLayoutMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find.descendant(
      of: find.byType(SettingsLayout),
      matching: find.byType(Material),
    ),
  );
}

Padding _findLayoutPadding(WidgetTester tester) {
  return tester.widget<Padding>(
    find.descendant(
      of: find.byType(SettingsLayout),
      matching: find.byType(Padding),
    ),
  );
}

Align _findLayoutAlign(WidgetTester tester) {
  return tester.widget<Align>(
    find.descendant(
      of: find.byType(SettingsLayout),
      matching: find.byType(Align),
    ),
  );
}

void main() {
  group('SettingsLayout alignment', () {
    testWidgets('bottom aligns to bottomCenter', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.bottom));
      expect(_findLayoutAlign(tester).alignment, Alignment.bottomCenter);
    });

    testWidgets('top aligns to topCenter', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.top));
      expect(_findLayoutAlign(tester).alignment, Alignment.topCenter);
    });

    testWidgets('left aligns to centerLeft', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.left));
      expect(_findLayoutAlign(tester).alignment, Alignment.centerLeft);
    });

    testWidgets('right aligns to centerRight', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.right));
      expect(_findLayoutAlign(tester).alignment, Alignment.centerRight);
    });
  });

  group('SettingsLayout padding', () {
    testWidgets('bottom applies bottom edge gap', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.bottom, edgeGap: 24));
      expect(
        _findLayoutPadding(tester).padding,
        const EdgeInsets.only(bottom: 24),
      );
    });

    testWidgets('top applies top edge gap', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.top, edgeGap: 24));
      expect(
        _findLayoutPadding(tester).padding,
        const EdgeInsets.only(top: 24),
      );
    });

    testWidgets('left applies left edge gap', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.left, edgeGap: 24));
      expect(
        _findLayoutPadding(tester).padding,
        const EdgeInsets.only(left: 24),
      );
    });

    testWidgets('right applies right edge gap', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.right, edgeGap: 24));
      expect(
        _findLayoutPadding(tester).padding,
        const EdgeInsets.only(right: 24),
      );
    });
  });

  group('SettingsLayout sizing', () {
    testWidgets('left wraps child in SizedBox', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.left));
      expect(
        find.descendant(
          of: find.byType(SettingsLayout),
          matching: find.byType(SizedBox),
        ),
        findsWidgets,
      );
    });

    testWidgets('right wraps child in SizedBox', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.right));
      expect(
        find.descendant(
          of: find.byType(SettingsLayout),
          matching: find.byType(SizedBox),
        ),
        findsWidgets,
      );
    });

    testWidgets('bottom does not add sizing SizedBox', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.bottom));
      expect(
        find.descendant(
          of: find.byType(SettingsLayout),
          matching: find.byType(SizedBox),
        ),
        findsOneWidget,
      );
    });

    testWidgets('top does not add sizing SizedBox', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.top));
      expect(
        find.descendant(
          of: find.byType(SettingsLayout),
          matching: find.byType(SizedBox),
        ),
        findsOneWidget,
      );
    });
  });

  group('SettingsLayout material', () {
    testWidgets('renders Material with elevation 6', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.bottom));
      expect(_findLayoutMaterial(tester).elevation, 6);
    });

    testWidgets('Material uses surfaceContainerHigh color', (tester) async {
      await tester.pumpWidget(_wrap(SettingsDirection.bottom));
      final material = _findLayoutMaterial(tester);
      final context = tester.element(
        find.descendant(
          of: find.byType(SettingsLayout),
          matching: find.byType(Material),
        ),
      );
      expect(
        material.color,
        Theme.of(context).colorScheme.surfaceContainerHigh,
      );
    });
  });
}
