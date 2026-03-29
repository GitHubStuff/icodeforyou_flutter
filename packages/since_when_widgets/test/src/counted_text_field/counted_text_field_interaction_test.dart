// test/src/counted_text_field/counted_text_field_interaction_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:since_when_widgets/since_when_widgets.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('CountedTextField interaction', () {
    testWidgets('badge updates as user types', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {}, maxLength: 10)),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      expect(find.text('5/10'), findsOneWidget);
    });

    testWidgets('onChanged fires with typed value', (tester) async {
      String? captured;

      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (v) => captured = v, maxLength: 10)),
      );

      await tester.enterText(find.byType(TextField), 'hi');
      await tester.pump();

      expect(captured, 'hi');
    });

    testWidgets('input under limit is not truncated', (tester) async {
      String? captured;

      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (v) => captured = v, maxLength: 10)),
      );

      await tester.enterText(find.byType(TextField), 'short');
      await tester.pump();

      expect(captured, 'short');
    });

    testWidgets('input at exactly maxLength is not truncated', (tester) async {
      String? captured;

      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (v) => captured = v, maxLength: 5)),
      );

      await tester.enterText(find.byType(TextField), 'exact');
      await tester.pump();

      expect(captured, 'exact');
      expect(find.text('5/5'), findsOneWidget);
    });

    testWidgets('input over maxLength is truncated', (tester) async {
      String? captured;

      await tester.pumpWidget(
        _wrap(
          CountedTextField(
            onChanged: (v) => captured = v,
            maxLength: 5,
            durationMs: 750,
            fadeMs: 250,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'toolongstring');
      await tester.pump();

      expect(captured, 'toolo');
      expect(find.text('5/5'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 750));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
    });

    testWidgets('truncation fires onChanged with truncated value',
        (tester) async {
      String? captured;

      await tester.pumpWidget(
        _wrap(
          CountedTextField(
            onChanged: (v) => captured = v,
            maxLength: 3,
            durationMs: 750,
            fadeMs: 250,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'abcdef');
      await tester.pump();

      expect(captured, 'abc');

      await tester.pump(const Duration(milliseconds: 750));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
    });

    testWidgets('truncation shows floating message', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CountedTextField(
            onChanged: (_) {},
            maxLength: 3,
            durationMs: 750,
            fadeMs: 250,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'abcdef');
      await tester.pump();

      expect(find.text('🛑 Max 3 characters'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 750));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
    });

    testWidgets('floating message disappears after durationMs + fadeMs',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          CountedTextField(
            onChanged: (_) {},
            maxLength: 3,
            durationMs: 750,
            fadeMs: 250,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'abcdef');
      await tester.pump();

      expect(find.text('🛑 Max 3 characters'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 750));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      expect(find.text('🛑 Max 3 characters'), findsNothing);
    });

    testWidgets('clear button resets badge to 0', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {}, maxLength: 10)),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      expect(find.text('5/10'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.cancel_outlined));
      await tester.pump();

      expect(find.text('0/10'), findsOneWidget);
    });

    testWidgets('clear button fires onChanged with empty string',
        (tester) async {
      String? captured;

      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (v) => captured = v, maxLength: 10)),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.cancel_outlined));
      await tester.pump();

      expect(captured, '');
    });

    testWidgets('border color defaults to purple', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {})),
      );

      final widget = tester.widget<CountedTextField>(
        find.byType(CountedTextField),
      );

      expect(widget.borderColor, const Color(0xFF9C27B0));
    });

    testWidgets('error border color defaults to red', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {})),
      );

      final widget = tester.widget<CountedTextField>(
        find.byType(CountedTextField),
      );

      expect(widget.errorBorderColor, const Color(0xFFF44336));
    });

    testWidgets('custom borderColor is stored on widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CountedTextField(onChanged: (_) {}, borderColor: Colors.blue),
        ),
      );

      final widget = tester.widget<CountedTextField>(
        find.byType(CountedTextField),
      );

      expect(widget.borderColor, Colors.blue);
    });

    testWidgets('custom errorBorderColor is stored on widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CountedTextField(onChanged: (_) {}, errorBorderColor: Colors.orange),
        ),
      );

      final widget = tester.widget<CountedTextField>(
        find.byType(CountedTextField),
      );

      expect(widget.errorBorderColor, Colors.orange);
    });

    testWidgets('controller is disposed without error', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {})),
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
