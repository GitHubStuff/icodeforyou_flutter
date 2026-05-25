// packages/since_when_framework/lib/src/since_when/sql/drop_tables.dart

import 'package:since_when_framework/src/since_when/table_names.dart';

/// DROP TABLE statements, ordered so child tables drop before their parents
/// to satisfy foreign-key constraints.
const List<String> dropTableStatements = [
  'DROP TABLE IF EXISTS ${TableNames.tags}',
  'DROP TABLE IF EXISTS ${TableNames.tagGlossary}',
  'DROP TABLE IF EXISTS ${TableNames.sinceWhen}',
];
