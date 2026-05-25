// packages/since_when_framework/lib/src/database/setup/database_setup.dart

import 'package:since_when_framework/src/database/handle/database_handle.dart';

/// A pluggable schema installer.
///
/// Consumer packages (since_when, an app's own tables, third-party packages)
/// ship one or more implementations and pass them to the lifecycle cubit at
/// open time. The framework runs each in order during the
/// `DatabaseInstallingSchema` phase, before announcing `DatabaseReady`.
///
/// Implementations should be idempotent — they will typically use
/// `CREATE TABLE IF NOT EXISTS` and `CREATE INDEX IF NOT EXISTS` so
/// re-opening an existing database is a no-op.
abstract interface class DatabaseSetup {
  /// Human-readable name used for logging and failure reporting.
  ///
  /// When a setup throws, the framework wraps the cause in a
  /// `DatabaseSetupFailure` carrying this name so the caller knows which
  /// contribution failed.
  String get name;

  /// Install this contribution's schema against [handle].
  Future<void> install(DatabaseHandle handle);
}
