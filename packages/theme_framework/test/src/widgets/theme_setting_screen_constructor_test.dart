// packages/theme_framework/test/src/widgets/theme_setting_screen_constructor_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_framework/theme_framework.dart' show ThemeSettingScreen;

void main() {
  group(ThemeSettingScreen, () {
    // The constructor is const, and the existing widget tests construct
    // the screen with `const ThemeSettingScreen()` — const construction is
    // compile-time canonicalization, so the constructor line records zero
    // LCOV hits. Binding the `.new` tear-off to a local and invoking it
    // guarantees runtime execution without tripping
    // `prefer_const_constructors` or `unnecessary_constructor_name`.
    const construct = ThemeSettingScreen.new;

    test('constructs at runtime with an empty actions slot', () {
      final screen = construct();

      expect(screen.actions, isNull);
      expect(screen.key, isNull);
    });

    test('stores the app bar actions it was created with', () {
      final actions = <Widget>[const Icon(Icons.info_outline)];

      final screen = construct(actions: actions);

      expect(screen.actions, same(actions));
    });

    test('forwards the key to the superclass', () {
      const key = Key('theme-setting-screen');

      final screen = construct(key: key);

      expect(screen.key, same(key));
    });
  });
}
