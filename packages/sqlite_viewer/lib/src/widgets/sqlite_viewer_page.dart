// packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_page.dart

// ignore_for_file: document_ignores, comment_references

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqlite_viewer/src/abstract/sqlite_viewer_abstract.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_cubit.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_state.dart';
import 'package:sqlite_viewer/src/models/database_metadata.dart';
import 'package:sqlite_viewer/src/models/text_handling.dart';
import 'package:sqlite_viewer/src/widgets/display_query_widget.dart';
import 'package:sqlite_viewer/src/widgets/sqlite_viewer_metadata_panel.dart';
import 'package:sqlite_viewer/src/widgets/sqlite_viewer_query_input.dart';
import 'package:sqlite_viewer/src/widgets/sqlite_viewer_table_detail.dart';

part '_sqlite_viewer_page_helper_views.dart';
part '_sqlite_viewer_page_phone_layout.dart';
part '_sqlite_viewer_page_tablet_layout.dart';

/// A pre-built responsive page for viewing SQLite database contents.
///
/// Adapts layout based on screen size:
/// - **Phone (<600dp)**: Bottom navigation with Tables/Data/Query tabs
/// - **Tablet (600-1200dp)**: Side-by-side metadata panel + content
/// - **Desktop (>1200dp)**: Sidebar + main content + query panel
///
/// Provides [SqliteViewerCubit] to child widgets automatically.
///
/// Example:
/// ```dart
/// // Navigate to viewer page
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => SqliteViewerPage(source: myDatabase),
///   ),
/// );
/// ```
class SqliteViewerPage extends StatelessWidget {
  /// Creates [SqliteViewerPage].
  const SqliteViewerPage({
    required this.source,
    super.key,
    this.title = 'SQLite Viewer',
    this.showQueryInput = true,
    this.sidebarWidth = 280.0,
    this.showRowNumbers = true,
    this.nullValueDisplay = 'NULL',
    this.textHandling = TextHandling.trunc,
  }) : _cubit = null;

  /// Creates [SqliteViewerPage] with a pre-seeded [cubit] for testing.
  ///
  /// The provided cubit is used directly via [BlocProvider.value] — no
  /// internal cubit is created and [connect] is not called.
  @visibleForTesting
  const SqliteViewerPage.withCubit({
    required this.source,
    required SqliteViewerCubit cubit,
    super.key,
    this.title = 'SQLite Viewer',
    this.showQueryInput = true,
    this.sidebarWidth = 280.0,
    this.showRowNumbers = true,
    this.nullValueDisplay = 'NULL',
    this.textHandling = TextHandling.trunc,
  }) : _cubit = cubit;

  /// Creates [SqliteViewerPage] with a pre-supplied [cubit] for use outside
  /// tests — for example in a widgetbook workspace.
  ///
  /// The provided cubit is used directly via [BlocProvider.value] — no
  /// internal cubit is created and [connect] is not called.
  ///
  /// Identical to [SqliteViewerPage.withCubit] but without the
  /// [visibleForTesting] restriction.
  const SqliteViewerPage.forWidgetbook({
    required this.source,
    required SqliteViewerCubit cubit,
    super.key,
    this.title = 'SQLite Viewer',
    this.showQueryInput = true,
    this.sidebarWidth = 280.0,
    this.showRowNumbers = true,
    this.nullValueDisplay = 'NULL',
    this.textHandling = TextHandling.trunc,
  }) : _cubit = cubit;

  /// Database source implementing [SqliteViewerAbstract].
  final SqliteViewerAbstract source;

  /// Title shown in app bar.
  final String title;

  /// Whether to show custom query input.
  final bool showQueryInput;

  /// Width of metadata sidebar on tablet/desktop.
  final double sidebarWidth;

  /// Whether to show row numbers in data grid.
  final bool showRowNumbers;

  /// Display string for null values.
  final String nullValueDisplay;

  /// How to handle text overflow in cells.
  final TextHandling textHandling;

  final SqliteViewerCubit? _cubit;

  @override
  Widget build(BuildContext context) {
    final content = _SqliteViewerPageContent(
      title: title,
      showQueryInput: showQueryInput,
      sidebarWidth: sidebarWidth,
      showRowNumbers: showRowNumbers,
      nullValueDisplay: nullValueDisplay,
      textHandling: textHandling,
    );

    final seeded = _cubit;
    if (seeded != null) {
      return BlocProvider.value(value: seeded, child: content);
    }

    return BlocProvider(
      create: (_) {
        final cubit = SqliteViewerCubit(source);
        unawaited(cubit.connect());
        return cubit;
      },
      child: content,
    );
  }
}

class _SqliteViewerPageContent extends StatelessWidget {
  const _SqliteViewerPageContent({
    required this.title,
    required this.showQueryInput,
    required this.sidebarWidth,
    required this.showRowNumbers,
    required this.nullValueDisplay,
    required this.textHandling,
  });

  final String title;
  final bool showQueryInput;
  final double sidebarWidth;
  final bool showRowNumbers;
  final String nullValueDisplay;
  final TextHandling textHandling;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _PhoneLayout(
            title: title,
            showQueryInput: showQueryInput,
            showRowNumbers: showRowNumbers,
            nullValueDisplay: nullValueDisplay,
            textHandling: textHandling,
          );
        } else if (constraints.maxWidth < 1200) {
          return _TabletLayout(
            title: title,
            showQueryInput: showQueryInput,
            sidebarWidth: sidebarWidth,
            showRowNumbers: showRowNumbers,
            nullValueDisplay: nullValueDisplay,
            textHandling: textHandling,
          );
        }
        return _DesktopLayout(
          title: title,
          showQueryInput: showQueryInput,
          sidebarWidth: sidebarWidth,
          showRowNumbers: showRowNumbers,
          nullValueDisplay: nullValueDisplay,
          textHandling: textHandling,
        );
      },
    );
  }
}

// =============================================================================
// Testing Helpers
// =============================================================================

/// Builds a disconnected view widget for testing.
@visibleForTesting
Widget buildDisconnectedViewForTesting() => const _DisconnectedView();

/// Builds a loading view widget for testing.
@visibleForTesting
Widget buildLoadingViewForTesting({required String message}) =>
    _LoadingView(message: message);

/// Builds an error view widget for testing.
@visibleForTesting
Widget buildErrorViewForTesting({
  required String message,
  VoidCallback? onRetry,
}) =>
    _ErrorView(message: message, onRetry: onRetry);

/// Builds an empty data view widget for testing.
@visibleForTesting
Widget buildEmptyDataViewForTesting() => const _EmptyDataView();

/// Builds a select table prompt widget for testing.
@visibleForTesting
Widget buildSelectTablePromptForTesting() => const _SelectTablePrompt();

/// Builds a query result view widget for testing.
@visibleForTesting
Widget buildQueryResultViewForTesting({
  required String query,
  required List<String> columns,
  required List<Map<String, Object?>> rows,
  bool showRowNumbers = true,
  String nullValueDisplay = 'NULL',
  TextHandling textHandling = TextHandling.trunc,
}) =>
    _QueryResultView(
      query: query,
      columns: columns,
      rows: rows,
      showRowNumbers: showRowNumbers,
      nullValueDisplay: nullValueDisplay,
      textHandling: textHandling,
    );
