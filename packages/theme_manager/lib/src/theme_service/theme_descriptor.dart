// theme_manager/lib/src/theme_service/theme_descriptor.dart

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:app_preferences/app_preferences.dart'
    show AbstractPreferencesInterface;
import 'package:app_preferences_service/app_preferences_service.dart'
    show AppPreferences;
import 'package:flutter/material.dart';
import 'package:my_logger/my_logger.dart' show MyLogger;
import 'package:service_locator/service_locator.dart'
    show AsyncServiceDescriptor, ServiceItemTimeout, ServiceRegistry;
import 'package:theme_manager/src/theme_service/theme_service.dart'
    show ThemeService;
import 'package:theme_manager/theme_manager.dart'
    show MaterialTheme, MaterialThemeCubit, ThemePersistence;

/// Resolves an [AppPreferences] instance by name from the service registry.
typedef AppPreferencesResolver =
    Future<AppPreferences> Function(String name);

/// Builds a [ThemePersistence] over the given preferences interface.
typedef ThemePersistenceFactory =
    Future<ThemePersistence> Function(AbstractPreferencesInterface prefs);

class ThemeDescriptor extends AsyncServiceDescriptor<ThemeService> {
  ThemeDescriptor({
    required this.name,
    this.dark,
    this.light,
    AppPreferencesResolver? appPreferencesResolver,
    ThemePersistenceFactory? themePersistenceFactory,
  }) : _appPreferencesResolver =
           appPreferencesResolver ?? defaultAppPreferencesResolver,
       _themePersistenceFactory =
           themePersistenceFactory ?? ThemePersistence.create;

  ThemeData? dark;
  ThemeData? light;

  final AppPreferencesResolver _appPreferencesResolver;
  final ThemePersistenceFactory _themePersistenceFactory;

  /// Production [AppPreferencesResolver] used when none is injected.
  ///
  /// Delegates to the global [ServiceRegistry] singleton. Exposed for
  /// direct unit testing so the seam can be covered without coupling
  /// tests to the global registry through [ThemeDescriptor]'s builder.
  @visibleForTesting
  static Future<AppPreferences> defaultAppPreferencesResolver(String name) =>
      ServiceRegistry.R.getAsync<AppPreferences>(name);

  @override
  final String name;

  @override
  List<Type> get dependencies => [AppPreferences];

  @override
  Duration get timeout => const Duration(milliseconds: 250);

  @override
  Future<ThemeService> Function() get builder => () async {
    try {
      // AppPreferences is registered as LazyAsync. Its builder is staged
      // by the registry's dependency resolution but not fired until the
      // first getAsync — so use getAsync, not getSync. getSync would
      // throw ServiceNotReady because the lazy hasn't materialized yet.
      final appPrefs = await _appPreferencesResolver('AppPreferences');
      late final ThemePersistence store;

      try {
        store = await _themePersistenceFactory(appPrefs.prefs).timeout(timeout);
      } on TimeoutException {
        throw ServiceItemTimeout(name, timeout);
      }

      final mode = await store.load();
      final MaterialTheme theme = MaterialTheme(
        mode: mode,
        dark: dark,
        light: light,
      );
      final cubit = MaterialThemeCubit(
        theme: theme,
        themeModeStorage: store,
      );
      return ThemeService(cubit);
      //
    } catch (error, stackTrace) {
      // Get-it's `registerServiceAsync` swallows builder errors with an
      // empty `catch (e) {}` and only surfaces the registration as "not
      // ready" — losing the real cause. Log here so the original
      // exception lands in console output before the registry's
      // canonical wrapping.
      MyLogger.e(
        'ThemeDescriptor builder failed: $error',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  };
}
