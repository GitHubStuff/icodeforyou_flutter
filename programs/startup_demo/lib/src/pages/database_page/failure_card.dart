// startup_demo/lib/src/pages/database_page/failure_card.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:since_when_framework/database.dart'
    show DatabaseFailure, DatabaseLifecycleCubit;

/// Renders a [DatabaseFailure] when the cubit is in `DatabaseFailed`.
///
/// Shows the failure's runtime type as a heading and its `toString()`
/// underneath in monospace — the failure's `toString` already includes
/// the structured cause via the framework's sealed failure hierarchy
/// (e.g. `DatabaseOpenFailure: <inner exception>` or
/// `DatabaseSetupFailure(setup="glossary"): <cause>`).
///
/// Exposes a "back to Closed" button that calls
/// [DatabaseLifecycleCubit.closeDatabase] — the cubit handles the
/// transition back to `DatabaseClosed` even from `DatabaseFailed`, so
/// this gives the user a way out without restarting the app.
class FailureCard extends StatelessWidget {
  const FailureCard({required this.failure, super.key});

  /// The failure to display.
  final DatabaseFailure failure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              failure.runtimeType.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$failure',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () =>
                  context.read<DatabaseLifecycleCubit>().closeDatabase(),
              child: const Text('back to Closed'),
            ),
          ],
        ),
      ),
    );
  }
}
