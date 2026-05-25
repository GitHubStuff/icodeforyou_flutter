// packages/sqlite_viewer/lib/sqlite_viewer.dart

/// A Flutter package for viewing SQLite database contents.
///
/// Provides:
/// - `SqliteViewerAbstract` — interface for database sources
/// - `SqliteViewerCubit` — state management
/// - `SqliteViewerPage` — pre-built responsive page
/// - `DisplayQueryWidget` — spreadsheet-style data grid
/// - Individual components for custom layouts
///
/// Example usage:
/// ```dart
/// import 'package:sqlite_viewer/sqlite_viewer.dart';
///
/// // Use pre-built page
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => SqliteViewerPage(source: myDatabase),
///   ),
/// );
/// ```
library;

// Abstract
export 'src/abstract/sqlite_viewer_abstract.dart';

// Cubit
export 'src/cubit/sqlite_viewer_cubit.dart';
export 'src/cubit/sqlite_viewer_state.dart';

// Failures
export 'src/failures/sqlite_viewer_failure.dart';

// Models
export 'src/models/database_metadata.dart';
export 'src/models/pragma_key.dart';
export 'src/models/text_handling.dart';

// Widgets
export 'src/widgets/display_query_widget.dart';
export 'src/widgets/sqlite_viewer_metadata_panel.dart';
export 'src/widgets/sqlite_viewer_page.dart';
export 'src/widgets/sqlite_viewer_query_input.dart';
export 'src/widgets/sqlite_viewer_table_detail.dart';
