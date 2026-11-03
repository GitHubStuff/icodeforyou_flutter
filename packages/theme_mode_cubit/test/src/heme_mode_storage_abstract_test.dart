// test/src/theme_mode_storage_abstract_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_mode_cubit/src/theme_mode_storage_abstract.dart'
    show ThemeModeStorageAbstract;

/// Test implementation to execute and verify the interface contracts.
class FakeThemeModeStorage extends ThemeModeStorageAbstract {
  ThemeMode _mode = ThemeMode.system;

  @override
  Future<ThemeMode> read() async => _mode;

  @override
  Future<void> write(ThemeMode newMode) async {
    _mode = newMode;
  }
}

void main() {
  group('ThemeModeStorageAbstract', () {
    test('can be implemented and executes read and write contracts', () async {
      final storage = FakeThemeModeStorage();

      expect(await storage.read(), equals(ThemeMode.system));

      await storage.write(ThemeMode.dark);
      expect(await storage.read(), equals(ThemeMode.dark));

      await storage.write(ThemeMode.light);
      expect(await storage.read(), equals(ThemeMode.light));
    });
  });
}
