// packages/theme_framework/test/src/preferences/theme_storage_abstract_test.dart

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_framework/theme_framework.dart' show ThemeStorageAbstract;

/// A fake implementation to verify the [ThemeStorageAbstract] contract signatures.
class _FakeThemeStorage implements ThemeStorageAbstract {
  ThemeMode? _storedMode;

  @override
  Future<ThemeMode?> read() async => _storedMode;

  @override
  Future<void> write(ThemeMode mode) async {
    _storedMode = mode;
  }
}

void main() {
  group('ThemeStorageAbstract', () {
    test('can be implemented and its contract methods can be invoked', () async {
      final ThemeStorageAbstract storage = _FakeThemeStorage();

      // Verify the read signature returns a Future<ThemeMode?>
      final initialResult = await storage.read();
      expect(initialResult, isNull);

      // Verify the write signature accepts a ThemeMode and returns a Future<void>
      await storage.write(ThemeMode.system);

      final updatedResult = await storage.read();
      expect(updatedResult, ThemeMode.system);
    });
  });
}
