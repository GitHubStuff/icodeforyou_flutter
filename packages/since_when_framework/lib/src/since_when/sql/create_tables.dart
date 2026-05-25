// packages/since_when_framework/lib/src/since_when/sql/create_tables.dart

import 'package:since_when_framework/src/since_when/table_names.dart';

/// CREATE TABLE DDL for the `since_when` table.
const String createTableSinceWhen =
    '''
CREATE TABLE IF NOT EXISTS ${TableNames.sinceWhen} (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  createdTimeStamp  INTEGER NOT NULL UNIQUE,
  reviewedTimeStamp INTEGER NOT NULL,
  editedTimeStamp   INTEGER NOT NULL,
  parentTimeStamp   INTEGER,
  eventTimeStamp    INTEGER,
  sequenceNumber    INTEGER NOT NULL DEFAULT 0,
  metaData          TEXT,
  data              TEXT    NOT NULL
)
''';

/// CREATE TABLE DDL for the `since_when_tag_glossary` table.
const String createTableTagGlossary =
    '''
CREATE TABLE IF NOT EXISTS ${TableNames.tagGlossary} (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  createdTimeStamp INTEGER NOT NULL UNIQUE,
  tagName          TEXT    NOT NULL UNIQUE CHECK(tagName != ''),
  color            INTEGER NOT NULL UNIQUE
)
''';

/// CREATE TABLE DDL for the `since_when_tags` join table.
const String createTableTags =
    '''
CREATE TABLE IF NOT EXISTS ${TableNames.tags} (
  id                 INTEGER PRIMARY KEY AUTOINCREMENT,
  record_timestamp   INTEGER NOT NULL,
  glossary_timestamp INTEGER NOT NULL,
  FOREIGN KEY (record_timestamp)
    REFERENCES ${TableNames.sinceWhen}(createdTimeStamp)
    ON DELETE CASCADE,
  FOREIGN KEY (glossary_timestamp)
    REFERENCES ${TableNames.tagGlossary}(createdTimeStamp)
    ON DELETE CASCADE,
  UNIQUE(record_timestamp, glossary_timestamp)
)
''';

/// Ordered list of every CREATE TABLE statement, run during `setup()`.
const List<String> createTableStatements = [
  createTableSinceWhen,
  createTableTagGlossary,
  createTableTags,
];
