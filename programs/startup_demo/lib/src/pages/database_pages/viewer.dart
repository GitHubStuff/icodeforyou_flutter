// startup_demo/lib/src/pages/database_pages/viewer.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:since_when_framework/database.dart'
    show DatabaseLifecycleCubit, DatabaseLifecycleState, DatabaseReady;
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:startup_demo/src/pages/database_pages/handle_viewer_source.dart';

/// Query + display screen for the currently-open in-memory database.
///
/// Reads the ambient [DatabaseLifecycleCubit]. When the state is
/// [DatabaseReady], the open [DatabaseHandle] is adapted to
/// [SqliteViewerAbstract] via [HandleViewerSource] and handed to
/// [SqliteViewerPage]. Any other state shows a fallback — this page is
/// only meaningful when a database is open.
class DatabaseViewerPage extends StatelessWidget {
  const DatabaseViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DatabaseLifecycleCubit, DatabaseLifecycleState>(
      builder: (context, state) {
        if (state is! DatabaseReady) {
          return const _NotReadyScaffold();
        }
        return SqliteViewerPage(
          source: HandleViewerSource(handle: state.handle),
        );
      },
    );
  }
}

class _NotReadyScaffold extends StatelessWidget {
  const _NotReadyScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite Viewer')),
      body: const Center(child: Text('Database is not open.')),
    );
  }
}
