// lib/src/sql/_sql_statements.dart

/// SQL statements for SinceWhen database operations.
///
/// This class is internal and should not be exported publicly.
abstract final class SqlStatements {
  /// Table name for main records.
  static const String tableSinceWhen = 'since_when';

  /// Table name for tag definitions.
  static const String tableTagGlossary = 'since_when_tag_glossary';

  /// Table name for tags junction table.
  static const String tableTags = 'since_when_tags';

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE TABLES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates the main since_when table.
  static const String createTableSinceWhen = '''
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

  /// Creates the tag glossary table.
  static const String createTableTagGlossary = '''
    CREATE TABLE IF NOT EXISTS $tableTagGlossary (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      createdTimeStamp TEXT NOT NULL UNIQUE,
      tagName TEXT NOT NULL UNIQUE CHECK(tagName != ''),
      tagDescription TEXT NOT NULL DEFAULT '',
      color INTEGER NOT NULL
    )
  ''';

  /// Creates the tags junction table.
  static const String createTableTags = '''
    CREATE TABLE IF NOT EXISTS $tableTags (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      record_timestamp TEXT NOT NULL,
      glossary_timestamp TEXT NOT NULL,
      FOREIGN KEY (record_timestamp) 
        REFERENCES $tableSinceWhen(createdTimeStamp) 
        ON DELETE CASCADE,
      FOREIGN KEY (glossary_timestamp) 
        REFERENCES $tableTagGlossary(createdTimeStamp) 
        ON DELETE CASCADE,
      UNIQUE(record_timestamp, glossary_timestamp)
    )
  ''';

  // ═══════════════════════════════════════════════════════════════════════════
  // INDEXES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates index on createdTimeStamp for fast lookups.
  static const String createIndexCreatedTimeStamp = '''
    CREATE INDEX IF NOT EXISTS idx_since_when_created 
    ON $tableSinceWhen(createdTimeStamp)
  ''';

  /// Creates index on parentTimeStamp for hierarchy queries.
  static const String createIndexParentTimeStamp = '''
    CREATE INDEX IF NOT EXISTS idx_since_when_parent 
    ON $tableSinceWhen(parentTimeStamp)
  ''';

  /// Creates index on tagName for lookups.
  static const String createIndexTagName = '''
    CREATE INDEX IF NOT EXISTS idx_glossary_tag_name 
    ON $tableTagGlossary(tagName)
  ''';

  /// Creates index on glossary createdTimeStamp.
  static const String createIndexGlossaryTimestamp = '''
    CREATE INDEX IF NOT EXISTS idx_glossary_created 
    ON $tableTagGlossary(createdTimeStamp)
  ''';

  /// Creates index on record_timestamp for joining.
  static const String createIndexTagsRecordTimestamp = '''
    CREATE INDEX IF NOT EXISTS idx_tags_record_timestamp 
    ON $tableTags(record_timestamp)
  ''';

  /// Creates index on glossary_timestamp for joining.
  static const String createIndexTagsGlossaryTimestamp = '''
    CREATE INDEX IF NOT EXISTS idx_tags_glossary_timestamp 
    ON $tableTags(glossary_timestamp)
  ''';

  // ═══════════════════════════════════════════════════════════════════════════
  // PRAGMA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Enables foreign key support (must be run per connection).
  static const String enableForeignKeys = 'PRAGMA foreign_keys = ON';

  // ═══════════════════════════════════════════════════════════════════════════
  // SINCE_WHEN OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Checks if a record exists by createdTimeStamp.
  static const String existsByCreatedTimeStamp = '''
    SELECT 1 FROM $tableSinceWhen 
    WHERE createdTimeStamp = ? 
    LIMIT 1
  ''';

  /// Gets the maximum sequenceNumber for a given parentTimeStamp.
  static const String maxSequenceNumberForParent = '''
    SELECT MAX(sequenceNumber) as maxSeq 
    FROM $tableSinceWhen 
    WHERE parentTimeStamp = ?
  ''';

  /// Inserts a new record into since_when table.
  static const String insertRecord = '''
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

  /// Deletes all records from since_when table.
  static const String deleteAllRecords = '''
    DELETE FROM $tableSinceWhen
  ''';

  // ═══════════════════════════════════════════════════════════════════════════
  // TAG GLOSSARY OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Checks if a glossary timestamp exists.
  static const String existsGlossaryByTimestamp = '''
    SELECT 1 FROM $tableTagGlossary 
    WHERE createdTimeStamp = ? 
    LIMIT 1
  ''';

  /// Inserts a new tag definition.
  static const String insertTagDefinition = '''
    INSERT INTO $tableTagGlossary (
      createdTimeStamp,
      tagName,
      tagDescription,
      color
    ) VALUES (?, ?, ?, ?)
  ''';

  /// Updates a tag definition by createdTimeStamp.
  static const String updateTagDefinition = '''
    UPDATE $tableTagGlossary 
    SET tagName = ?, tagDescription = ?, color = ?
    WHERE createdTimeStamp = ?
  ''';

  /// Deletes a tag definition by createdTimeStamp.
  static const String deleteTagDefinition = '''
    DELETE FROM $tableTagGlossary 
    WHERE createdTimeStamp = ?
  ''';

  /// Gets a tag definition by createdTimeStamp.
  static const String selectTagDefinitionByTimestamp = '''
    SELECT * FROM $tableTagGlossary 
    WHERE createdTimeStamp = ?
  ''';

  /// Gets a tag definition by tagName.
  static const String selectTagDefinitionByName = '''
    SELECT * FROM $tableTagGlossary 
    WHERE tagName = ?
  ''';

  /// Gets all tag definitions.
  static const String selectAllTagDefinitions = '''
    SELECT * FROM $tableTagGlossary 
    ORDER BY tagName ASC
  ''';

  /// Checks if a tag name exists.
  static const String existsTagName = '''
    SELECT 1 FROM $tableTagGlossary 
    WHERE tagName = ? 
    LIMIT 1
  ''';

  /// Deletes all tag definitions.
  static const String deleteAllTagDefinitions = '''
    DELETE FROM $tableTagGlossary
  ''';

  // ═══════════════════════════════════════════════════════════════════════════
  // JUNCTION TABLE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Links a record to a tag via glossary timestamp.
  static const String insertRecordTag = '''
    INSERT OR IGNORE INTO $tableTags (record_timestamp, glossary_timestamp) 
    VALUES (?, ?)
  ''';

  /// Removes a tag from a record.
  static const String deleteRecordTag = '''
    DELETE FROM $tableTags 
    WHERE record_timestamp = ? AND glossary_timestamp = ?
  ''';

  /// Deletes all tags for a record.
  static const String deleteTagsForRecord = '''
    DELETE FROM $tableTags 
    WHERE record_timestamp = ?
  ''';

  /// Gets all tag definitions for a record.
  static const String selectTagsForRecord = '''
    SELECT g.* FROM $tableTagGlossary g
    INNER JOIN $tableTags t ON g.createdTimeStamp = t.glossary_timestamp
    WHERE t.record_timestamp = ?
    ORDER BY g.tagName ASC
  ''';

  /// Gets all records with a specific tag (by glossary timestamp).
  static const String selectRecordsByTagTimestamp = '''
    SELECT sw.* FROM $tableSinceWhen sw
    INNER JOIN $tableTags t ON sw.createdTimeStamp = t.record_timestamp
    WHERE t.glossary_timestamp = ?
  ''';

  /// Gets all records with a specific tag (by tag name).
  static const String selectRecordsByTagName = '''
    SELECT sw.* FROM $tableSinceWhen sw
    INNER JOIN $tableTags t ON sw.createdTimeStamp = t.record_timestamp
    INNER JOIN $tableTagGlossary g ON t.glossary_timestamp = g.createdTimeStamp
    WHERE g.tagName = ?
  ''';

  /// Deletes all junction entries.
  static const String deleteAllTags = '''
    DELETE FROM $tableTags
  ''';
}
