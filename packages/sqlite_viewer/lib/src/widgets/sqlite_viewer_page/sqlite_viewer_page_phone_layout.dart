// packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_page/sqlite_viewer_page_phone_layout.dart

part of 'sqlite_viewer_page.dart';

// =============================================================================
// Phone Layout — Bottom Navigation
// =============================================================================

/// A compact layout tailored for phone screens using a bottom navigation bar.
class PhoneLayout extends StatefulWidget {
  /// Creates a [PhoneLayout].
  const PhoneLayout({
    required this.title,
    required this.showQueryInput,
    required this.showRowNumbers,
    required this.nullValueDisplay,
    required this.textHandling,
    super.key,
  });

  /// The title displayed in the top app bar.
  final String title;

  /// Whether to show the query input destination and tab.
  final bool showQueryInput;

  /// Whether to render row indices in data views.
  final bool showRowNumbers;

  /// The placeholder string used to represent SQL `NULL` values.
  final String nullValueDisplay;

  /// Configuration for handling text overflow and truncation in table cells.
  final TextHandling textHandling;

  @override
  State<PhoneLayout> createState() => PhoneLayoutState();
}

/// The state for [PhoneLayout], managing navigation tabs and tab views.
class PhoneLayoutState extends State<PhoneLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SqliteViewerCubit, SqliteViewerState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            centerTitle: false,
            actions: [
              if (state is MetadataLoaded ||
                  state is TableDetailLoaded ||
                  state is QueryResultLoaded)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    unawaited(
                      context.read<SqliteViewerCubit>().refreshMetadata(),
                    );
                  },
                  tooltip: 'Refresh',
                ),
            ],
          ),
          body: buildBody(context, state),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.table_chart_outlined),
                selectedIcon: Icon(Icons.table_chart),
                label: 'Tables',
              ),
              const NavigationDestination(
                icon: Icon(Icons.grid_on_outlined),
                selectedIcon: Icon(Icons.grid_on),
                label: 'Data',
              ),
              if (widget.showQueryInput)
                const NavigationDestination(
                  icon: Icon(Icons.code_outlined),
                  selectedIcon: Icon(Icons.code),
                  label: 'Query',
                ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the main content area based on the current [state].
  Widget buildBody(BuildContext context, SqliteViewerState state) {
    return switch (state) {
      ViewerDisconnected() => const DisconnectedView(),
      ViewerConnecting() => const LoadingView(message: 'Connecting...'),
      ViewerConnectionFailed(:final failure) => ErrorView(
        message: failure.message,
      ),
      MetadataLoading(:final metadata) => _buildConnectedBody(
        context,
        state,
        metadata,
      ),
      MetadataLoaded(:final metadata) => _buildConnectedBody(
        context,
        state,
        metadata,
      ),
      MetadataLoadFailed(:final metadata) =>
        metadata != null
            ? _buildConnectedBody(context, state, metadata)
            : const DisconnectedView(),
      TableDetailLoading(:final metadata) => _buildConnectedBody(
        context,
        state,
        metadata,
      ),
      TableDetailLoaded(:final metadata) => _buildConnectedBody(
        context,
        state,
        metadata,
      ),
      TableDetailLoadFailed(:final metadata) => _buildConnectedBody(
        context,
        state,
        metadata,
      ),
      QueryExecuting(:final metadata) => _buildConnectedBody(
        context,
        state,
        metadata,
      ),
      QueryResultLoaded(:final metadata) => _buildConnectedBody(
        context,
        state,
        metadata,
      ),
      QueryFailed(:final metadata) => _buildConnectedBody(
        context,
        state,
        metadata,
      ),
    };
  }

  /// Renders the body when a database connection and [metadata] are present.
  Widget _buildConnectedBody(
    BuildContext context,
    SqliteViewerState state,
    DatabaseMetadata metadata,
  ) {
    switch (_currentIndex) {
      case 0:
        return _buildTablesTab(context, state, metadata);
      case 1:
        return _buildDataTab(context, state);
      case 2:
        return _buildQueryTab(context, state, metadata);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Builds the table list view tab.
  Widget _buildTablesTab(
    BuildContext context,
    SqliteViewerState state,
    DatabaseMetadata metadata,
  ) {
    final selectedTable = switch (state) {
      TableDetailLoading(:final tableName) => tableName,
      TableDetailLoaded(:final tableName) => tableName,
      TableDetailLoadFailed(:final tableName) => tableName,
      _ => null,
    };

    return SqliteViewerMetadataPanel(
      metadata: metadata,
      selectedTable: selectedTable,
      onTableSelected: (tableName) {
        unawaited(context.read<SqliteViewerCubit>().selectTable(tableName));
        setState(() => _currentIndex = 1);
      },
      onRefresh: () {
        unawaited(context.read<SqliteViewerCubit>().refreshMetadata());
      },
      isLoading: state is MetadataLoading,
    );
  }

  /// Builds the data grid view tab for the active table or query result.
  Widget _buildDataTab(BuildContext context, SqliteViewerState state) {
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
          showRowNumbers: widget.showRowNumbers,
          nullValueDisplay: widget.nullValueDisplay,
          textHandling: widget.textHandling,
        ),
      TableDetailLoadFailed(:final tableName, :final failure) => ErrorView(
        message: 'Failed to load $tableName: ${failure.message}',
        onRetry: () {
          unawaited(
            context.read<SqliteViewerCubit>().selectTable(tableName),
          );
        },
      ),
      QueryResultLoaded(:final query, :final columns, :final rows) =>
        _buildQueryResult(context, query, columns, rows),
      QueryFailed(:final query, :final failure) => ErrorView(
        message: 'Query failed: ${failure.message}',
        onRetry: () {
          unawaited(context.read<SqliteViewerCubit>().executeQuery(query));
        },
      ),
      _ => const EmptyDataView(),
    };
  }

  /// Builds the view displaying the results of an executed query.
  Widget _buildQueryResult(
    BuildContext context,
    String query,
    List<String> columns,
    List<Map<String, Object?>> rows,
  ) {
    return QueryResultView(
      query: query,
      columns: columns,
      rows: rows,
      showRowNumbers: widget.showRowNumbers,
      nullValueDisplay: widget.nullValueDisplay,
      textHandling: widget.textHandling,
    );
  }

  /// Builds the query editor tab containing the SQL input interface.
  Widget _buildQueryTab(
    BuildContext context,
    SqliteViewerState state,
    DatabaseMetadata metadata,
  ) {
    return Column(
      children: [
        Expanded(
          child: _buildDataTab(context, state),
        ),
        const SqlCommand(),
        // SqliteViewerQueryInput(
        //   onExecute: (sql) {
        //     unawaited(context.read<SqliteViewerCubit>().executeQuery(sql));
        //     setState(() => _currentIndex = 1);
        //   },
        //   isExecuting: isExecuting,
        //   initialQuery: lastQuery,
        // ),
      ],
    );
  }
}
