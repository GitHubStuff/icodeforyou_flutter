// icodeforyou_flutter/packages/since_when/lib/since_when.dart

/// A SQLite-based timestamped record storage package with hierarchical
/// relationships and tagging.
///
/// ## Getting Started
///
/// **Singleton usage:**
/// ```dart
/// import 'package:since_when/since_when.dart';
///
/// // Initialize once at app start
/// await SinceWhenDatabase.initializeSingleton();
///
/// // Access anywhere
/// final db = SinceWhenDatabase.instance;
///
/// // Create a record
/// final result = await db.create(
///   metaData: 'My first note',
///   dataString: 'This is the content...',
///   category: 'notes',
///   tags: ['personal', 'ideas'],
/// );
///
/// result.fold(
///   (failure) => print('Error: $failure'),
///   (record) => print('Created: ${record.createdTimeStamp}'),
/// );
/// ```
///
/// **Named instance usage:**
/// ```dart
/// final dbResult = await SinceWhenDatabase.openOrCreate(dbName: 'my_data.db');
///
/// dbResult.fold(
///   (failure) => print('Error: $failure'),
///   (db) async {
///     await db.create(...);
///     await db.close();
///   },
/// );
/// ```
library;

// Domain exports (public)
export 'package:since_when/src/domain/since_when_failure.dart';
export 'package:since_when/src/domain/since_when_import_mode.dart';
export 'package:since_when/src/domain/since_when_record.dart';

// Database API (public)
export 'package:since_when/src/since_when_database.dart';
