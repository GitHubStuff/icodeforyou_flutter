// packages/since_when_framework/lib/src/database/lifecycle/database_lifecycle_state.dart

import 'package:equatable/equatable.dart';
import 'package:since_when_framework/src/database/failure/database_failure.dart';
import 'package:since_when_framework/src/database/handle/database_handle.dart';

/// Sealed state hierarchy for the database connection's lifecycle.
///
/// Typical paths:
///   Closed ─► Opening ─► InstallingSchema ─► Ready ─► Closing ─► Closed
///   Ready  ─► Importing ─► Ready
///   Ready  ─► Exporting ─► Ready
///   any    ─► Failed(cause)
sealed class DatabaseLifecycleState extends Equatable {
  const DatabaseLifecycleState();

  @override
  List<Object?> get props => const [];
}

/// No database connection is held.
final class DatabaseClosed extends DatabaseLifecycleState {
  const DatabaseClosed();
}

/// Connection is being opened.
final class DatabaseOpening extends DatabaseLifecycleState {
  const DatabaseOpening();
}

/// A registered setup is installing or upgrading its schema.
final class DatabaseInstallingSchema extends DatabaseLifecycleState {
  const DatabaseInstallingSchema({required this.currentSetupName});

  final String currentSetupName;

  @override
  List<Object?> get props => [currentSetupName];
}

/// Connection is open and the live [DatabaseHandle] is available.
final class DatabaseReady extends DatabaseLifecycleState {
  const DatabaseReady({required this.handle});

  final DatabaseHandle handle;

  @override
  List<Object?> get props => [handle];
}

/// A registered importer is loading external data into the database.
final class DatabaseImporting extends DatabaseLifecycleState {
  const DatabaseImporting({required this.importerName});

  final String importerName;

  @override
  List<Object?> get props => [importerName];
}

/// A registered exporter is writing the database out to an external target.
final class DatabaseExporting extends DatabaseLifecycleState {
  const DatabaseExporting({required this.exporterName});

  final String exporterName;

  @override
  List<Object?> get props => [exporterName];
}

/// Connection is being closed.
final class DatabaseClosing extends DatabaseLifecycleState {
  const DatabaseClosing();
}

/// A lifecycle operation failed.
final class DatabaseFailed extends DatabaseLifecycleState {
  const DatabaseFailed(this.failure);

  final DatabaseFailure failure;

  @override
  List<Object?> get props => [failure];
}
