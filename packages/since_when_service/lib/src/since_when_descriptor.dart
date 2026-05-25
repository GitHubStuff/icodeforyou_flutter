// packages/since_when_service/lib/src/since_when_descriptor.dart

import 'dart:async';

import 'package:flutter/services.dart'
    show BackgroundIsolateBinaryMessenger, RootIsolateToken;
import 'package:service_locator/service_locator.dart'
    show LazyAsyncServiceDescriptor, ServiceItemTimeout;
import 'package:since_when_framework/database.dart'
    show
        DatabaseAccess,
        DatabaseConfiguration,
        DatabaseFailed,
        DatabaseLifecycleCubit,
        DatabaseReady,
        DatabaseSetup;
import 'package:since_when_service/src/since_when_service_class.dart';

/// Service-locator descriptor for [SinceWhenServiceClass].
///
/// Builds a [DatabaseLifecycleCubit], calls `open(...)` against the
/// configured [DatabaseConfiguration] and [setups], and waits for the
/// cubit to reach [DatabaseReady] before handing the service back to
/// the locator.
///
/// Four named constructors:
///
/// - [SinceWhenDescriptor.documents]          — application documents directory.
/// - [SinceWhenDescriptor.applicationSupport] — application support directory.
/// - [SinceWhenDescriptor.inMemory]           — in-memory (tests, viewers).
/// - [SinceWhenDescriptor.fromConfiguration]  — pre-built configuration.
///
/// The `documents` and `applicationSupport` constructors are non-const
/// because they call `DatabaseConfiguration.documents(...)` /
/// `.applicationSupport(...)` with parameter values; const constructors
/// require all-literal inputs. The `inMemory` and `fromConfiguration`
/// constructors are const.
///
/// Failure handling: if the cubit lands in [DatabaseFailed], the wrapped
/// `DatabaseFailure` is thrown directly. It implements [Exception] so it
/// propagates through the locator's `ServiceStartupFailed` wrapping with
/// the typed failure preserved for downstream pattern-matching.
class SinceWhenDescriptor
    extends LazyAsyncServiceDescriptor<SinceWhenServiceClass> {
  /// Documents-directory backed descriptor.
  SinceWhenDescriptor.documents({
    required String dbName,
    String subdirectory = 'db',
    DatabaseAccess access = DatabaseAccess.automatic,
    this.setups = const [],
    Duration timeout = const Duration(seconds: 5),
  }) : configuration = DatabaseConfiguration.documents(
         dbName: dbName,
         subdirectory: subdirectory,
         access: access,
       ),
       _timeout = timeout;

  /// Application-support-directory backed descriptor.
  SinceWhenDescriptor.applicationSupport({
    required String dbName,
    String subdirectory = 'db',
    DatabaseAccess access = DatabaseAccess.automatic,
    this.setups = const [],
    Duration timeout = const Duration(seconds: 5),
  }) : configuration = DatabaseConfiguration.applicationSupport(
         dbName: dbName,
         subdirectory: subdirectory,
         access: access,
       ),
       _timeout = timeout;

  /// In-memory descriptor — the database lives only for the lifetime
  /// of this service instance. Intended for tests and the sqlite_viewer
  /// workflow.
  const SinceWhenDescriptor.inMemory({
    this.setups = const [],
    Duration timeout = const Duration(seconds: 5),
  }) : configuration = const DatabaseConfiguration.inMemory(),
       _timeout = timeout;

  /// Escape hatch — construct from a pre-built [DatabaseConfiguration].
  /// Used when the caller already has a configuration value (e.g. from
  /// app settings) and doesn't want to unpack and repack it.
  const SinceWhenDescriptor.fromConfiguration({
    required this.configuration,
    this.setups = const [],
    Duration timeout = const Duration(seconds: 5),
  }) : _timeout = timeout;

  /// The configuration used to open the database.
  final DatabaseConfiguration configuration;

  /// Schema contributions run during the `InstallingSchema` phase. Empty
  /// by default — the calling app composes its own list (e.g. the
  /// since_when adapter, plus any app-specific tables).
  final List<DatabaseSetup> setups;

  final Duration _timeout;

  @override
  String get name => 'SinceWhen';

  @override
  List<Type> get dependencies => const [];

  @override
  Duration get timeout => _timeout;

  @override
  Future<SinceWhenServiceClass> Function() get builder => () async {
    final token = RootIsolateToken.instance;
    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }

    final cubit = DatabaseLifecycleCubit();

    try {
      await cubit
          .open(configuration: configuration, setups: setups)
          .timeout(timeout);
    } on TimeoutException {
      await cubit.close();
      throw ServiceItemTimeout(name, timeout);
    }

    final state = cubit.state;
    if (state is DatabaseFailed) {
      final failure = state.failure;
      await cubit.close();
      throw failure;
    }
    if (state is! DatabaseReady) {
      await cubit.close();
      throw StateError(
        'Database lifecycle cubit settled in unexpected state $state '
        'after open(...) completed. Expected DatabaseReady or '
        'DatabaseFailed.',
      );
    }

    return SinceWhenServiceClass(cubit);
  };
}
