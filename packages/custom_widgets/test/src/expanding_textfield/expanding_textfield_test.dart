// packages/custom_widgets/test/src/expanding_textfield/expanding_textfield_test.dart

import 'package:custom_widgets/custom_widgets.dart' show ExpandingTextField;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [field] inside a Material scaffold and returns the theme in use.
Future<ThemeData> _pump(WidgetTester tester, Widget field) async {
  final theme = ThemeData();
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Theme(data: theme, child: field))),
  );
  return theme;
}

void main() {
  group('ExpandingTextField', () {
    testWidgets('applies its multiline defaults', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        ExpandingTextField(controller: controller, onChanged: (_) {}),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.minLines, 4);
      expect(field.maxLines, 10);
      expect(field.keyboardType, TextInputType.multiline);
      expect(field.autofocus, isTrue);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.textInputAction, TextInputAction.newline);
      expect(field.style!.fontFamily, 'monospace');
      expect(field.style!.fontSize, 18);
      expect(field.style!.fontWeight, FontWeight.bold);
    });

    testWidgets('honours custom lines, style, and hint', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      const style = TextStyle(fontSize: 12);

      await _pump(
        tester,
        ExpandingTextField(
          controller: controller,
          onChanged: (_) {},
          minLines: 2,
          maxLines: null,
          textStyle: style,
          hintText: 'type here',
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.minLines, 2);
      expect(field.maxLines, isNull);
      expect(field.style, style);
      expect(field.decoration!.hintText, 'type here');
    });

    testWidgets('defaults the border color to the theme primary',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      final theme = await _pump(
        tester,
        ExpandingTextField(controller: controller, onChanged: (_) {}),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      final enabled = field.decoration!.enabledBorder! as OutlineInputBorder;
      final focused = field.decoration!.focusedBorder! as OutlineInputBorder;
      expect(enabled.borderSide.color, theme.colorScheme.primary);
      expect(focused.borderSide.color, theme.colorScheme.primary);
      expect(focused.borderSide.width, 2);
    });

    testWidgets('uses a supplied border color', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        ExpandingTextField(
          controller: controller,
          onChanged: (_) {},
          borderColor: Colors.teal,
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      final enabled = field.decoration!.enabledBorder! as OutlineInputBorder;
      expect(enabled.borderSide.color, Colors.teal);
    });

    testWidgets('forwards text input to onChanged', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      String? received;

      await _pump(
        tester,
        ExpandingTextField(
          controller: controller,
          onChanged: (value) => received = value,
        ),
      );

      await tester.enterText(find.byType(TextField), 'hello');

      expect(received, 'hello');
      expect(controller.text, 'hello');
    });

    test('asserts when maxLines is less than minLines', () {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      expect(
        () => ExpandingTextField(
          controller: controller,
          onChanged: (_) {},
          minLines: 4,
          maxLines: 2,
        ),
        throwsAssertionError,
      );
    });

    test('asserts when minLines is below one', () {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      expect(
        () => ExpandingTextField(
          controller: controller,
          onChanged: (_) {},
          minLines: 0,
        ),
        throwsAssertionError,
      );
    });
  });
}
