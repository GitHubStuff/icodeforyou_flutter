// lib/src/sql/_sql_statements.dart

part of '../database/_database_initializer.dart';

abstract final class SqlStatements {
  // ─── Table names (public — needed by operation files) ──────────────────────
  static const String tableSinceWhen = 'since_when';
  static const String tableTagGlossary = 'since_when_tag_glossary';
  static const String tableTags = 'since_when_tags';
  static const String tableLog = 'since_when_log';

  // ─── PRAGMA ────────────────────────────────────────────────────────────────
  static const String _enableForeignKeys = 'PRAGMA foreign_keys = ON';

  // ─── CREATE TABLES ─────────────────────────────────────────────────────────
  static const String _createTableSinceWhen =
      '''
    CREATE TABLE IF NOT EXISTS $tableSinceWhen (
      id                INTEGER PRIMARY KEY AUTOINCREMENT,
      createdTimeStamp  INTEGER NOT NULL UNIQUE,
      parentTimeStamp   INTEGER,
      reviewedTimeStamp INTEGER NOT NULL,
      editedTimeStamp   INTEGER NOT NULL,
      metaTimeStamp     INTEGER,
      metaData          TEXT    NOT NULL,
      sequenceNumber    INTEGER NOT NULL DEFAULT 0,
      dataString        TEXT    NOT NULL,
      category          TEXT    NOT NULL
    )
  ''';

  static const String _createTableTagGlossary =
      '''
    CREATE TABLE IF NOT EXISTS $tableTagGlossary (
      id               INTEGER PRIMARY KEY AUTOINCREMENT,
      createdTimeStamp INTEGER NOT NULL UNIQUE,
      tagName          TEXT    NOT NULL UNIQUE CHECK(tagName != ''),
      color            INTEGER NOT NULL
    )
  ''';

  static const String _createTableTags =
      '''
    CREATE TABLE IF NOT EXISTS $tableTags (
      id                 INTEGER PRIMARY KEY AUTOINCREMENT,
      record_timestamp   INTEGER NOT NULL,
      glossary_timestamp INTEGER NOT NULL,
      FOREIGN KEY (record_timestamp)
        REFERENCES $tableSinceWhen(createdTimeStamp)
        ON DELETE CASCADE,
      FOREIGN KEY (glossary_timestamp)
        REFERENCES $tableTagGlossary(createdTimeStamp)
        ON DELETE CASCADE,
      UNIQUE(record_timestamp, glossary_timestamp)
    )
  ''';

  /// Append-only audit/debug log.
  ///
  /// - [logTimeStamp]  ms since epoch — when this entry was written.
  /// - [action]        [LogAction] enum value stored as TEXT.
  /// - [tableName]     which table was affected.
  /// - [targetId]      createdTimeStamp of the affected row; NULL for
  ///                   table-level operations (e.g. deleteAll).
  /// - [detail]        optional free-text context (error, diff, etc.).
  static const String _createTableLog =
      '''
    CREATE TABLE IF NOT EXISTS $tableLog (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      logTimeStamp INTEGER NOT NULL,
      action       TEXT    NOT NULL,
      tableName    TEXT    NOT NULL,
      targetId     INTEGER,
      detail       TEXT
    )
  ''';

  // ─── CREATE INDEXES ────────────────────────────────────────────────────────
  static const String _createIndexCreatedTimeStamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_since_when_created
    ON $tableSinceWhen(createdTimeStamp)
  ''';

  static const String _createIndexParentTimeStamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_since_when_parent
    ON $tableSinceWhen(parentTimeStamp)
  ''';

  static const String _createIndexTagName =
      '''
    CREATE INDEX IF NOT EXISTS idx_glossary_tag_name
    ON $tableTagGlossary(tagName)
  ''';

  static const String _createIndexGlossaryTimestamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_glossary_created
    ON $tableTagGlossary(createdTimeStamp)
  ''';

  static const String _createIndexTagsRecordTimestamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_tags_record_timestamp
    ON $tableTags(record_timestamp)
  ''';

  static const String _createIndexTagsGlossaryTimestamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_tags_glossary_timestamp
    ON $tableTags(glossary_timestamp)
  ''';

  static const String _createIndexLogTimeStamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_log_timestamp
    ON $tableLog(logTimeStamp)
  ''';

  static const String _createIndexLogAction =
      '''
    CREATE INDEX IF NOT EXISTS idx_log_action
    ON $tableLog(action)
  ''';
}
