// packages/sincewhen_widgets/test/src/glossary_edits/cubit/glossary_edit_state_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_widgets/src/glossary_edits/cubit/glossary_edit_state.dart';

void main() {
  group('GlossaryEditInitial', () {
    test('supports value equality', () {
      expect(
        const GlossaryEditInitial(),
        equals(const GlossaryEditInitial()),
      );
    });

    test('props are empty', () {
      expect(const GlossaryEditInitial().props, isEmpty);
    });
  });
}
