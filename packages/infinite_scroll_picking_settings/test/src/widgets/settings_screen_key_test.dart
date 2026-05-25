// infinite_scroll_picking_settings/test/src/widgets/settings_screen_key_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/widgets/settings_screen.dart';

void main() {
  group('SettingsScreen constructor', () {
    test('forwards key to super', () {
      const key = ValueKey('settings_screen');

      const screen = SettingsScreen(key: key);

      expect(screen.key, same(key));
    });
  });
}
