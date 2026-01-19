// icodeforyou_flutter/packages/since_when/lib/since_when.dart

/// A SQLite-based timestamped record storage package with hierarchical
/// relationships and tagging.
///
/// ## Getting Started
///
/// **Open or create database:**
/// ```dart
/// import 'package:since_when/since_when.dart';
///
/// // Open with defaults (db/since_when.sqlite)
/// final result = await SinceWhenDatabase.openOrCreate();
/// final db = result.getOrElse(() => throw Exception('Failed'));
///
/// // Create a record
/// final recordResult = await db.create(
///   metaData: 'My first note',
///   dataString: 'This is the content...',
///   category: 'notes',
///   tags: ['personal', 'ideas'],
/// );
///
/// recordResult.fold(
///   (failure) => print('Error: $failure'),
///   (record) => print('Created: ${record.createdTimeStamp}'),
/// );
/// ```
///
/// **Custom path:**
/// ```dart
/// final result = await SinceWhenDatabase.openOrCreate(
///   dbName: 'my_data.sqlite',
///   dbPath: 'storage/data',
/// );
/// ```
///
/// **In-memory (testing):**
/// ```dart
/// final db = await SinceWhenDatabase.openInMemory();
/// ```
library;

// Constants (public)
export 'package:since_when/src/constants/database_constants.dart';

// Domain exports (public)
export 'package:since_when/src/domain/since_when_failure.dart';
export 'package:since_when/src/domain/since_when_import_mode.dart';
export 'package:since_when/src/domain/since_when_record.dart';
export 'package:since_when/src/domain/table_info.dart';

// Database API (public)
export 'package:since_when/src/since_when_database.dart';
