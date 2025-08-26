// clock_painter_test.dart
import 'package:analog_clock_widget/analog_clock_widget.dart'
    show TimeProvider, ClockStyle, ClockFaceStyle, HandStyle, AnalogClock;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixed time provider to deterministically tick the clock in tests.
class _FixedTime implements TimeProvider {
  _FixedTime(this._now);
  DateTime _now;
  @override
  DateTime get now => _now;
  void setNow(DateTime t) => _now = t;
}

Widget _host(Widget child) {
  return MaterialApp(
    theme: ThemeData.from(colorScheme: const ColorScheme.light()),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalogClock → painter behavior via widget', () {
    testWidgets('classic face + traditional hands + seconds + numbers', (
      tester,
    ) async {
      final time = _FixedTime(DateTime(2024, 1, 15, 3, 27, 42));
      final style = ClockStyle(
        faceStyle: ClockFaceStyle.classic, // exercises _drawClassicTicks
        handStyle: HandStyle.traditional, // exercises _drawTraditionalHand
        showSecondHand: true, // exercises _drawSecondHandShape
        showNumbers: true, // exercises _drawNumbers path
      );

      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 220,
            height: 220,
            child: AnalogClock(
              radius: 100, // large → ticks + numbers + minute sweep branch
              style: style,
              timeProvider: time,
            ),
          ),
        ),
      );
      await tester.pump(); // first paint

      // Change time to trigger shouldRepaint(dateTime)
      time.setNow(DateTime(2024, 1, 15, 4, 10, 5));
      await tester.pump(const Duration(milliseconds: 16)); // repaint

      expect(find.byType(AnalogClock), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets(
      'modern face + modern hands (thicker) + no seconds + numbers off/on',
      (tester) async {
        final time = _FixedTime(DateTime(2024, 1, 15, 10, 5, 30));

        // Initial: numbers ON, seconds OFF (exercises config variants)
        await tester.pumpWidget(
          _host(
            SizedBox(
              width: 210,
              height: 210,
              child: AnalogClock(
                radius: 96,
                style: ClockStyle(
                  faceStyle:
                      ClockFaceStyle.modern, // exercises _drawModernTicks
                  handStyle: HandStyle.modern, // exercises _drawModernHand
                  showSecondHand: false, // skip second hand
                  showNumbers: true, // numbers path
                ),
                timeProvider: time,
              ),
            ),
          ),
        );
        await tester.pump();

        // Flip config to trigger shouldRepaint(configuration) and second hand path
        await tester.pumpWidget(
          _host(
            SizedBox(
              width: 210,
              height: 210,
              child: AnalogClock(
                radius: 96,
                style: ClockStyle(
                  faceStyle: ClockFaceStyle.modern,
                  handStyle: HandStyle.modern,
                  showSecondHand: true, // now draws second hand
                  showNumbers: false, // numbers disabled
                ),
                timeProvider: time,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));

        expect(find.byType(AnalogClock), findsOneWidget);
      },
    );

    testWidgets(
      'minimal face (dots) + sleek hands + tiny canvas (minute sweep off)',
      (tester) async {
        final time = _FixedTime(DateTime(2024, 1, 15, 12, 0, 0));

        // Small outer size to force tiny canvas radius so the painter’s
        // minute-sweep branch uses the small-radius code path (0.0).
        await tester.pumpWidget(
          _host(
            SizedBox(
              width: 34,
              height: 34,
              child: FittedBox(
                child: AnalogClock(
                  radius: 60,
                  style: ClockStyle(
                    faceStyle: ClockFaceStyle
                        .minimal, // exercises _drawMinimalTicks dots; numbers ignored
                    handStyle: HandStyle.sleek, // exercises _drawSleekHand
                    showSecondHand: true,
                    showNumbers: true, // ignored by minimal face in painter
                  ),
                  timeProvider: time,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Nudge time to verify repaint still succeeds on tiny canvas
        time.setNow(DateTime(2024, 1, 15, 12, 30, 45));
        await tester.pump(const Duration(milliseconds: 16));

        expect(find.byType(AnalogClock), findsOneWidget);
      },
    );

    test('constructor enforces minimum radius', () {
      // Must throw when radius is below painter minimum constraint
      expect(() => AnalogClock(radius: 1), throwsArgumentError);
    });
  });
}
