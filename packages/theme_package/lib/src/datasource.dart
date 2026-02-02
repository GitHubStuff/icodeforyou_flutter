// lib/src/datasource.dart
part of '../theme_package.dart';

final class _ThemeLocalDatasource {
  _ThemeLocalDatasource({
    required this.databaseName,
    required this.subDirectory,
    this.customPath,
    this.inMemory = false,
  });

  final String databaseName;
  final String subDirectory;
  final String? customPath;
  final bool inMemory;

  Box<String>? _box;

  /// In-memory fallback storage when Hive is unavailable.
  final Map<String, String> _memoryStore = {};

  /// Initializes Hive and opens the theme box.
  ///
  /// Returns [Either<ThemeError, Unit>] indicating success or failure.
  Future<Either<ThemeError, Unit>> initialize() async {
    if (inMemory) {
      return const Right(unit);
    }

    // coverage:ignore-start
    try {
      final String dbPath;

      if (customPath != null) {
        dbPath = '$customPath/$subDirectory';
      } else {
        final appDocDir = await getApplicationDocumentsDirectory();
        dbPath = '${appDocDir.path}/$subDirectory';
      }

      await Hive.initFlutter(dbPath);

      _box = await Hive.openBox<String>(databaseName);

      return const Right(unit);
    } catch (e) {
      return Left(ThemeError.initializationFailed(e.toString()));
    }
    // coverage:ignore-end
  }

  /// Returns the persisted [ThemeMode].
  /// Defaults to [ThemeMode.system] if no value is stored.
  ThemeMode getThemeMode() {
    if (inMemory) {
      final value = _memoryStore[_ThemeConstants.themeKey];
      return _ThemeConstants.stringToThemeMode(value);
    }

    // coverage:ignore-start
    final value = _box?.get(_ThemeConstants.themeKey);
    return _ThemeConstants.stringToThemeMode(value);
    // coverage:ignore-end
  }

  /// Persists the [ThemeMode] to Hive.
  ///
  /// Returns [Either<ThemeError, Unit>] indicating success or failure.
  Future<Either<ThemeError, Unit>> setThemeMode(ThemeMode mode) async {
    // Test hook to force failure
    if (ThemePackage.forceSetThemeFailure) {
      return const Left(ThemeError.persistenceFailed('Forced test failure'));
    }

    try {
      final value = _ThemeConstants.themeModeToString(mode);

      if (inMemory) {
        _memoryStore[_ThemeConstants.themeKey] = value;
        return const Right(unit);
      }

      // coverage:ignore-start
      await _box?.put(_ThemeConstants.themeKey, value);
      return const Right(unit);
    } catch (e) {
      return Left(ThemeError.persistenceFailed(e.toString()));
    }
    // coverage:ignore-end
  }
}
