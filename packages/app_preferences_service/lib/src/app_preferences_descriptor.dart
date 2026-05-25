// app_preferences_service/lib/src/app_preferences_descriptor.dart
// ignore_for_file: always_use_package_imports, public_member_api_docs
import 'dart:async';

import 'package:app_preferences/app_preferences.dart'
    show
        AbstractPreferencesInterface,
        HiveInitMode,
        HivePreferences,
        MockPreferences,
        PlatformPreferences;
import 'package:flutter/foundation.dart' show protected, visibleForTesting;
import 'package:service_locator/service_locator.dart'
    show LazyAsyncServiceDescriptor, ServiceItemTimeout;

import 'app_preferences.dart';

/// Backend selector for [AppPreferencesDescriptor].
enum AppPreferencesBackend {
  /// `SharedPreferencesAsync` — platform-native, no cache.
  platform,

  /// `hive_ce` — Dart-native, file-backed.
  hive,

  /// In-memory mock — test/dev only, no persistence.
  mock,
}

/// Service-locator descriptor for [AppPreferences].
///
/// Builds a [PlatformPreferences], [HivePreferences], or [MockPreferences]
/// and wraps it in a service handle. The Hive variants additionally
/// initialize Hive against the chosen storage location and open the
/// named box.
class AppPreferencesDescriptor
    extends LazyAsyncServiceDescriptor<AppPreferences> {
  /// Platform-backed descriptor (`SharedPreferencesAsync`).
  const AppPreferencesDescriptor.platform({
    String serviceName = 'AppPreferences',
  }) : backend = AppPreferencesBackend.platform,
       name = serviceName,
       hiveBoxName = null,
       hiveInitMode = null,
       hiveCustomPath = null,
       mockInitialValues = null;

  /// Hive-backed descriptor.
  ///
  /// [boxName] names the Hive box that stores preferences.
  /// [initMode] selects the storage location (see [HiveInitMode]).
  /// [customPath] is required when [initMode] is [HiveInitMode.custom].
  const AppPreferencesDescriptor.hive({
    required String boxName,
    String serviceName = 'AppPreferences',
    HiveInitMode initMode = HiveInitMode.productionDocuments,
    String? customPath,
  }) : backend = AppPreferencesBackend.hive,
       name = serviceName,
       hiveBoxName = boxName,
       hiveInitMode = initMode,
       hiveCustomPath = customPath,
       mockInitialValues = null;

  /// Mock descriptor — in-memory store for tests and dev harnesses.
  ///
  /// [initialValues] optionally seeds the store at construction.
  const AppPreferencesDescriptor.mock({
    String serviceName = 'AppPreferences',
    Map<String, Object?>? initialValues,
  }) : backend = AppPreferencesBackend.mock,
       name = serviceName,
       hiveBoxName = null,
       hiveInitMode = null,
       hiveCustomPath = null,
       mockInitialValues = initialValues;

  final AppPreferencesBackend backend;
  final String? hiveBoxName;
  final HiveInitMode? hiveInitMode;
  final String? hiveCustomPath;
  final Map<String, Object?>? mockInitialValues;

  @override
  final String name;

  @override
  List<Type> get dependencies => const [];

  @override
  Duration get timeout => const Duration(milliseconds: 500);

  @override
  Future<AppPreferences> Function() get builder => () async {
    try {
      final prefs = await build().timeout(timeout);
      return AppPreferences(prefs);
    } on TimeoutException {
      throw ServiceItemTimeout(name, timeout);
    }
  };

  // ───── Internals ─────

  /// Builds the underlying preferences instance for the selected [backend].
  ///
  /// Exposed as `@protected` and `@visibleForTesting` so subclasses can
  /// substitute a slow or failing implementation to exercise the timeout
  /// branch in [builder].
  @protected
  @visibleForTesting
  Future<AbstractPreferencesInterface> build() {
    switch (backend) {
      case AppPreferencesBackend.platform:
        return PlatformPreferences.create();
      case AppPreferencesBackend.hive:
        return _buildHive();
      case AppPreferencesBackend.mock:
        return Future.value(
          MockPreferences(initialValues: mockInitialValues),
        );
    }
  }

  Future<HivePreferences> _buildHive() async {
    await HivePreferences.init(
      mode: hiveInitMode!,
      customPath: hiveCustomPath,
    );
    return HivePreferences.create(boxName: hiveBoxName!);
  }
}
