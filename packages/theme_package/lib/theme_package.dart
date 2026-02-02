// lib/theme_package.dart
library;

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'src/error.dart';
part 'src/constants.dart';
part 'src/datasource.dart';
part 'src/state.dart';
part 'src/cubit.dart';
part 'src/root_widget.dart';
part 'src/selector_widget.dart';
part 'src/builder_widget.dart';

/// Static API for theme management.
///
/// ## Option A: Use ThemePackageRoot (recommended)
/// ```dart
/// void main() {
///   runApp(
///     ThemePackageRoot(
///       databaseName: 'abc123def456ghi78901',
///       splash: MySplashWidget(),
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
///
/// ## Option B: Initialize manually for early access
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await ThemePackage.initialize(databaseName: 'abc123def456ghi78901');
///   runApp(
///     ThemePackageRoot(
///       splash: MySplashWidget(),
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
///
/// ## Option C: In-memory mode for testing/Widgetbook
/// ```dart
/// await ThemePackage.initialize(
///   databaseName: 'test_db_12345678901',
///   inMemory: true,
/// );
/// ```
abstract final class ThemePackage {
  static _ThemeCubit? _cubit;
  static _ThemeLocalDatasource? _datasource;
  static bool _initialized = false;

  /// Allows injection of a custom datasource factory for testing.
  @visibleForTesting
  static Future<Either<ThemeError, Unit>> Function()? testDatasourceInitializer;

  /// Forces setTheme to fail for testing error paths.
  @visibleForTesting
  static bool forceSetThemeFailure = false;

  /// Returns true if the package has been initialized.
  static bool get isInitialized => _initialized;

  /// Returns the current [ThemeMode].
  ///
  /// Throws [StateError] if [initialize] has not been called.
  static ThemeMode get currentTheme {
    _assertInitialized();
    return _cubit!.state.themeMode;
  }

  /// Initializes the theme package.
  ///
  /// [databaseName] must be exactly 20 valid filename characters.
  /// Valid characters: a-z, A-Z, 0-9, underscore, hyphen.
  ///
  /// [subDirectory] optional path relative to app documents directory.
  /// Defaults to 'db'.
  ///
  /// [customPath] optional custom base path. If provided, bypasses
  /// path_provider. Useful for platforms where path_provider is unavailable.
  ///
  /// [inMemory] if true, uses in-memory storage instead of Hive.
  /// Useful for testing, Widgetbook, or environments without file system access.
  /// Defaults to false.
  ///
  /// Returns [Either<ThemeError, Unit>] indicating success or failure.
  static Future<Either<ThemeError, Unit>> initialize({
    required String databaseName,
    String subDirectory = 'db',
    String? customPath,
    bool inMemory = false,
  }) async {
    if (_initialized) {
      return const Right(unit);
    }

    _validateDatabaseName(databaseName);

    try {
      // Allow test injection of datasource initializer
      if (testDatasourceInitializer != null) {
        final result = await testDatasourceInitializer!();
        return result.fold(
          (error) => Left(error),
          (_) {
            _initialized = true;
            return const Right(unit);
          },
        );
      }

      _datasource = _ThemeLocalDatasource(
        databaseName: databaseName,
        subDirectory: subDirectory,
        customPath: customPath,
        inMemory: inMemory,
      );

      final initResult = await _datasource!.initialize();

      return initResult.fold(
        (error) => Left(error),
        (_) {
          final savedMode = _datasource!.getThemeMode();
          _cubit = _ThemeCubit(
            datasource: _datasource!,
            initialMode: savedMode,
          );
          _initialized = true;
          return const Right(unit);
        },
      );
    } catch (e) {
      return Left(ThemeError.initializationFailed(e.toString()));
    }
  }

  /// Sets the theme mode and persists it.
  ///
  /// Returns [Either<ThemeError, Unit>] indicating success or failure.
  static Future<Either<ThemeError, Unit>> setTheme(ThemeMode mode) async {
    _assertInitialized();
    return _cubit!.setTheme(mode);
  }

  /// Returns the persisted [ThemeMode] from storage.
  ///
  /// Throws [StateError] if [initialize] has not been called.
  static ThemeMode getTheme() {
    _assertInitialized();
    return _datasource!.getThemeMode();
  }

  /// Resets the package state. Primarily for testing.
  @visibleForTesting
  static void reset() {
    _cubit = null;
    _datasource = null;
    _initialized = false;
    testDatasourceInitializer = null;
    forceSetThemeFailure = false;
  }

  static void _assertInitialized() {
    if (!_initialized || _cubit == null || _datasource == null) {
      throw StateError(
        'ThemePackage has not been initialized. '
        'Call ThemePackage.initialize() or use ThemePackageRoot widget.',
      );
    }
  }

  static void _validateDatabaseName(String name) {
    if (name.length != 20) {
      throw ArgumentError(
        'databaseName must be exactly 20 characters. '
        'Received ${name.length} characters: "$name"',
      );
    }

    final validPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!validPattern.hasMatch(name)) {
      throw ArgumentError(
        'databaseName contains invalid characters. '
        'Only a-z, A-Z, 0-9, underscore, and hyphen are allowed. '
        'Received: "$name"',
      );
    }
  }
}
