// packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../abstract/sqlite_viewer_abstract.dart';
import '../models/database_metadata.dart';
import '../cubit/sqlite_viewer_cubit.dart';
import '../cubit/sqlite_viewer_state.dart';
import '../models/text_handling.dart';
import 'display_query_widget.dart';
import 'sqlite_viewer_metadata_panel.dart';
import 'sqlite_viewer_query_input.dart';
import 'sqlite_viewer_table_detail.dart';

part '_sqlite_viewer_page_phone_layout.dart';
part '_sqlite_viewer_page_tablet_layout.dart';
part '_sqlite_viewer_page_helper_views.dart';

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
  const SqliteViewerPage({
    super.key,
    required this.source,
    this.title = 'SQLite Viewer',
    this.showQueryInput = true,
    this.sidebarWidth = 280.0,
    this.showRowNumbers = true,
    this.nullValueDisplay = 'NULL',
    this.textHandling = TextHandling.trunc,
  });

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SqliteViewerCubit(source)..connect(),
      child: _SqliteViewerPageContent(
        title: title,
        showQueryInput: showQueryInput,
        sidebarWidth: sidebarWidth,
        showRowNumbers: showRowNumbers,
        nullValueDisplay: nullValueDisplay,
        textHandling: textHandling,
      ),
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
