// animated_widgets/test/src/length_colored_border_field/length_colored_border_field_test.dart
import 'package:animated_widgets/src/length_colored_border_field/color_point.dart'
    show ColorPoint;
import 'package:animated_widgets/src/length_colored_border_field/color_point_ramp.dart'
    show ColorPointRamp;
import 'package:animated_widgets/src/length_colored_border_field/length_colored_border_field.dart'
    show LengthColoredBorderField;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _red = Color(0xFFFF0000);
const _blue = Color(0xFF0000FF);
const _green = Color(0xFF00FF00);

/// red for length < 3, blue for length >= 3.
ColorPointRamp _redBlueRamp() => ColorPointRamp(const [
      ColorPoint(point: 0, color: _red),
      ColorPoint(point: 3, color: _blue),
    ]);

/// green for length < 3, blue for length >= 3 (differs from red/blue at len 0).
ColorPointRamp _greenBlueRamp() => ColorPointRamp(const [
      ColorPoint(point: 0, color: _green),
      ColorPoint(point: 3, color: _blue),
    ]);

/// green at length 0 (same as green/blue at len 0) but a different shape.
ColorPointRamp _greenRedRamp() => ColorPointRamp(const [
      ColorPoint(point: 0, color: _green),
      ColorPoint(point: 2, color: _red),
    ]);

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

TextField _field(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField));

Color _enabledBorderColor(WidgetTester tester) {
  final border = _field(tester).decoration!.enabledBorder! as OutlineInputBorder;
  return border.borderSide.color;
}

void main() {
  group('LengthColoredBorderField', () {
    group('without maxLength', () {
      testWidgets(
        'renders a bare field with no counter and owns its controller',
        (tester) async {
          await tester.pumpWidget(
            _app(LengthColoredBorderField(ramp: _redBlueRamp())),
          );

          expect(find.byType(TextField), findsOneWidget);
          expect(find.textContaining('/'), findsNothing);

          final field = _field(tester);
          expect(field.maxLength, isNull);
          expect(field.inputFormatters, isNull);
          expect(_enabledBorderColor(tester), _red); // length 0

          // buildCounter is wired to the hidden (null) counter.
          final context = tester.element(find.byType(TextField));
          expect(
            field.buildCounter!(
              context,
              currentLength: 0,
              maxLength: null,
              isFocused: false,
            ),
            isNull,
          );

          // Removing the field disposes the self-owned controller cleanly; a
          // leak would surface as an exception.
          await tester.pumpWidget(const SizedBox.shrink());
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('recolors the border as text length crosses a threshold', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(LengthColoredBorderField(ramp: _redBlueRamp())),
        );
        expect(_enabledBorderColor(tester), _red);

        await tester.enterText(find.byType(TextField), 'ab'); // length 2
        await tester.pump();
        expect(_enabledBorderColor(tester), _red);

        await tester.enterText(find.byType(TextField), 'abc'); // length 3
        await tester.pump();
        expect(_enabledBorderColor(tester), _blue);
      });
    });

    group('with maxLength', () {
      testWidgets(
        'renders the counter pill and forwards a limiting formatter',
        (tester) async {
          await tester.pumpWidget(
            _app(LengthColoredBorderField(ramp: _redBlueRamp(), maxLength: 5)),
          );

          expect(find.text('0/5'), findsOneWidget);

          final field = _field(tester);
          expect(field.maxLength, 5);
          final limiter = field.inputFormatters!
              .whereType<LengthLimitingTextInputFormatter>()
              .single;
          expect(limiter.maxLength, 5);
        },
      );

      testWidgets('hard-caps input at maxLength and updates the counter', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(LengthColoredBorderField(ramp: _redBlueRamp(), maxLength: 5)),
        );

        await tester.enterText(find.byType(TextField), 'abcdefgh'); // 8 chars
        await tester.pump();

        expect(_field(tester).controller!.text.length, 5);
        expect(find.text('5/5'), findsOneWidget);
        expect(_enabledBorderColor(tester), _blue); // length 5 >= 3
      });
    });

    group('controller ownership', () {
      testWidgets('does not dispose a caller-owned controller', (tester) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _app(
            LengthColoredBorderField(
              ramp: _redBlueRamp(),
              controller: controller,
              maxLength: 5,
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'ab'); // length 2
        await tester.pump();
        expect(find.text('2/5'), findsOneWidget);

        // Selection-only change notifies the listener but alters neither length
        // nor color, so the guard short-circuits and the count holds.
        controller.selection = const TextSelection.collapsed(offset: 1);
        await tester.pump();
        expect(find.text('2/5'), findsOneWidget);

        // Removing the widget must NOT dispose the caller's controller.
        await tester.pumpWidget(const SizedBox.shrink());
        expect(() => controller.text = 'still alive', returnsNormally);
      });
    });

    group('didUpdateWidget', () {
      testWidgets('recolors when the ramp changes, holds otherwise', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(LengthColoredBorderField(ramp: _redBlueRamp())),
        );
        expect(_enabledBorderColor(tester), _red); // length 0

        // New ramp -> different color at length 0 -> setState.
        await tester.pumpWidget(
          _app(LengthColoredBorderField(ramp: _greenBlueRamp())),
        );
        expect(_enabledBorderColor(tester), _green);

        // Equal ramp (same content) + a style change -> ramp-unchanged branch.
        await tester.pumpWidget(
          _app(
            LengthColoredBorderField(
              ramp: _greenBlueRamp(),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        );
        expect(_enabledBorderColor(tester), _green);

        // Different ramp but identical color at length 0 -> ramp changed,
        // color stable, so no setState.
        await tester.pumpWidget(
          _app(LengthColoredBorderField(ramp: _greenRedRamp())),
        );
        expect(_enabledBorderColor(tester), _green);
      });
    });
  });
}
