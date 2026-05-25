// animated_widgets/test/src/length_colored_border_field/length_colored_border_field_test.dart

import 'package:animated_widgets/src/length_colored_border_field/color_point.dart';
import 'package:animated_widgets/src/length_colored_border_field/color_point_ramp.dart';
import 'package:animated_widgets/src/length_colored_border_field/length_colored_border_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _purple = Color(0xFF800080);
const _green = Color(0xFF00FF00);
const _yellow = Color(0xFFFFFF00);
const _red = Color(0xFFFF0000);

ColorPointRamp _exampleRamp() => ColorPointRamp(const [
  ColorPoint(point: 0, color: _purple),
  ColorPoint(point: 3, color: _green),
  ColorPoint(point: 6, color: _yellow),
  ColorPoint(point: 9, color: _red),
]);

Widget _buildSubject({
  required ColorPointRamp ramp,
  TextEditingController? controller,
  TextStyle? style,
}) => MaterialApp(
  home: Scaffold(
    body: LengthColoredBorderField(
      ramp: ramp,
      controller: controller,
      style: style,
    ),
  ),
);

Color _enabledBorderColor(WidgetTester tester) {
  final field = tester.widget<TextField>(find.byType(TextField));
  final border = field.decoration!.enabledBorder! as OutlineInputBorder;
  return border.borderSide.color;
}

Color _focusedBorderColor(WidgetTester tester) {
  final field = tester.widget<TextField>(find.byType(TextField));
  final border = field.decoration!.focusedBorder! as OutlineInputBorder;
  return border.borderSide.color;
}

double _focusedBorderWidth(WidgetTester tester) {
  final field = tester.widget<TextField>(find.byType(TextField));
  final border = field.decoration!.focusedBorder! as OutlineInputBorder;
  return border.borderSide.width;
}

void main() {
  group('LengthColoredBorderField', () {
    testWidgets('renders a TextField', (tester) async {
      await tester.pumpWidget(_buildSubject(ramp: _exampleRamp()));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('initial border uses first color when text is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(ramp: _exampleRamp()));
      expect(_enabledBorderColor(tester), equals(_purple));
    });

    testWidgets('border color updates when length crosses a threshold', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(ramp: _exampleRamp()));

      await tester.enterText(find.byType(TextField), 'abc'); // length 3
      await tester.pump();
      expect(_enabledBorderColor(tester), equals(_green));

      await tester.enterText(find.byType(TextField), 'abcdef'); // length 6
      await tester.pump();
      expect(_enabledBorderColor(tester), equals(_yellow));

      await tester.enterText(find.byType(TextField), 'abcdefghi'); // length 9
      await tester.pump();
      expect(_enabledBorderColor(tester), equals(_red));
    });

    testWidgets('border color stays through bucket interior', (tester) async {
      await tester.pumpWidget(_buildSubject(ramp: _exampleRamp()));

      await tester.enterText(find.byType(TextField), 'abc'); // 3 → green
      await tester.pump();
      expect(_enabledBorderColor(tester), equals(_green));

      await tester.enterText(find.byType(TextField), 'abcde'); // 5 → green
      await tester.pump();
      expect(_enabledBorderColor(tester), equals(_green));
    });

    testWidgets('focused border uses same color with width 2', (tester) async {
      await tester.pumpWidget(_buildSubject(ramp: _exampleRamp()));
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();

      expect(_focusedBorderColor(tester), equals(_green));
      expect(_focusedBorderWidth(tester), equals(2.0));
    });

    testWidgets('uses the supplied controller when provided', (tester) async {
      final controller = TextEditingController(text: 'abcdef'); // length 6
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildSubject(ramp: _exampleRamp(), controller: controller),
      );

      expect(_enabledBorderColor(tester), equals(_yellow));

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(identical(field.controller, controller), isTrue);
    });

    testWidgets('caller-owned controller is not disposed by the widget', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'ab');

      await tester.pumpWidget(
        _buildSubject(ramp: _exampleRamp(), controller: controller),
      );
      await tester.pumpWidget(const SizedBox.shrink());

      // Still usable after the widget is gone.
      expect(() => controller.text = 'still alive', returnsNormally);
      controller.dispose();
    });

    testWidgets('internally created controller does not leak on dispose', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(ramp: _exampleRamp()));
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      // No assertion — flutter_test's leak tracking will fail this if the
      // widget-owned controller is not disposed.
    });

    testWidgets('forwards style to the inner TextField', (tester) async {
      const style = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
      await tester.pumpWidget(
        _buildSubject(ramp: _exampleRamp(), style: style),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.style, equals(style));
    });

    testWidgets('null style forwards null to the inner TextField', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(ramp: _exampleRamp()));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.style, isNull);
    });

    testWidgets('border color recomputes when ramp changes', (tester) async {
      final controller = TextEditingController(text: 'abcde'); // length 5
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildSubject(ramp: _exampleRamp(), controller: controller),
      );
      expect(_enabledBorderColor(tester), equals(_green));

      // Swap to a ramp where length 5 lands in red.
      final tightRamp = ColorPointRamp(const [
        ColorPoint(point: 0, color: _purple),
        ColorPoint(point: 5, color: _red),
      ]);
      await tester.pumpWidget(
        _buildSubject(ramp: tightRamp, controller: controller),
      );

      expect(_enabledBorderColor(tester), equals(_red));
    });

    testWidgets('border color does not change within the same bucket', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(ramp: _exampleRamp()));

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();
      final firstColor = _enabledBorderColor(tester);

      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump();
      final secondColor = _enabledBorderColor(tester);

      expect(firstColor, equals(_purple));
      expect(secondColor, equals(_purple));
    });
  });
}
