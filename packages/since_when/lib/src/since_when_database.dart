// lib/src/since_when_database.dart

// ignore_for_file: document_ignores

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/constants/database_constants.dart';
import 'package:since_when/src/database/_database_initializer.dart';
import 'package:since_when/src/domain/database_access.dart';
import 'package:sqflite/sqflite.dart';

part '_since_when_failure.dart';

typedef _OpenOrCreate = Future<DatabaseInitResult> Function({
  required String dbName,
  required String dbPath,
});

/// A SQLite database instance for the since_when package.
///
/// File-based:
/// ```dart
/// final result = 
///      await SinceWhenDatabase.open(access: DatabaseAccess.automatic);
/// final db = result.getOrElse((f) => throw Exception(f));
/// ```
///
/// In-memory (testing):
/// ```dart
/// final db = await SinceWhenDatabase.inMemory();
/// ```
class SinceWhenDatabase {
  SinceWhenDatabase._({
    required Database db,
    required String fullPath,
  })  : _db = db,
        _fullPath = fullPath;

  final Database _db;
  final String _fullPath;

  static _OpenOrCreate _openOrCreate = DatabaseInitializer.openOrCreateDatabase;

  /// Overrides the database factory for testing only.
  @visibleForTesting
  // ignore: library_private_types_in_public_api, avoid_setters_without_getters
  static set openOrCreateOverride(_OpenOrCreate override) =>
      _openOrCreate = override;

  /// Resets the database factory to the default implementation.
  @visibleForTesting
  static void resetOpenOrCreateOverride() =>
      _openOrCreate = DatabaseInitializer.openOrCreateDatabase;

  bool get isOpen => _db.isOpen;
  bool get isInMemory => _fullPath == kInMemoryPath;
  String get fullPath => _fullPath;

  /// Opens or creates a file-based database.
  ///
  /// Behaviour is governed by [DatabaseAccess]:
  /// - [DatabaseAccess.create]    — fails if the file already exists.
  /// - [DatabaseAccess.open]      — fails if the file does not exist.
  /// - [DatabaseAccess.automatic] — creates if absent, opens if present.
  static Future<Either<SinceWhenFailure, SinceWhenDatabase>> open({
    String dbName = kDefaultDatabaseName,
    String dbPath = kDefaultDatabasePath,
    DatabaseAccess access = DatabaseAccess.automatic,
  }) async {
    final nameFailure = _validateName(dbName);
    if (nameFailure != null) return Left(nameFailure);

    try {
      final fullPath = await DatabaseInitializer.resolveFullPath(
        dbName: dbName,
        dbPath: dbPath,
      );

      final accessFailure = _checkAccess(fullPath, access);
      if (accessFailure != null) return Left(accessFailure);

      final result = await _openOrCreate(dbName: dbName, dbPath: dbPath);

      return Right(
        SinceWhenDatabase._(db: result.database, fullPath: result.fullPath),
      );
    } on Exception catch (e) {
      return Left(SinceWhenOpenFailure(e));
    }
  }

  /// Opens an in-memory database, intended for testing.
  static Future<SinceWhenDatabase> inMemory() async {
    final result = await DatabaseInitializer.openInMemoryDatabase();
    return SinceWhenDatabase._(
      db: result.database,
      fullPath: kInMemoryPath,
    );
  }

  Future<void> close() => _db.close();

  static SinceWhenFailure? _validateName(String name) {
    if (name.trim().isEmpty) return const SinceWhenInvalidName();
    return null;
  }

  static SinceWhenFailure? _checkAccess(
    String fullPath,
    DatabaseAccess access,
  ) {
    final exists = File(fullPath).existsSync();
    return switch (access) {
      DatabaseAccess.create when exists => const SinceWhenAlreadyExists(),
      DatabaseAccess.open when !exists => const SinceWhenNotFound(),
      _ => null,
    };
  }
}
