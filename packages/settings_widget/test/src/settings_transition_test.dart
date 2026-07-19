// test/src/_settings_transition_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_widget/src/settings_direction.dart';
import 'package:settings_widget/src/settings_transition.dart';

Widget _wrap(SettingsDirection direction, Animation<double> animation) =>
    MaterialApp(
      home: Scaffold(
        body: SettingsTransition(
          animation: animation,
          direction: direction,
          child: const SizedBox(width: 100, height: 100),
        ),
      ),
    );

SlideTransition _findSlide(WidgetTester tester) {
  return tester.widget<SlideTransition>(
    find.descendant(
      of: find.byType(SettingsTransition),
      matching: find.byType(SlideTransition),
    ),
  );
}

void main() {
  group('SettingsTransition', () {
    testWidgets('bottom begins at offset (0, 1)', (tester) async {
      final controller = AnimationController(vsync: tester);
      await tester.pumpWidget(_wrap(SettingsDirection.bottom, controller));
      expect(_findSlide(tester).position.value, const Offset(0, 1));
      controller.dispose();
    });

    testWidgets('top begins at offset (0, -1)', (tester) async {
      final controller = AnimationController(vsync: tester);
      await tester.pumpWidget(_wrap(SettingsDirection.top, controller));
      expect(_findSlide(tester).position.value, const Offset(0, -1));
      controller.dispose();
    });

    testWidgets('left begins at offset (-1, 0)', (tester) async {
      final controller = AnimationController(vsync: tester);
      await tester.pumpWidget(_wrap(SettingsDirection.left, controller));
      expect(_findSlide(tester).position.value, const Offset(-1, 0));
      controller.dispose();
    });

    testWidgets('right begins at offset (1, 0)', (tester) async {
      final controller = AnimationController(vsync: tester);
      await tester.pumpWidget(_wrap(SettingsDirection.right, controller));
      expect(_findSlide(tester).position.value, const Offset(1, 0));
      controller.dispose();
    });

    testWidgets('tween end is Offset.zero', (tester) async {
      final controller = AnimationController(
        vsync: tester,
        value: 1,
      );
      await tester.pumpWidget(_wrap(SettingsDirection.bottom, controller));
      final slide = _findSlide(tester);
      final tween = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero);
      expect(tween.end, Offset.zero);
      expect(slide.position, isNotNull);
      controller.dispose();
    });
  });
}
