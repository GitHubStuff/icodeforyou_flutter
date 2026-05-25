// startup_demo/lib/src/pages/database_page/snapshot_card.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Displays the most recently produced export snapshot.
///
/// The snapshot text is rendered as [SelectableText] so the user can
/// copy it out for inspection or for piping back into the importer.
/// The host ([DatabasePageBody]) only shows this card when a snapshot
/// has actually been captured — passing an empty string here is
/// allowed but yields an empty card.
class SnapshotCard extends StatelessWidget {
  const SnapshotCard({required this.snapshot, super.key});

  /// The JSON-encoded snapshot text to display.
  final String snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last export snapshot', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(
              snapshot,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
