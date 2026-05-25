// animated_widgets/test/src/length_colored_border_field/length_colored_border_field_max_length_test.dart

import 'package:animated_widgets/src/length_colored_border_field/color_point.dart';
import 'package:animated_widgets/src/length_colored_border_field/color_point_ramp.dart';
import 'package:animated_widgets/src/length_colored_border_field/length_colored_border_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LengthColoredBorderField with maxLength', () {
    final ramp = ColorPointRamp(const [
      ColorPoint(point: 0, color: Color(0xFFFF0000)),
      ColorPoint(point: 3, color: Color(0xFF00FF00)),
    ]);

    Widget hostWidget({TextEditingController? controller, int? maxLength}) {
      return MaterialApp(
        home: Scaffold(
          body: LengthColoredBorderField(
            ramp: ramp,
            controller: controller,
            maxLength: maxLength,
          ),
        ),
      );
    }

    testWidgets('renders the counter pill showing current/max', (tester) async {
      final controller = TextEditingController(text: 'ab');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        hostWidget(controller: controller, maxLength: 5),
      );

      expect(find.text('2/5'), findsOneWidget);
    });

    testWidgets('counter pill updates as text changes', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        hostWidget(controller: controller, maxLength: 4),
      );

      expect(find.text('0/4'), findsOneWidget);

      controller.text = 'abcd';
      await tester.pump();

      expect(find.text('4/4'), findsOneWidget);
    });

    testWidgets('hard-caps input at maxLength via the formatter',
        (tester) async {
      await tester.pumpWidget(hostWidget(maxLength: 3));

      await tester.enterText(find.byType(TextField), 'abcdef');
      await tester.pump();

      expect(find.text('3/3'), findsOneWidget);
      expect(
        (tester.widget<TextField>(find.byType(TextField))).controller!.text,
        'abc',
      );
    });
  });
}
