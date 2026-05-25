// packages/since_when_framework/lib/src/since_when/sql/create_indexes.dart

import 'package:since_when_framework/src/since_when/table_names.dart';

// ─── since_when table indexes ────────────────────────────────────────────────

/// Index on `parentTimeStamp` for parent → child lookups.
const String createIndexSinceWhenParent =
    '''
CREATE INDEX IF NOT EXISTS idx_since_when_parent
  ON ${TableNames.sinceWhen}(parentTimeStamp)
''';

/// Index on `eventTimeStamp` for event-time range queries.
const String createIndexSinceWhenEvent =
    '''
CREATE INDEX IF NOT EXISTS idx_since_when_event
  ON ${TableNames.sinceWhen}(eventTimeStamp)
''';

/// Index on `editedTimeStamp` for recently-edited queries.
const String createIndexSinceWhenEdited =
    '''
CREATE INDEX IF NOT EXISTS idx_since_when_edited
  ON ${TableNames.sinceWhen}(editedTimeStamp)
''';

/// Index on `reviewedTimeStamp` for recently-reviewed queries.
const String createIndexSinceWhenReviewed =
    '''
CREATE INDEX IF NOT EXISTS idx_since_when_reviewed
  ON ${TableNames.sinceWhen}(reviewedTimeStamp)
''';

// ─── since_when_tag_glossary indexes ─────────────────────────────────────────

/// Index on `tagName` for tag name lookups. (The column is already UNIQUE,
/// which creates an implicit index; this is the explicit named version for
/// query planner clarity.)
const String createIndexTagGlossaryName =
    '''
CREATE INDEX IF NOT EXISTS idx_tag_glossary_name
  ON ${TableNames.tagGlossary}(tagName)
''';

// ─── since_when_tags join table indexes ──────────────────────────────────────

/// Index on `record_timestamp` for "tags for this record" lookups.
const String createIndexTagsRecord =
    '''
CREATE INDEX IF NOT EXISTS idx_tags_record
  ON ${TableNames.tags}(record_timestamp)
''';

/// Index on `glossary_timestamp` for "records with this tag" lookups.
const String createIndexTagsGlossary =
    '''
CREATE INDEX IF NOT EXISTS idx_tags_glossary
  ON ${TableNames.tags}(glossary_timestamp)
''';

/// Ordered list of every CREATE INDEX statement, run during `setup()`
/// after the CREATE TABLE statements.
const List<String> createIndexStatements = [
  createIndexSinceWhenParent,
  createIndexSinceWhenEvent,
  createIndexSinceWhenEdited,
  createIndexSinceWhenReviewed,
  createIndexTagGlossaryName,
  createIndexTagsRecord,
  createIndexTagsGlossary,
];
