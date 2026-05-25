// startup_demo/lib/src/pages/database_page/page_body.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:since_when_framework/database.dart'
    show
        DatabaseAccess,
        DatabaseConfiguration,
        DatabaseFailed,
        DatabaseLifecycleCubit,
        DatabaseLifecycleState,
        DatabaseReady;
import 'package:startup_demo/src/pages/database_page/configuration_panel.dart';
import 'package:startup_demo/src/pages/database_page/demo/demo_json_exporter.dart';
import 'package:startup_demo/src/pages/database_page/demo/demo_json_importer.dart';
import 'package:startup_demo/src/pages/database_page/demo/demo_logs_setup.dart';
import 'package:startup_demo/src/pages/database_page/demo/demo_things_setup.dart';
import 'package:startup_demo/src/pages/database_page/failure_card.dart';
import 'package:startup_demo/src/pages/database_page/lifecycle_panel.dart';
import 'package:startup_demo/src/pages/database_page/snapshot_card.dart';
import 'package:startup_demo/src/pages/database_page/sql_pad/sql_pad.dart';
import 'package:startup_demo/src/pages/database_page/state_panel.dart';

/// Stateful host that owns:
/// - The chosen [DatabaseConfiguration] variant and [DatabaseAccess] mode.
/// - The dbName text field controller.
/// - The most recent export snapshot (kept across lifecycle transitions so
///   import can replay it).
///
/// Composes [ConfigurationPanel], [LifecyclePanel], [StatePanel],
/// [SqlPad] / [FailureCard] (state-dependent), and [SnapshotCard]
/// (visible when a snapshot has been captured). Reads the
/// [DatabaseLifecycleCubit] from the ambient [BlocProvider].
class DatabasePageBody extends StatefulWidget {
  const DatabasePageBody({super.key});

  @override
  State<DatabasePageBody> createState() => _DatabasePageBodyState();
}

class _DatabasePageBodyState extends State<DatabasePageBody> {
  ConfigChoice _configChoice = ConfigChoice.inMemory;
  DatabaseAccess _access = DatabaseAccess.automatic;
  final TextEditingController _dbNameController = TextEditingController(
    text: 'demo.db',
  );
  String _exportSnapshot = '';

  @override
  void dispose() {
    _dbNameController.dispose();
    super.dispose();
  }

  /// Builds the [DatabaseConfiguration] currently selected by the user.
  DatabaseConfiguration _buildConfiguration() {
    final dbName = _dbNameController.text.trim();
    return switch (_configChoice) {
      ConfigChoice.documents => DatabaseConfiguration.documents(
        dbName: dbName,
        access: _access,
      ),
      ConfigChoice.applicationSupport =>
        DatabaseConfiguration.applicationSupport(
          dbName: dbName,
          access: _access,
        ),
      ConfigChoice.inMemory => const DatabaseConfiguration.inMemory(),
    };
  }

  Future<void> _open() async {
    await context.read<DatabaseLifecycleCubit>().open(
      configuration: _buildConfiguration(),
      setups: const [DemoThingsSetup(), DemoLogsSetup()],
    );
  }

  Future<void> _close() async {
    await context.read<DatabaseLifecycleCubit>().closeDatabase();
  }

  Future<void> _export() async {
    final exporter = DemoJsonExporter(
      onSnapshotProduced: (snapshot) =>
          setState(() => _exportSnapshot = snapshot),
    );
    await context.read<DatabaseLifecycleCubit>().export(exporter);
  }

  Future<void> _import() async {
    if (_exportSnapshot.isEmpty) return;
    final importer = DemoJsonImporter(snapshot: _exportSnapshot);
    await context.read<DatabaseLifecycleCubit>().import(importer);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConfigurationPanel(
                choice: _configChoice,
                access: _access,
                dbNameController: _dbNameController,
                onChoiceChanged: (c) => setState(() => _configChoice = c),
                onAccessChanged: (a) => setState(() => _access = a),
              ),
              const SizedBox(height: 16),
              LifecyclePanel(
                onOpen: _open,
                onClose: _close,
                onExport: _export,
                onImport: _import,
                canImport: _exportSnapshot.isNotEmpty,
              ),
              const SizedBox(height: 16),
              const StatePanel(),
              const SizedBox(height: 16),
              BlocBuilder<DatabaseLifecycleCubit, DatabaseLifecycleState>(
                builder: (context, state) => switch (state) {
                  DatabaseReady(:final handle) => SqlPad(handle: handle),
                  DatabaseFailed(:final failure) => FailureCard(
                    failure: failure,
                  ),
                  _ => const SizedBox.shrink(),
                },
              ),
              if (_exportSnapshot.isNotEmpty) ...[
                const SizedBox(height: 16),
                SnapshotCard(snapshot: _exportSnapshot),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
