// programs/startup_demo/lib/src/pages/database_page/configuration_panel.dart

// ignore_for_file: comment_references

import 'package:flutter/material.dart';
import 'package:since_when_framework/database.dart' show DatabaseAccess;

/// Which [DatabaseConfiguration] variant the page is currently set to build.
///
/// One-to-one with the framework's three configuration constructors —
/// [DatabaseConfiguration.documents], [DatabaseConfiguration.applicationSupport],
/// [DatabaseConfiguration.inMemory] — kept as a separate enum so the
/// state owner ([DatabasePageBody]) can serialize the user's choice
/// independently of an actual configuration value.
enum ConfigChoice { documents, applicationSupport, inMemory }

/// User-facing picker for the [DatabaseConfiguration] variant, dbName,
/// and [DatabaseAccess] mode.
///
/// Pure: takes the current values + change callbacks. Owns no state of
/// its own. The dbName [TextField] and the [DatabaseAccess] segmented
/// button disable themselves when the chosen variant is in-memory
/// (those fields are meaningless without a file).
class ConfigurationPanel extends StatelessWidget {
  const ConfigurationPanel({
    required this.choice,
    required this.access,
    required this.dbNameController,
    required this.onChoiceChanged,
    required this.onAccessChanged,
    super.key,
  });

  /// Currently-selected configuration variant.
  final ConfigChoice choice;

  /// Currently-selected access mode. Ignored when [choice] is in-memory.
  final DatabaseAccess access;

  /// External controller for the dbName field — held by [DatabasePageBody]
  /// so its value survives rebuilds of this panel.
  final TextEditingController dbNameController;

  /// Fires when the user picks a different variant.
  final ValueChanged<ConfigChoice> onChoiceChanged;

  /// Fires when the user picks a different access mode.
  final ValueChanged<DatabaseAccess> onAccessChanged;

  bool get _fileBacked => choice != ConfigChoice.inMemory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DatabaseConfiguration', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<ConfigChoice>(
              segments: const [
                ButtonSegment(
                  value: ConfigChoice.documents,
                  label: Text('documents'),
                ),
                ButtonSegment(
                  value: ConfigChoice.applicationSupport,
                  label: Text('appSupport'),
                ),
                ButtonSegment(
                  value: ConfigChoice.inMemory,
                  label: Text('inMemory'),
                ),
              ],
              selected: {choice},
              onSelectionChanged: (s) => onChoiceChanged(s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dbNameController,
              enabled: _fileBacked,
              decoration: const InputDecoration(
                labelText: 'dbName',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text('DatabaseAccess', style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            SegmentedButton<DatabaseAccess>(
              segments: const [
                ButtonSegment(
                  value: DatabaseAccess.automatic,
                  label: Text('automatic'),
                ),
                ButtonSegment(
                  value: DatabaseAccess.create,
                  label: Text('create'),
                ),
                ButtonSegment(
                  value: DatabaseAccess.open,
                  label: Text('open'),
                ),
              ],
              selected: {access},
              onSelectionChanged: _fileBacked
                  ? (s) => onAccessChanged(s.first)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
