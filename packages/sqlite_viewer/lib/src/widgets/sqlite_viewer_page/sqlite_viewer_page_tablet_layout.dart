// packages/sqlite_viewer/lib/src/widgets/_sqlite_viewer_page_tablet_layout.dart

part of 'sqlite_viewer_page.dart';

// =============================================================================
// Tablet Layout — Side by Side
// =============================================================================

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
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
    return BlocBuilder<SqliteViewerCubit, SqliteViewerState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            centerTitle: false,
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SqliteViewerState state) {
    return switch (state) {
      ViewerDisconnected() => const DisconnectedView(),
      ViewerConnecting() => const LoadingView(message: 'Connecting...'),
      ViewerConnectionFailed(:final failure) => ErrorView(
        message: failure.message,
      ),
      _ => _buildConnectedLayout(context, state),
    };
  }

  Widget _buildConnectedLayout(BuildContext context, SqliteViewerState state) {
    final metadata = _getMetadata(state);
    if (metadata == null) return const DisconnectedView();

    final selectedTable = _getSelectedTable(state);

    return Row(
      children: [
        // Sidebar
        SizedBox(
          width: sidebarWidth,
          child: SqliteViewerMetadataPanel(
            metadata: metadata,
            selectedTable: selectedTable,
            onTableSelected: (tableName) {
              unawaited(
                context.read<SqliteViewerCubit>().selectTable(tableName),
              );
            },
            onRefresh: () {
              unawaited(context.read<SqliteViewerCubit>().refreshMetadata());
            },
            isLoading: state is MetadataLoading,
          ),
        ),

        // Divider
        const VerticalDivider(width: 1, thickness: 1),

        // Main content
        Expanded(
          child: Column(
            children: [
              Expanded(child: _buildMainContent(context, state)),
              if (showQueryInput) const SqlCommand(),
              //if (showQueryInput)
              // SqliteViewerQueryInput(
              //   onExecute: (sql) {
              //     unawaited(
              //       context.read<SqliteViewerCubit>().executeQuery(sql),
              //     );
              //   },
              //   isExecuting: state is QueryExecuting,
              //   initialQuery: _getLastQuery(state),
              //   maxLines: 3,
              //   minLines: 2,
              //),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, SqliteViewerState state) {
    return switch (state) {
      TableDetailLoading(:final tableName) => LoadingView(
        message: 'Loading $tableName...',
      ),
      TableDetailLoaded(
        :final tableName,
        :final columns,
        :final tableInfo,
        :final indexList,
        :final foreignKeys,
        :final rows,
        :final rowCount,
      ) =>
        SqliteViewerTableDetail(
          tableName: tableName,
          columns: columns,
          tableInfo: tableInfo,
          indexList: indexList,
          foreignKeys: foreignKeys,
          rows: rows,
          rowCount: rowCount,
          onRefresh: () {
            unawaited(
              context.read<SqliteViewerCubit>().selectTable(tableName),
            );
          },
          showRowNumbers: showRowNumbers,
          nullValueDisplay: nullValueDisplay,
          textHandling: textHandling,
        ),
      TableDetailLoadFailed(:final tableName, :final failure) => ErrorView(
        message: 'Failed to load $tableName: ${failure.message}',
        onRetry: () {
          unawaited(
            context.read<SqliteViewerCubit>().selectTable(tableName),
          );
        },
      ),
      QueryExecuting() => const LoadingView(
        message: 'Executing query...',
      ),
      QueryResultLoaded(:final query, :final columns, :final rows) =>
        QueryResultView(
          query: query,
          columns: columns,
          rows: rows,
          showRowNumbers: showRowNumbers,
          nullValueDisplay: nullValueDisplay,
          textHandling: textHandling,
        ),
      QueryFailed(:final query, :final failure) => ErrorView(
        message: 'Query failed: ${failure.message}',
        onRetry: () {
          unawaited(context.read<SqliteViewerCubit>().executeQuery(query));
        },
      ),
      _ => const SelectTablePrompt(),
    };
  }

  DatabaseMetadata? _getMetadata(SqliteViewerState state) {
    return switch (state) {
      MetadataLoading(:final metadata) => metadata,
      MetadataLoaded(:final metadata) => metadata,
      MetadataLoadFailed(:final metadata) => metadata,
      TableDetailLoading(:final metadata) => metadata,
      TableDetailLoaded(:final metadata) => metadata,
      TableDetailLoadFailed(:final metadata) => metadata,
      QueryExecuting(:final metadata) => metadata,
      QueryResultLoaded(:final metadata) => metadata,
      QueryFailed(:final metadata) => metadata,
      _ => null,
    };
  }

  String? _getSelectedTable(SqliteViewerState state) {
    return switch (state) {
      TableDetailLoading(:final tableName) => tableName,
      TableDetailLoaded(:final tableName) => tableName,
      TableDetailLoadFailed(:final tableName) => tableName,
      _ => null,
    };
  }

  String? _getLastQuery(SqliteViewerState state) {
    return switch (state) {
      QueryResultLoaded(:final query) => query,
      QueryFailed(:final query) => query,
      _ => null,
    };
  }
}

// =============================================================================
// Desktop Layout — Three Panel
// =============================================================================

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
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
    // Desktop uses same layout as tablet for now
    // Can be extended with resizable panels, multiple tabs, etc.
    return _TabletLayout(
      title: title,
      showQueryInput: showQueryInput,
      sidebarWidth: sidebarWidth,
      showRowNumbers: showRowNumbers,
      nullValueDisplay: nullValueDisplay,
      textHandling: textHandling,
    );
  }
}
