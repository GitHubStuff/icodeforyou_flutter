// test/src/counted_text_field/counted_text_field_render_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:since_when_widgets/since_when_widgets.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('CountedTextField render', () {
    testWidgets('renders with defaults', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {})),
      );

      expect(find.byType(CountedTextField), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders default hint text', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {})),
      );

      expect(find.text('Enter text'), findsOneWidget);
    });

    testWidgets('renders custom hint text', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {}, hintText: 'Type here')),
      );

      expect(find.text('Type here'), findsOneWidget);
    });

    testWidgets('renders default clear widget', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {})),
      );

      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('renders custom clear widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CountedTextField(
            onChanged: (_) {},
            clearWidget: const Icon(Icons.close),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('badge shows 0/maxLength on mount', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {}, maxLength: 10)),
      );

      expect(find.text('0/10'), findsOneWidget);
    });

    testWidgets('badge respects custom maxLength', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {}, maxLength: 42)),
      );

      expect(find.text('0/42'), findsOneWidget);
    });

    testWidgets('renders caption when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CountedTextField(onChanged: (_) {}, caption: 'Name'),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('does not render caption when omitted', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {})),
      );

      expect(find.text('Name'), findsNothing);
    });

    testWidgets('uses LTR direction by default', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {})),
      );

      final directionality = tester.widget<Directionality>(
        find
            .descendant(
              of: find.byType(CountedTextField),
              matching: find.byType(Directionality),
            )
            .first,
      );

      expect(directionality.textDirection, TextDirection.ltr);
    });

    testWidgets('uses explicit RTL direction when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CountedTextField(
            onChanged: (_) {},
            textDirection: TextDirection.rtl,
          ),
        ),
      );

      final directionality = tester.widget<Directionality>(
        find
            .descendant(
              of: find.byType(CountedTextField),
              matching: find.byType(Directionality),
            )
            .first,
      );

      expect(directionality.textDirection, TextDirection.rtl);
    });

    testWidgets('floating message is not visible on mount', (tester) async {
      await tester.pumpWidget(
        _wrap(CountedTextField(onChanged: (_) {}, maxLength: 5)),
      );

      expect(find.text('🛑 Max 5 characters'), findsNothing);
    });
  });
}
