// lib/packages/app_preferences/src/hive/hive_init_mode.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:app_preferences/app_preferences.dart' show HiveInitMode;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Overview', type: HiveInitModeShowcase)
Widget hiveInitModeOverview(BuildContext context) {
  final selected = context.knobs.object.dropdown<HiveInitMode>(
    label: 'Selected mode',
    options: HiveInitMode.values,
    initialOption: HiveInitMode.productionDocuments,
    labelBuilder: (m) => m.name,
  );
  return HiveInitModeShowcase(selected: selected);
}

/// Showcase for the [HiveInitMode] enum. Lists every variant with its
/// storage location and intended use, and highlights the selected one.
class HiveInitModeShowcase extends StatelessWidget {
  const HiveInitModeShowcase({required this.selected, super.key});

  final HiveInitMode selected;

  static const _entries = <(HiveInitMode, String, String, IconData)>[
    (
      HiveInitMode.test,
      'System temp directory',
      'OS-reclaimed. Use in unit & widget tests; the directory is cleaned '
          'up by the OS so leftover boxes do not pollute the next run.',
      Icons.science,
    ),
    (
      HiveInitMode.productionDocuments,
      'getApplicationDocumentsDirectory()',
      'User-visible documents. Backed up to iCloud on iOS — use only for '
          'data the user should be able to recover after a restore.',
      Icons.folder_special,
    ),
    (
      HiveInitMode.productionSupport,
      'getApplicationSupportDirectory()',
      'App-private support storage. Not backed up on iOS — appropriate '
          'for caches, derived data, and most preferences.',
      Icons.settings_suggest,
    ),
    (
      HiveInitMode.custom,
      'Caller-supplied path',
      'Use when the host app needs full control of the storage location '
          '— e.g. a NAS-mounted directory, or a shared container between '
          'an app and its extension.',
      Icons.edit_location,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
            itemCount: _entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final (mode, location, blurb, icon) = _entries[i];
              final isSelected = mode == selected;
              return Card(
                margin: EdgeInsets.zero,
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: isSelected ? Colors.indigo : null),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HiveInitMode.${mode.name}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              location,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(blurb),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
