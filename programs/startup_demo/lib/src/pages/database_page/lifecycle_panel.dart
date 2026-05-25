// startup_demo/lib/src/pages/database_page/lifecycle_panel.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:since_when_framework/database.dart'
    show
        DatabaseClosed,
        DatabaseFailed,
        DatabaseLifecycleCubit,
        DatabaseLifecycleState,
        DatabaseReady;

/// Four-button row driving the lifecycle cubit: open, close, export, import.
///
/// Watches the ambient [DatabaseLifecycleCubit] to enable/disable each
/// button:
///
/// | Button   | Enabled when                              |
/// |----------|-------------------------------------------|
/// | open     | state is `DatabaseClosed` or `DatabaseFailed` |
/// | close    | state is `DatabaseReady`                  |
/// | export   | state is `DatabaseReady`                  |
/// | import   | state is `DatabaseReady` AND [canImport]  |
///
/// The panel itself doesn't know what the actions do — it forwards to
/// the supplied callbacks. [DatabasePageBody] wires those callbacks to
/// the cubit's `open` / `closeDatabase` / `export` / `import` methods
/// with the demo setups / importer / exporter.
class LifecyclePanel extends StatelessWidget {
  const LifecyclePanel({
    required this.onOpen,
    required this.onClose,
    required this.onExport,
    required this.onImport,
    required this.canImport,
    super.key,
  });

  /// Invoked when the user taps "open(...)".
  final VoidCallback onOpen;

  /// Invoked when the user taps "closeDatabase()".
  final VoidCallback onClose;

  /// Invoked when the user taps "export(...)".
  final VoidCallback onExport;

  /// Invoked when the user taps "import(...)".
  final VoidCallback onImport;

  /// Gates the import button. True when a previous export produced a
  /// snapshot the importer can replay.
  final bool canImport;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DatabaseLifecycleCubit, DatabaseLifecycleState>(
      builder: (context, state) {
        final isReady = state is DatabaseReady;
        final isClosed = state is DatabaseClosed || state is DatabaseFailed;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: isClosed ? onOpen : null,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('open(...)'),
                ),
                OutlinedButton.icon(
                  onPressed: isReady ? onClose : null,
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('closeDatabase()'),
                ),
                OutlinedButton.icon(
                  onPressed: isReady ? onExport : null,
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('export(...)'),
                ),
                OutlinedButton.icon(
                  onPressed: isReady && canImport ? onImport : null,
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('import(...)'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
