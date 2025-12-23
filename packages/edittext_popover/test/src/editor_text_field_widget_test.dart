// test/src/editor_text_field_widget_test.dart
import 'package:edittext_popover/src/_editor_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditorTextFieldWidget', () {
    testWidgets('renders with controller text', (tester) async {
      final controller = TextEditingController(text: 'hello');
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextFieldWidget(
              controller: controller,
              focusNode: focusNode,
              textStyle: const TextStyle(fontSize: 18),
              height: 200,
            ),
          ),
        ),
      );

      expect(find.text('hello'), findsOneWidget);

      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextFieldWidget(
              controller: controller,
              focusNode: focusNode,
              textStyle: const TextStyle(fontSize: 18),
              height: 200,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'new text');
      await tester.pump();

      expect(controller.text, equals('new text'));

      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('accepts multiline input', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextFieldWidget(
              controller: controller,
              focusNode: focusNode,
              textStyle: const TextStyle(fontSize: 18),
              height: 200,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'line1\nline2');
      await tester.pump();

      expect(controller.text, equals('line1\nline2'));

      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('respects provided height', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextFieldWidget(
              controller: controller,
              focusNode: focusNode,
              textStyle: const TextStyle(fontSize: 18),
              height: 300,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(TextField),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.height, equals(300));

      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('applies text style', (tester) async {
      final controller = TextEditingController(text: 'styled');
      final focusNode = FocusNode();
      const testStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextFieldWidget(
              controller: controller,
              focusNode: focusNode,
              textStyle: testStyle,
              height: 200,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.fontSize, equals(24));
      expect(textField.style?.fontWeight, equals(FontWeight.bold));

      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('uses theme colors', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          home: Scaffold(
            body: EditorTextFieldWidget(
              controller: controller,
              focusNode: focusNode,
              textStyle: const TextStyle(fontSize: 18),
              height: 200,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.filled, isTrue);

      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('focusNode receives focus', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextFieldWidget(
              controller: controller,
              focusNode: focusNode,
              textStyle: const TextStyle(fontSize: 18),
              height: 200,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);

      controller.dispose();
      focusNode.dispose();
    });
  });
}
