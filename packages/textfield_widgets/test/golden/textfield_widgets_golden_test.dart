// packages/textfield_widgets/test/golden/textfield_widgets_golden_test.dart

import 'package:test/test.dart';
import '../../lib/textfield_widgets.dart' show TextfieldWidgets;

void main() {
  group(TextfieldWidgets, () {
    test('can be instantiated', () =>
      expect(TextfieldWidgets(), isNotNull)
    );
  });
}
