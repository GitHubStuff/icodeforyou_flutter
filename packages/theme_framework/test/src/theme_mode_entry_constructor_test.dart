// packages/theme_framework/test/src/theme_mode_entry_constructor_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_widget/settings_widget.dart' show AppSettingsEntry;
import 'package:theme_framework/theme_framework.dart' show ThemeModeEntry;

void main() {
  group(ThemeModeEntry, () {
    // The constructor is const, and the existing widget tests construct
    // the entry with `const ThemeModeEntry()` — const construction is
    // compile-time canonicalization, so the constructor line records zero
    // LCOV hits. Binding the `.new` tear-off to a local and invoking it
    // guarantees runtime execution without tripping
    // `prefer_const_constructors` or `unnecessary_constructor_name`.
    const construct = ThemeModeEntry.new;

    test('constructs at runtime as an AppSettingsEntry', () {
      final entry = construct();

      expect(entry, isA<AppSettingsEntry>());
      expect(entry.key, isNull);
    });

    test('forwards the key to the superclass', () {
      const key = Key('theme-mode-entry');

      final entry = construct(key: key);

      expect(entry.key, same(key));
    });
  });
}
