// packages/custom_widgets/test/src/textfield/input_field_test.dart

import 'package:custom_widgets/custom_widgets.dart' show InputField;
import 'package:custom_widgets/src/textfield/_suffix_slot.dart'
    show SuffixSlot;
import 'package:extensions/enum/src/window_size_category.dart'
    show WindowSizeCategory;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Caller-owned lifecycle objects for the field under test.
final class _Harness {
  /// Creates the harness and registers disposal with [tester]'s teardown.
  _Harness() {
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
  }

  /// The caller-owned text controller.
  final TextEditingController controller = TextEditingController();

  /// The caller-owned focus node.
  final FocusNode focusNode = FocusNode();
}

/// Pumps [field] inside a Material scaffold.
Future<void> _pump(WidgetTester tester, InputField field) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: field))),
  );
}

void main() {
  group('InputField', () {
    testWidgets('sizes its width from the window size category',
        (tester) async {
      final harness = _Harness();

      await _pump(
        tester,
        InputField(
          controller: harness.controller,
          focusNode: harness.focusNode,
          windowSizeCategory: WindowSizeCategory.compact,
        ),
      );

      final box = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(TextField),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(box.width, WindowSizeCategory.compact.upperBound);
    });

    testWidgets('applies its no-noise defaults and reserves the helper line',
        (tester) async {
      final harness = _Harness();

      await _pump(
        tester,
        InputField(
          controller: harness.controller,
          focusNode: harness.focusNode,
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.maxLines, 1);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.decoration!.helperText, ' ');
      expect(field.decoration!.border, const OutlineInputBorder());
      expect(field.decoration!.suffixIcon, isNull);
      expect(field.decoration!.errorText, isNull);
    });

    testWidgets('forwards label, error, keyboard type, and max lines',
        (tester) async {
      final harness = _Harness();

      await _pump(
        tester,
        InputField(
          controller: harness.controller,
          focusNode: harness.focusNode,
          label: 'Email',
          errorText: 'Required',
          textInputType: TextInputType.emailAddress,
          maxLines: 3,
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration!.labelText, 'Email');
      expect(field.decoration!.errorText, 'Required');
      expect(field.keyboardType, TextInputType.emailAddress);
      expect(field.maxLines, 3);
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('routes a suffix through the shared slot with its '
        'constraints', (tester) async {
      final harness = _Harness();

      await _pump(
        tester,
        InputField(
          controller: harness.controller,
          focusNode: harness.focusNode,
          suffixWidget: const Icon(Icons.clear),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(SuffixSlot),
          matching: find.byIcon(Icons.clear),
        ),
        findsOneWidget,
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration!.suffixIconConstraints, SuffixSlot.constraints);
    });

    testWidgets('writes through the caller-owned controller',
        (tester) async {
      final harness = _Harness();

      await _pump(
        tester,
        InputField(
          controller: harness.controller,
          focusNode: harness.focusNode,
        ),
      );

      await tester.enterText(find.byType(TextField), 'hello');

      expect(harness.controller.text, 'hello');
    });
  });
}
