// packages/sincewhen_framework/lib/src/sql/tables/create_tables.dart

import 'package:sincewhen_framework/src/sql/table_names.dart' show TableNames;

/// CREATE TABLE DDL for the `since_when` table.
final String createTableSinceWhen =
    '''
CREATE TABLE IF NOT EXISTS ${TableNames.sinceWhen.name} (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  createdTimeStamp  INTEGER NOT NULL UNIQUE,
  reviewedTimeStamp INTEGER NOT NULL,
  editedTimeStamp   INTEGER NOT NULL,
  parentTimeStamp   INTEGER,
  eventTimeStamp    INTEGER,
  sequenceNumber    INTEGER NOT NULL DEFAULT 0,
  metaData          TEXT,
  data              TEXT NOT NULL
)
''';

/// CREATE TABLE DDL for the `since_when_tag_glossary` table.
final String createTableTagGlossary =
    '''
CREATE TABLE IF NOT EXISTS ${TableNames.glossary.name} (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  createdTimeStamp INTEGER NOT NULL UNIQUE,
  tagName          TEXT    NOT NULL UNIQUE CHECK(tagName != ''),
  color            INTEGER NOT NULL UNIQUE
)
''';

/// CREATE TABLE DDL for the `since_when_tags` join table.
final String createTableTags =
    '''
CREATE TABLE IF NOT EXISTS ${TableNames.tags.name} (
  id                 INTEGER PRIMARY KEY AUTOINCREMENT,
  record_timestamp   INTEGER NOT NULL,
  glossary_timestamp INTEGER NOT NULL,
  FOREIGN KEY (record_timestamp)
    REFERENCES ${TableNames.sinceWhen.name}(createdTimeStamp)
    ON DELETE CASCADE,
  FOREIGN KEY (glossary_timestamp)
    REFERENCES ${TableNames.glossary.name}(createdTimeStamp)
    ON DELETE CASCADE,
  UNIQUE(record_timestamp, glossary_timestamp)
)
''';

/// Ordered list of every CREATE TABLE statement, run during `setup()`.
final List<String> createTableStatements = [
  createTableSinceWhen,
  createTableTagGlossary,
  createTableTags,
];
