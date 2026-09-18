// packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_page/sqlite_viewer_page_helper_views.dart

part of 'sqlite_viewer_page.dart';

// =============================================================================
// Shared Helper Widgets
// =============================================================================

/// A placeholder view shown when no active database connection exists.
class DisconnectedView extends StatelessWidget {
  /// Creates a [DisconnectedView].
  const DisconnectedView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.link_off,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Not connected',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A progress indicator display with an accompanying status [message].
class LoadingView extends StatelessWidget {
  /// Creates a [LoadingView] displaying [message].
  const LoadingView({required this.message, super.key});

  /// The status or progress message shown below the indicator.
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// An error display that shows a [message] and an optional [onRetry] action.
class ErrorView extends StatelessWidget {
  /// Creates an [ErrorView].
  const ErrorView({required this.message, super.key, this.onRetry});

  /// The error description to display.
  final String message;

  /// Optional callback invoked when the user taps the retry button.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A placeholder view shown when no table has been selected yet.
class EmptyDataView extends StatelessWidget {
  /// Creates an [EmptyDataView].
  const EmptyDataView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a table to view data',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A prompt instructing the user to choose a table or enter a custom query.
class SelectTablePrompt extends StatelessWidget {
  /// Creates a [SelectTablePrompt].
  const SelectTablePrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a table from the sidebar',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'or enter a custom query below',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays the results of an executed SQL query in a tabular format.
class QueryResultView extends StatelessWidget {
  /// Creates a [QueryResultView].
  const QueryResultView({
    required this.query,
    required this.columns,
    required this.rows,
    required this.showRowNumbers,
    required this.nullValueDisplay,
    required this.textHandling,
    super.key,
  });

  /// The raw SQL query string that produced these results.
  final String query;

  /// The list of column headers returned by the query.
  final List<String> columns;

  /// The list of row records mapping column names to their cell values.
  final List<Map<String, Object?>> rows;

  /// Whether to render a leading row-index column.
  final bool showRowNumbers;

  /// The string placeholder used to represent SQL `NULL` values.
  final String nullValueDisplay;

  /// Determines how cell text overflow and wrapping are handled.
  final TextHandling textHandling;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Query returned no results',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Query header
        Container(
          padding: const EdgeInsets.all(12),
          color: colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Icon(Icons.code, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  query,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${rows.length} rows',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Results
        Expanded(
          child: DisplayQueryWidget(
            columns: columns,
            rows: rows,
            evenRowStyle:
                theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
            oddRowStyle:
                theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
            evenRowColor: colorScheme.surface,
            oddRowColor: colorScheme.surfaceContainerLowest,
            headerBackgroundColor: colorScheme.surfaceContainerHighest,
            showRowNumbers: showRowNumbers,
            nullValueDisplay: nullValueDisplay,
            textHandling: textHandling,
          ),
        ),
      ],
    );
  }
}
