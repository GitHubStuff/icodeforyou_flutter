// packages/custom_widgets/test/src/textfield/password_field_test.dart

import 'package:custom_widgets/custom_widgets.dart' show PasswordField;
import 'package:custom_widgets/src/textfield/_suffix_slot.dart' show SuffixSlot;
import 'package:extensions/enum/src/window_size_category.dart'
    show WindowSizeCategory;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The icon shown while the text is hidden.
const Key _kShowKey = Key('show-icon');

/// The icon shown while the text is revealed.
const Key _kHideKey = Key('hide-icon');

/// Caller-owned lifecycle objects for the field under test.
final class _Harness {
  /// Creates the harness and registers disposal with the test teardown.
  _Harness() {
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
  }

  /// The caller-owned text controller.
  final TextEditingController controller = TextEditingController();

  /// The caller-owned focus node.
  final FocusNode focusNode = FocusNode();
}

/// Pumps a [PasswordField] built from [harness] inside a Material scaffold.
Future<void> _pump(
  WidgetTester tester,
  _Harness harness, {
  String? label,
  String? errorText,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: PasswordField(
            controller: harness.controller,
            focusNode: harness.focusNode,
            showTextIcon: const Icon(Icons.visibility, key: _kShowKey),
            hideTextIcon: const Icon(Icons.visibility_off, key: _kHideKey),
            label: label,
            errorText: errorText,
          ),
        ),
      ),
    ),
  );
}

/// Taps the reveal/hide toggle in the suffix slot.
Future<void> _tapToggle(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(SuffixSlot),
      matching: find.byType(GestureDetector),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PasswordField', () {
    testWidgets('starts obscured, single-line, showing the reveal icon', (
      tester,
    ) async {
      final harness = _Harness();
      await _pump(tester, harness);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
      expect(field.maxLines, 1);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(find.byKey(_kShowKey), findsOneWidget);
      expect(find.byKey(_kHideKey), findsNothing);
    });

    testWidgets('announces the toggle action for accessibility', (
      tester,
    ) async {
      // Disposed inside the test body: flutter_test verifies that no
      // SemanticsHandle is still active before addTearDown callbacks
      // run, so a teardown-based dispose fires too late.
      final handle = tester.ensureSemantics();
      final harness = _Harness();
      await _pump(tester, harness);

      expect(find.bySemanticsLabel('Show password'), findsOneWidget);

      await _tapToggle(tester);

      expect(find.bySemanticsLabel('Hide password'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('tapping the toggle reveals, refocuses, and parks the caret', (
      tester,
    ) async {
      final harness = _Harness();
      harness.controller.text = 'secret';
      await _pump(tester, harness);

      await _tapToggle(tester);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isFalse);
      expect(field.maxLines, isNull);
      expect(find.byKey(_kHideKey), findsOneWidget);
      expect(harness.focusNode.hasFocus, isTrue);
      expect(
        harness.controller.selection,
        const TextSelection.collapsed(offset: 6),
      );
    });

    testWidgets('tapping the toggle again re-obscures', (tester) async {
      final harness = _Harness();
      await _pump(tester, harness);

      await _tapToggle(tester);
      await _tapToggle(tester);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
      expect(find.byKey(_kShowKey), findsOneWidget);
    });

    testWidgets('forwards label and error, reserving the helper line', (
      tester,
    ) async {
      final harness = _Harness();
      await _pump(tester, harness, label: 'Password', errorText: 'Too short');

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration!.labelText, 'Password');
      expect(field.decoration!.errorText, 'Too short');
      expect(field.decoration!.helperText, ' ');
      expect(field.decoration!.suffixIconConstraints, SuffixSlot.constraints);
    });

    testWidgets('sizes its width from the window size category', (
      tester,
    ) async {
      final harness = _Harness();
      await _pump(tester, harness);

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
  });
}
