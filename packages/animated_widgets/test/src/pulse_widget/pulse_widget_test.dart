// test/src/pulse_widget/pulse_widget_test.dart

import 'package:animated_widgets/src/pulse_widget/pulse_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildSubject({required bool trigger, Duration? duration}) => WidgetsApp(
  color: const Color(0xFF000000),
  builder: (_, _) => PulseWidget(
    trigger: trigger,
    duration: duration ?? const Duration(milliseconds: 200),
    child: const SizedBox(width: 50, height: 50),
  ),
);

void main() {
  group('PulseWidget', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(_buildSubject(trigger: false));
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('wraps child in ScaleTransition', (tester) async {
      await tester.pumpWidget(_buildSubject(trigger: false));
      expect(find.byType(ScaleTransition), findsOneWidget);
    });

    testWidgets('scale is 1.0 when trigger is false', (tester) async {
      await tester.pumpWidget(_buildSubject(trigger: false));
      final transition = tester.widget<ScaleTransition>(
        find.byType(ScaleTransition),
      );
      expect(transition.scale.value, equals(1.0));
    });

    testWidgets('animates when trigger changes false → true', (tester) async {
      await tester.pumpWidget(_buildSubject(trigger: false));

      await tester.pumpWidget(_buildSubject(trigger: true));
      await tester.pump(const Duration(milliseconds: 100));

      final transition = tester.widget<ScaleTransition>(
        find.byType(ScaleTransition),
      );
      expect(transition.scale.value, isNot(equals(1.0)));
    });

    testWidgets('animation completes and returns to 1.0', (tester) async {
      await tester.pumpWidget(_buildSubject(trigger: false));
      await tester.pumpWidget(_buildSubject(trigger: true));
      await tester.pumpAndSettle();

      final transition = tester.widget<ScaleTransition>(
        find.byType(ScaleTransition),
      );
      expect(transition.scale.value, closeTo(1.0, 0.01));
    });

    testWidgets('does not animate when trigger stays true', (tester) async {
      await tester.pumpWidget(_buildSubject(trigger: true));
      await tester.pumpWidget(_buildSubject(trigger: true));
      await tester.pump(const Duration(milliseconds: 100));

      final transition = tester.widget<ScaleTransition>(
        find.byType(ScaleTransition),
      );
      // no new animation fired — scale stays at 1.0
      expect(transition.scale.value, equals(1.0));
    });

    testWidgets('does not animate when trigger stays false', (tester) async {
      await tester.pumpWidget(_buildSubject(trigger: false));
      await tester.pumpWidget(_buildSubject(trigger: false));
      await tester.pump(const Duration(milliseconds: 100));

      final transition = tester.widget<ScaleTransition>(
        find.byType(ScaleTransition),
      );
      expect(transition.scale.value, equals(1.0));
    });

    testWidgets('accepts custom duration', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          trigger: false,
          duration: const Duration(milliseconds: 400),
        ),
      );
      expect(find.byType(PulseWidget), findsOneWidget);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(_buildSubject(trigger: false));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
