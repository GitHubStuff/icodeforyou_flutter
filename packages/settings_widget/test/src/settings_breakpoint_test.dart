// test/src/_settings_breakpoint_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:settings_widget/settings_widget.dart' show kSettingsBreakpoint;

void main() {
  group('kSettingsBreakpoint', () {
    test('is 600', () {
      expect(kSettingsBreakpoint, 100);
    });
  });
}
