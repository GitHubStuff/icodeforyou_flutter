// test/src/editor_text_field_test.dart
import 'package:edittext_popover/edittext_popover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditorTextField', () {
    testWidgets('renders with controller text', (tester) async {
      final controller = TextEditingController(text: 'hello');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(controller: controller),
          ),
        ),
      );

      expect(find.text('hello'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('applies decoration', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ),
        ),
      );

      expect(find.text('Notes'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('applies style', (tester) async {
      final controller = TextEditingController(text: 'styled');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(
              controller: controller,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.fontSize, equals(20));

      controller.dispose();
    });

    testWidgets('opens editor on tap', (tester) async {
      final controller = TextEditingController(text: 'tap me');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(controller: controller),
          ),
        ),
      );

      await tester.tap(find.byType(EditorTextField));
      await tester.pumpAndSettle();

      expect(find.text('SAVE'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('updates controller on save', (tester) async {
      final controller = TextEditingController(text: 'original');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(controller: controller),
          ),
        ),
      );

      await tester.tap(find.byType(EditorTextField));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'updated');
      await tester.pump();

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(controller.text, equals('updated'));

      controller.dispose();
    });

    testWidgets('preserves controller text on cancel', (tester) async {
      final controller = TextEditingController(text: 'original');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(controller: controller),
          ),
        ),
      );

      await tester.tap(find.byType(EditorTextField));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'modified');
      await tester.pump();

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(controller.text, equals('original'));

      controller.dispose();
    });

    testWidgets('calls onResult with EditorCompleted on save', (tester) async {
      final controller = TextEditingController(text: 'test');
      EditorResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(
              controller: controller,
              onResult: (r) => result = r,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EditorTextField));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(result, isA<EditorCompleted>());
      expect(result?.text, equals('test'));

      controller.dispose();
    });

    testWidgets('calls onResult with EditorDismissed on cancel', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'test');
      EditorResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(
              controller: controller,
              onResult: (r) => result = r,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EditorTextField));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(result, isA<EditorDismissed>());
      expect(result?.text, equals('test'));

      controller.dispose();
    });

    testWidgets('uses custom editor text style', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(
              controller: controller,
              editorTextStyle: const TextStyle(fontSize: 30),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EditorTextField));
      await tester.pumpAndSettle();

      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      final editorTextField = textFields.last;
      expect(editorTextField.style?.fontSize, equals(30));

      controller.dispose();
    });

    testWidgets('uses custom editor barrier color', (tester) async {
      final controller = TextEditingController();
      const customColor = Color(0x80FF0000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(
              controller: controller,
              editorBarrierColor: customColor,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EditorTextField));
      await tester.pumpAndSettle();

      final coloredBoxes = tester.widgetList<ColoredBox>(
        find.byType(ColoredBox),
      );
      final hasBarrierColor = coloredBoxes.any(
        (box) => box.color == customColor,
      );
      expect(hasBarrierColor, isTrue);

      controller.dispose();
    });

    testWidgets('uses custom save widget', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(
              controller: controller,
              editorSaveWidget: const Icon(Icons.done),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EditorTextField));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.done), findsOneWidget);

      controller.dispose();
    });

    testWidgets('uses custom cancel widget', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(
              controller: controller,
              editorCancelWidget: const Icon(Icons.clear),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EditorTextField));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.clear), findsOneWidget);

      controller.dispose();
    });

    testWidgets('text field is read only', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(controller: controller),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.readOnly, isTrue);

      controller.dispose();
    });
  });
}
