// lib/src/sql/_sql_statements.dart

abstract final class SqlStatements {
  static const String tableSinceWhen = 'since_when';
  static const String tableTagGlossary = 'since_when_tag_glossary';
  static const String tableTags = 'since_when_tags';

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE TABLES
  // ═══════════════════════════════════════════════════════════════════════════

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

  static const String createTableTagGlossary =
      '''
    CREATE TABLE IF NOT EXISTS $tableTagGlossary (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      createdTimeStamp TEXT NOT NULL UNIQUE,
      tagName TEXT NOT NULL UNIQUE CHECK(tagName != ''),
      color INTEGER NOT NULL
    )
  ''';

  static const String createTableTags =
      '''
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

  static const String createIndexCreatedTimeStamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_since_when_created 
    ON $tableSinceWhen(createdTimeStamp)
  ''';

  static const String createIndexParentTimeStamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_since_when_parent 
    ON $tableSinceWhen(parentTimeStamp)
  ''';

  static const String createIndexTagName =
      '''
    CREATE INDEX IF NOT EXISTS idx_glossary_tag_name 
    ON $tableTagGlossary(tagName)
  ''';

  static const String createIndexGlossaryTimestamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_glossary_created 
    ON $tableTagGlossary(createdTimeStamp)
  ''';

  static const String createIndexTagsRecordTimestamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_tags_record_timestamp 
    ON $tableTags(record_timestamp)
  ''';

  static const String createIndexTagsGlossaryTimestamp =
      '''
    CREATE INDEX IF NOT EXISTS idx_tags_glossary_timestamp 
    ON $tableTags(glossary_timestamp)
  ''';

  // ═══════════════════════════════════════════════════════════════════════════
  // PRAGMA
  // ═══════════════════════════════════════════════════════════════════════════

  static const String enableForeignKeys = 'PRAGMA foreign_keys = ON';

  // ═══════════════════════════════════════════════════════════════════════════
  // SINCE_WHEN OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const String existsByCreatedTimeStamp =
      '''
    SELECT 1 FROM $tableSinceWhen 
    WHERE createdTimeStamp = ? 
    LIMIT 1
  ''';

  static const String maxSequenceNumberForParent =
      '''
    SELECT MAX(sequenceNumber) as maxSeq 
    FROM $tableSinceWhen 
    WHERE parentTimeStamp = ?
  ''';

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

  static const String deleteAllRecords =
      '''
    DELETE FROM $tableSinceWhen
  ''';

  // ═══════════════════════════════════════════════════════════════════════════
  // TAG GLOSSARY OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const String existsGlossaryByTimestamp =
      '''
    SELECT 1 FROM $tableTagGlossary 
    WHERE createdTimeStamp = ? 
    LIMIT 1
  ''';

  static const String insertTagDefinition =
      '''
    INSERT INTO $tableTagGlossary (
      createdTimeStamp,
      tagName,
      color
    ) VALUES (?, ?, ?)
  ''';

  static const String updateTagDefinition =
      '''
    UPDATE $tableTagGlossary 
    SET tagName = ?, color = ?
    WHERE createdTimeStamp = ?
  ''';

  static const String deleteTagDefinition =
      '''
    DELETE FROM $tableTagGlossary 
    WHERE createdTimeStamp = ?
  ''';

  static const String selectTagDefinitionByTimestamp =
      '''
    SELECT * FROM $tableTagGlossary 
    WHERE createdTimeStamp = ?
  ''';

  static const String selectTagDefinitionByName =
      '''
    SELECT * FROM $tableTagGlossary 
    WHERE tagName = ?
  ''';

  static const String selectAllTagDefinitions =
      '''
    SELECT * FROM $tableTagGlossary 
    ORDER BY tagName ASC
  ''';

  static const String existsTagName =
      '''
    SELECT 1 FROM $tableTagGlossary 
    WHERE tagName = ? 
    LIMIT 1
  ''';

  static const String deleteAllTagDefinitions =
      '''
    DELETE FROM $tableTagGlossary
  ''';

  // ═══════════════════════════════════════════════════════════════════════════
  // JUNCTION TABLE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const String insertRecordTag =
      '''
    INSERT OR IGNORE INTO $tableTags (record_timestamp, glossary_timestamp) 
    VALUES (?, ?)
  ''';

  static const String deleteRecordTag =
      '''
    DELETE FROM $tableTags 
    WHERE record_timestamp = ? AND glossary_timestamp = ?
  ''';

  static const String deleteTagsForRecord =
      '''
    DELETE FROM $tableTags 
    WHERE record_timestamp = ?
  ''';

  static const String selectTagsForRecord =
      '''
    SELECT g.* FROM $tableTagGlossary g
    INNER JOIN $tableTags t ON g.createdTimeStamp = t.glossary_timestamp
    WHERE t.record_timestamp = ?
    ORDER BY g.tagName ASC
  ''';

  static const String selectRecordsByTagTimestamp =
      '''
    SELECT sw.* FROM $tableSinceWhen sw
    INNER JOIN $tableTags t ON sw.createdTimeStamp = t.record_timestamp
    WHERE t.glossary_timestamp = ?
  ''';

  static const String selectRecordsByTagName =
      '''
    SELECT sw.* FROM $tableSinceWhen sw
    INNER JOIN $tableTags t ON sw.createdTimeStamp = t.record_timestamp
    INNER JOIN $tableTagGlossary g ON t.glossary_timestamp = g.createdTimeStamp
    WHERE g.tagName = ?
  ''';

  static const String deleteAllTags =
      '''
    DELETE FROM $tableTags
  ''';
}
