// icodeforyou_flutter/packages/since_when/lib/src/sql/_sql_statements.dart

/// SQL statements for SinceWhen database operations.
///
/// This class is internal and should not be exported publicly.
abstract final class SqlStatements {
  /// Table name for main records.
  static const String tableSinceWhen = 'since_when';

  /// Table name for tags junction table.
  static const String tableTags = 'since_when_tags';

  /// Creates the main since_when table.
  static const String createTableSinceWhen =
      '''
    CREATE TABLE IF NOT EXISTS $tableSinceWhen (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      createdTimeStamp TEXT NOT NULL UNIQUE,
      parentTimeStamp TEXT,
      reviewedTimeStamp TEXT NOT NULL,
      editedTimeStamp TEXT NOT NULL,
      metaTimeStamp TEXT,
      metaData TEXT NOT NULL,
      sequenceNumber INTEGER NOT NULL DEFAULT 0,
      dataString TEXT NOT NULL,
      category TEXT NOT NULL
    )
  ''';

  /// Creates index on createdTimeStamp for fast lookups.
  static const String createIndexCreatedTimeStamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_since_when_created 
    ON $tableSinceWhen(createdTimeStamp)
  ''';

  /// Creates index on parentTimeStamp for hierarchy queries.
  static const String createIndexParentTimeStamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_since_when_parent 
    ON $tableSinceWhen(parentTimeStamp)
  ''';

  /// Creates the tags junction table.
  static const String createTableTags =
      '''
    CREATE TABLE IF NOT EXISTS $tableTags (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      created_time_stamp TEXT NOT NULL,
      tag TEXT NOT NULL,
      FOREIGN KEY (created_time_stamp) 
        REFERENCES $tableSinceWhen(createdTimeStamp) 
        ON DELETE CASCADE
    )
  ''';

  /// Creates index on tag for tag-based queries.
  static const String createIndexTag =
      '''
    CREATE INDEX IF NOT EXISTS idx_tags_tag 
    ON $tableTags(tag)
  ''';

  /// Creates index on created_time_stamp for joining.
  static const String createIndexTagsCreatedTimeStamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_tags_created_time_stamp 
    ON $tableTags(created_time_stamp)
  ''';

  /// Enables foreign key support (must be run per connection).
  static const String enableForeignKeys = 'PRAGMA foreign_keys = ON';

  /// Checks if a record exists by createdTimeStamp.
  static const String existsByCreatedTimeStamp =
      '''
    SELECT 1 FROM $tableSinceWhen 
    WHERE createdTimeStamp = ? 
    LIMIT 1
  ''';

  /// Gets the maximum sequenceNumber for a given parentTimeStamp.
  static const String maxSequenceNumberForParent =
      '''
    SELECT MAX(sequenceNumber) as maxSeq 
    FROM $tableSinceWhen 
    WHERE parentTimeStamp = ?
  ''';

  /// Inserts a new record into since_when table.
  static const String insertRecord =
      '''
    INSERT INTO $tableSinceWhen (
      createdTimeStamp,
      parentTimeStamp,
      reviewedTimeStamp,
      editedTimeStamp,
      metaTimeStamp,
      metaData,
      sequenceNumber,
      dataString,
      category
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''';

  /// Inserts a tag for a record.
  static const String insertTag =
      '''
    INSERT INTO $tableTags (created_time_stamp, tag) 
    VALUES (?, ?)
  ''';

  /// Deletes all tags for a record.
  static const String deleteTagsForRecord =
      '''
    DELETE FROM $tableTags 
    WHERE created_time_stamp = ?
  ''';

  /// Gets all tags for a record.
  static const String selectTagsForRecord =
      '''
    SELECT tag FROM $tableTags 
    WHERE created_time_stamp = ?
  ''';

  /// Deletes all records from since_when table.
  static const String deleteAllRecords =
      '''
    DELETE FROM $tableSinceWhen
  ''';

  /// Deletes all tags.
  static const String deleteAllTags =
      '''
    DELETE FROM $tableTags
  ''';
}
