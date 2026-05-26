// packages/custom_widgets/test/src/expanding_textfield_test.dart
// ignore_for_file: public_member_api_docs
import 'package:custom_widgets/src/expanding_textfield/expanding_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TextEditingController controller;
  late FocusNode focusNode;

  setUp(() {
    controller = TextEditingController();
    focusNode = FocusNode();
  });

  tearDown(() {
    controller.dispose();
    focusNode.dispose();
  });

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  TextField findTextField(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField));

  group('ExpandingTextField construction', () {
    testWidgets('builds with required parameters only', (tester) async {
      await tester.pumpWidget(
        wrap(ExpandingTextField(controller: controller, onChanged: (_) {})),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('applies default min and max lines', (tester) async {
      await tester.pumpWidget(
        wrap(ExpandingTextField(controller: controller, onChanged: (_) {})),
      );

      final field = findTextField(tester);
      expect(field.minLines, 4);
      expect(field.maxLines, 10);
    });

    testWidgets('applies custom min and max lines', (tester) async {
      await tester.pumpWidget(
        wrap(
          ExpandingTextField(
            controller: controller,
            onChanged: (_) {},
            minLines: 2,
            maxLines: 6,
          ),
        ),
      );

      final field = findTextField(tester);
      expect(field.minLines, 2);
      expect(field.maxLines, 6);
    });

    testWidgets('accepts null maxLines', (tester) async {
      await tester.pumpWidget(
        wrap(
          ExpandingTextField(
            controller: controller,
            onChanged: (_) {},
            maxLines: null,
          ),
        ),
      );

      final field = findTextField(tester);
      expect(field.maxLines, isNull);
    });
  });

  group('ExpandingTextField assertions', () {
    test('throws when maxLines less than minLines', () {
      expect(
        () => ExpandingTextField(
          controller: TextEditingController(),
          onChanged: (_) {},
          minLines: 5,
          maxLines: 3,
        ),
        throwsAssertionError,
      );
    });

    test('throws when minLines less than 1', () {
      expect(
        () => ExpandingTextField(
          controller: TextEditingController(),
          onChanged: (_) {},
          minLines: 0,
        ),
        throwsAssertionError,
      );
    });

    test('allows null maxLines past minLines check', () {
      expect(
        () => ExpandingTextField(
          controller: TextEditingController(),
          onChanged: (_) {},
          minLines: 5,
          maxLines: null,
        ),
        returnsNormally,
      );
    });

    test('allows equal min and max lines', () {
      expect(
        () => ExpandingTextField(
          controller: TextEditingController(),
          onChanged: (_) {},
          minLines: 4,
          maxLines: 4,
        ),
        returnsNormally,
      );
    });
  });

  group('ExpandingTextField styling', () {
    testWidgets('applies default text style when none provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(ExpandingTextField(controller: controller, onChanged: (_) {})),
      );

      final field = findTextField(tester);
      expect(field.style?.fontFamily, 'monospace');
      expect(field.style?.fontSize, 18);
      expect(field.style?.fontWeight, FontWeight.bold);
      expect(field.style?.height, 1.4);
    });

    testWidgets('applies custom text style when provided', (tester) async {
      const custom = TextStyle(fontSize: 24, color: Colors.red);
      await tester.pumpWidget(
        wrap(
          ExpandingTextField(
            controller: controller,
            onChanged: (_) {},
            textStyle: custom,
          ),
        ),
      );

      final field = findTextField(tester);
      expect(field.style?.fontSize, 24);
      expect(field.style?.color, Colors.red);
    });

    testWidgets('uses theme primary color when borderColor is null', (
      tester,
    ) async {
      const primary = Color(0xFF123456);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(primary: primary),
          ),
          home: Scaffold(
            body: ExpandingTextField(controller: controller, onChanged: (_) {}),
          ),
        ),
      );

      final field = findTextField(tester);
      final decoration = field.decoration!;
      final enabled = decoration.enabledBorder! as OutlineInputBorder;
      final focused = decoration.focusedBorder! as OutlineInputBorder;
      expect(enabled.borderSide.color, primary);
      expect(focused.borderSide.color, primary);
    });

    testWidgets('uses borderColor when provided', (tester) async {
      const border = Color(0xFFABCDEF);
      await tester.pumpWidget(
        wrap(
          ExpandingTextField(
            controller: controller,
            onChanged: (_) {},
            borderColor: border,
          ),
        ),
      );

      final field = findTextField(tester);
      final decoration = field.decoration!;
      final enabled = decoration.enabledBorder! as OutlineInputBorder;
      final focused = decoration.focusedBorder! as OutlineInputBorder;
      expect(enabled.borderSide.color, border);
      expect(focused.borderSide.color, border);
    });

    testWidgets('focused border uses width 2', (tester) async {
      await tester.pumpWidget(
        wrap(ExpandingTextField(controller: controller, onChanged: (_) {})),
      );

      final field = findTextField(tester);
      final focused = field.decoration!.focusedBorder! as OutlineInputBorder;
      expect(focused.borderSide.width, 2);
    });

    testWidgets('applies content padding', (tester) async {
      await tester.pumpWidget(
        wrap(ExpandingTextField(controller: controller, onChanged: (_) {})),
      );

      final field = findTextField(tester);
      expect(
        field.decoration!.contentPadding,
        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      );
    });
  });

  group('ExpandingTextField configuration', () {
    testWidgets('applies hintText', (tester) async {
      await tester.pumpWidget(
        wrap(
          ExpandingTextField(
            controller: controller,
            onChanged: (_) {},
            hintText: 'Type here',
          ),
        ),
      );

      final field = findTextField(tester);
      expect(field.decoration!.hintText, 'Type here');
    });

    testWidgets('defaults keyboardType to multiline', (tester) async {
      await tester.pumpWidget(
        wrap(ExpandingTextField(controller: controller, onChanged: (_) {})),
      );

      final field = findTextField(tester);
      expect(field.keyboardType, TextInputType.multiline);
    });

    testWidgets('applies custom keyboardType', (tester) async {
      await tester.pumpWidget(
        wrap(
          ExpandingTextField(
            controller: controller,
            onChanged: (_) {},
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      );

      final field = findTextField(tester);
      expect(field.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('attaches focusNode', (tester) async {
      await tester.pumpWidget(
        wrap(
          ExpandingTextField(
            controller: controller,
            onChanged: (_) {},
            focusNode: focusNode,
          ),
        ),
      );

      final field = findTextField(tester);
      expect(field.focusNode, focusNode);
    });

    testWidgets('attaches controller', (tester) async {
      await tester.pumpWidget(
        wrap(ExpandingTextField(controller: controller, onChanged: (_) {})),
      );

      final field = findTextField(tester);
      expect(field.controller, controller);
    });

    testWidgets('fires onChanged with entered text', (tester) async {
      var captured = '';
      await tester.pumpWidget(
        wrap(
          ExpandingTextField(
            controller: controller,
            onChanged: (value) => captured = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      expect(captured, 'hello');
    });

    testWidgets('disables autocorrect and suggestions', (tester) async {
      await tester.pumpWidget(
        wrap(ExpandingTextField(controller: controller, onChanged: (_) {})),
      );

      final field = findTextField(tester);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.smartDashesType, SmartDashesType.disabled);
      expect(field.smartQuotesType, SmartQuotesType.disabled);
    });

    testWidgets('sets textInputAction and capitalization', (tester) async {
      await tester.pumpWidget(
        wrap(ExpandingTextField(controller: controller, onChanged: (_) {})),
      );

      final field = findTextField(tester);
      expect(field.textInputAction, TextInputAction.newline);
      expect(field.textCapitalization, TextCapitalization.none);
    });
  });
}
