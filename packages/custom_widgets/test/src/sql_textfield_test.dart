// packages/custom_widgets/test/src/sql_textfield_test.dart

import 'package:custom_widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme,
  home: Scaffold(body: child),
);

void main() {
  group('SqlTextField', () {
    testWidgets('renders a TextField wired to the controller', (tester) async {
      final controller = TextEditingController(text: 'SELECT 1');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(SqlTextField(controller: controller, onChanged: (_) {})),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('SELECT 1'), findsOneWidget);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller, same(controller));
      expect(field.minLines, 4);
      expect(field.maxLines, 10);
      expect(field.keyboardType, TextInputType.multiline);
      expect(field.textInputAction, TextInputAction.newline);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.smartDashesType, SmartDashesType.disabled);
      expect(field.smartQuotesType, SmartQuotesType.disabled);
    });

    testWidgets('forwards typed text to onChanged', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      String? captured;

      await tester.pumpWidget(
        _wrap(
          SqlTextField(
            controller: controller,
            onChanged: (value) => captured = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'DROP TABLE x');
      expect(captured, 'DROP TABLE x');
    });

    testWidgets(
      'borderColor null -> uses theme colorScheme.primary for the border',
      (tester) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);

        const primary = Color(0xFF00FF00);
        final theme = ThemeData(
          colorScheme: const ColorScheme.light(primary: primary),
        );

        await tester.pumpWidget(
          _wrap(
            SqlTextField(controller: controller, onChanged: (_) {}),
            theme: theme,
          ),
        );

        final field = tester.widget<TextField>(find.byType(TextField));
        final enabled = field.decoration!.enabledBorder! as OutlineInputBorder;
        final focused = field.decoration!.focusedBorder! as OutlineInputBorder;
        expect(enabled.borderSide.color, primary);
        expect(focused.borderSide.color, primary);
        expect(focused.borderSide.width, 2);
      },
    );

    testWidgets('borderColor provided -> overrides the theme primary', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      const custom = Color(0xFFAB12CD);
      final theme = ThemeData(
        colorScheme: const ColorScheme.light(primary: Color(0xFF00FF00)),
      );

      await tester.pumpWidget(
        _wrap(
          SqlTextField(
            controller: controller,
            onChanged: (_) {},
            borderColor: custom,
          ),
          theme: theme,
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      final enabled = field.decoration!.enabledBorder! as OutlineInputBorder;
      final focused = field.decoration!.focusedBorder! as OutlineInputBorder;
      expect(enabled.borderSide.color, custom);
      expect(focused.borderSide.color, custom);
    });

    testWidgets('respects an explicit maxLines override', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          SqlTextField(controller: controller, onChanged: (_) {}, maxLines: 6),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.maxLines, 6);
    });
  });
}
