// packages/sincewhen_drift_framework/lib/src/database/database_opening.dart

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart'
    show SinceWhenDatabase;

/// Opens [SinceWhenDatabase] instances over concrete executors.
extension SinceWhenDatabaseOpening on SinceWhenDatabase {
  /// Opens an ephemeral in-memory database.
  ///
  /// All data is lost when the database is closed.
  static SinceWhenDatabase inMemory() =>
      SinceWhenDatabase(NativeDatabase.memory());

  /// Opens a database persisted in the application support folder.
  static SinceWhenDatabase inAppFolder({required String fileName}) =>
      _inFolder(getApplicationSupportDirectory, fileName);

  /// Opens a database persisted in the application documents folder.
  static SinceWhenDatabase inDocumentFolder({required String fileName}) =>
      _inFolder(getApplicationDocumentsDirectory, fileName);

  /// Opens a database persisted in the folder resolved by [resolveFolder].
  static SinceWhenDatabase _inFolder(
    Future<Directory> Function() resolveFolder,
    String databaseFileName,
  ) => SinceWhenDatabase(
    LazyDatabase(() async {
      final folder = await resolveFolder();
      final file = File(p.join(folder.path, databaseFileName));
      return NativeDatabase.createInBackground(file);
    }),
  );
}
