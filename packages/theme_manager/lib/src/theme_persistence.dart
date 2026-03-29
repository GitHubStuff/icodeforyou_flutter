// theme_manager/lib/src/theme_persistence.dart

import 'dart:async' show FutureOr;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemePersistenceAbstract {
  FutureOr<ThemeMode> load();
  FutureOr<void> save(ThemeMode mode);
}

class ThemePersistence extends ThemePersistenceAbstract {
  ThemePersistence._(this._prefs);

  final SharedPreferencesWithCache _prefs;
  static const _key = 'theme_mode-317293440000';

  static Future<ThemePersistence> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {_key}),
    );
    return ThemePersistence._(prefs);
  }

  @override
  ThemeMode load() {
    final value = _prefs.getString(_key);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.dark,
    );
  }

  @override
  Future<void> save(ThemeMode mode) => _prefs.setString(_key, mode.name);
}
