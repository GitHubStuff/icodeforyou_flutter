// packages/since_when_framework/lib/src/database/lifecycle/database_lifecycle_cubit.dart

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:since_when_framework/src/database/configuration/database_access.dart';
import 'package:since_when_framework/src/database/configuration/database_configuration.dart';
import 'package:since_when_framework/src/database/failure/database_failure.dart';
import 'package:since_when_framework/src/database/handle/database_handle.dart';
import 'package:since_when_framework/src/database/handle/sqflite_handle.dart';
import 'package:since_when_framework/src/database/io/database_exporter.dart';
import 'package:since_when_framework/src/database/io/database_importer.dart';
import 'package:since_when_framework/src/database/lifecycle/database_lifecycle_state.dart';
import 'package:since_when_framework/src/database/setup/database_setup.dart';

/// Factory signature for producing a [DatabaseHandle] from a
/// [DatabaseConfiguration]. Defaults to [SqfliteHandle]; tests and alternate
/// backends inject their own.
typedef HandleFactory =
    Future<DatabaseHandle> Function(DatabaseConfiguration configuration);

/// Owns the database connection's lifecycle.
///
/// Emits [DatabaseLifecycleState] transitions as the connection moves
/// through open, schema install, ready, import/export, and close. Holds
/// zero knowledge of any specific tables — schema is supplied by callers
/// as a list of [DatabaseSetup] contributions.
class DatabaseLifecycleCubit extends Cubit<DatabaseLifecycleState> {
  DatabaseLifecycleCubit({HandleFactory? handleFactory})
    : _handleFactory = handleFactory ?? SqfliteHandle.open,
      super(const DatabaseClosed());

  final HandleFactory _handleFactory;

  DatabaseHandle? _handle;

  /// The currently open handle, or `null` if no database is open.
  DatabaseHandle? get currentHandle => _handle;

  // ─── Open ──────────────────────────────────────────────────────────────────

  /// Open the database described by [configuration], then install each
  /// [DatabaseSetup] in [setups] in order. Emits a sequence of states
  /// ending in [DatabaseReady] on success or [DatabaseFailed] on any
  /// error.
  Future<void> open({
    required DatabaseConfiguration configuration,
    List<DatabaseSetup> setups = const [],
  }) async {
    if (state is DatabaseOpening ||
        state is DatabaseInstallingSchema ||
        state is DatabaseReady) {
      return;
    }

    final preflightFailure = await _preflight(configuration);
    if (preflightFailure != null) {
      emit(DatabaseFailed(preflightFailure));
      return;
    }

    emit(const DatabaseOpening());

    final DatabaseHandle handle;
    try {
      handle = await _handleFactory(configuration);
    } on Object catch (e) {
      emit(DatabaseFailed(DatabaseOpenFailure(e)));
      return;
    }

    _handle = handle;

    for (final setup in setups) {
      emit(DatabaseInstallingSchema(currentSetupName: setup.name));
      try {
        await setup.install(handle);
      } on Object catch (e) {
        emit(
          DatabaseFailed(
            DatabaseSetupFailure(setupName: setup.name, cause: e),
          ),
        );
        return;
      }
    }

    emit(DatabaseReady(handle: handle));
  }

  Future<DatabaseFailure?> _preflight(
    DatabaseConfiguration configuration,
  ) async {
    if (!configuration.isFileBacked) return null;

    final (dbName, access) = _fileMetadata(configuration);
    if (dbName.trim().isEmpty) return const DatabaseInvalidName();

    final fullPath = await configuration.resolvePath();
    final exists = File(fullPath).existsSync();

    return switch (access) {
      DatabaseAccess.create when exists => const DatabaseAlreadyExists(),
      DatabaseAccess.open when !exists => const DatabaseNotFound(),
      _ => null,
    };
  }

  (String, DatabaseAccess) _fileMetadata(DatabaseConfiguration cfg) {
    return switch (cfg) {
      DatabaseConfigurationDocuments(:final dbName, :final access) =>
        (dbName, access),
      DatabaseConfigurationApplicationSupport(
        :final dbName,
        :final access,
      ) =>
        (dbName, access),
      DatabaseConfigurationInMemory() => ('', DatabaseAccess.automatic),
    };
  }

  // ─── Import / export ──────────────────────────────────────────────────────

  /// Run [importer] against the open handle. Requires [DatabaseReady];
  /// no-ops otherwise.
  Future<void> import(DatabaseImporter importer) async {
    final handle = _requireReadyHandle();
    if (handle == null) return;

    emit(DatabaseImporting(importerName: importer.name));
    try {
      await importer.import(handle);
      emit(DatabaseReady(handle: handle));
    } on Object catch (e) {
      emit(
        DatabaseFailed(
          DatabaseImportFailure(importerName: importer.name, cause: e),
        ),
      );
    }
  }

  /// Run [exporter] against the open handle. Requires [DatabaseReady];
  /// no-ops otherwise.
  Future<void> export(DatabaseExporter exporter) async {
    final handle = _requireReadyHandle();
    if (handle == null) return;

    emit(DatabaseExporting(exporterName: exporter.name));
    try {
      await exporter.export(handle);
      emit(DatabaseReady(handle: handle));
    } on Object catch (e) {
      emit(
        DatabaseFailed(
          DatabaseExportFailure(exporterName: exporter.name, cause: e),
        ),
      );
    }
  }

  DatabaseHandle? _requireReadyHandle() {
    final current = state;
    if (current is! DatabaseReady) return null;
    return current.handle;
  }

  // ─── Close ─────────────────────────────────────────────────────────────────

  /// Close the open connection. Safe to call from any state — closes if
  /// open, no-ops otherwise.
  Future<void> closeDatabase() async {
    final handle = _handle;
    if (handle == null) {
      emit(const DatabaseClosed());
      return;
    }

    emit(const DatabaseClosing());
    try {
      await handle.close();
      _handle = null;
      emit(const DatabaseClosed());
    } on Object catch (e) {
      emit(DatabaseFailed(DatabaseCloseFailure(e)));
    }
  }

  @override
  Future<void> close() async {
    await closeDatabase();
    return super.close();
  }
}
