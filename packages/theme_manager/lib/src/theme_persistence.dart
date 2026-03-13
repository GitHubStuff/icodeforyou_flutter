// lib/src/theme_persistence.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePersistence {
  ThemePersistence(this._prefs);

  final SharedPreferencesWithCache _prefs;
  static const _key = 'theme_mode';

  static Future<ThemePersistence> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {_key},
      ),
    );
    return ThemePersistence(prefs);
  }

  ThemeMode load() {
    final value = _prefs.getString(_key);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.dark,
    );
  }

  Future<void> save(ThemeMode mode) => _prefs.setString(_key, mode.name);
}
