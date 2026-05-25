// startup_demo/lib/src/pages/database_page/state_panel.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:since_when_framework/database.dart'
    show
        DatabaseClosed,
        DatabaseClosing,
        DatabaseExporting,
        DatabaseFailed,
        DatabaseImporting,
        DatabaseInstallingSchema,
        DatabaseLifecycleCubit,
        DatabaseLifecycleState,
        DatabaseOpening,
        DatabaseReady;

/// Always-visible badge displaying the cubit's current
/// [DatabaseLifecycleState] in monospace, prefixed by a colored dot.
///
/// Exhaustive switch on the sealed state hierarchy — adding a new
/// state to the framework would force the analyzer to flag this file
/// for an update, which is exactly the safety the sealed hierarchy is
/// there to provide.
///
/// Color palette:
/// - primary (themed)  — Ready
/// - error   (themed)  — Failed
/// - outline (themed)  — Closed (idle)
/// - tertiary          — transient states (Opening / InstallingSchema /
///                       Importing / Exporting / Closing)
class StatePanel extends StatelessWidget {
  const StatePanel({super.key});

  /// Formats the state into a single human-readable line, including
  /// inline arguments where the variant carries them.
  String _describe(DatabaseLifecycleState state) => switch (state) {
    DatabaseClosed() => 'DatabaseClosed',
    DatabaseOpening() => 'DatabaseOpening',
    DatabaseInstallingSchema(:final currentSetupName) =>
      'DatabaseInstallingSchema(currentSetupName: $currentSetupName)',
    DatabaseReady() => 'DatabaseReady(handle: …)',
    DatabaseImporting(:final importerName) =>
      'DatabaseImporting(importerName: $importerName)',
    DatabaseExporting(:final exporterName) =>
      'DatabaseExporting(exporterName: $exporterName)',
    DatabaseClosing() => 'DatabaseClosing',
    DatabaseFailed(:final failure) => 'DatabaseFailed($failure)',
  };

  /// Resolves the dot color for a given state.
  Color _stateColor(DatabaseLifecycleState state, ColorScheme scheme) =>
      switch (state) {
        DatabaseReady() => scheme.primary,
        DatabaseFailed() => scheme.error,
        DatabaseClosed() => scheme.outline,
        _ => scheme.tertiary,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DatabaseLifecycleCubit, DatabaseLifecycleState>(
      builder: (context, state) => Card(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: _stateColor(state, theme.colorScheme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _describe(state),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
