// packages/sincewhen_drift_framework/lib/src/sincewhen_startup.dart

import 'package:get_it/get_it.dart' show GetIt;
import 'package:sincewhen_drift_framework/src/startup_methods.dart'
    show
        registerAppDatabaseLazy,
        registerDocumentDatabaseLazy,
        registerGlossaryItemsDao,
        registerGlossaryRepository,
        registerInMemoryDatabaseLazy,
        registerSinceWhenItemsDao,
        registerSinceWhenRepository,
        registerTagItemsDao,
        registerTagRepository,
        warmStartDatabase;

/// Where the since_when database lives.
sealed class SinceWhenConfiguration {
  const SinceWhenConfiguration();
}

/// Persisted in the application documents folder as [fileName].
final class SinceWhenDocumentsConfiguration extends SinceWhenConfiguration {
  /// Creates a documents-folder configuration.
  const SinceWhenDocumentsConfiguration({required this.fileName});

  /// Database file name within the documents folder.
  final String fileName;
}

/// Persisted in the application support folder as [fileName].
final class SinceWhenAppFolderConfiguration extends SinceWhenConfiguration {
  /// Creates an application-support-folder configuration.
  const SinceWhenAppFolderConfiguration({required this.fileName});

  /// Database file name within the application support folder.
  final String fileName;
}

/// Ephemeral in-memory database; nothing is persisted.
final class SinceWhenInMemoryConfiguration extends SinceWhenConfiguration {
  /// Creates an in-memory configuration.
  const SinceWhenInMemoryConfiguration();
}

/// Composition-root facade for the since_when subsystem.
///
/// Applications declare a [SinceWhenConfiguration] and call [start];
/// registration of the database, DAOs, and persistence-free repository
/// contracts happens here, so app code never touches the individual
/// registration functions.
abstract final class SinceWhenStartup {
  /// Registers and warm-starts the subsystem on [getIt]: registration
  /// then [warm], in that order, guaranteed.
  ///
  /// The one-call entry point for startup task lists. The
  /// register-before-warm ordering is owned here so no call site can
  /// invert it. Apps pass `GetIt.I`; tests pass `GetIt.asNewInstance()`.
  static Future<void> start(
    GetIt getIt,
    SinceWhenConfiguration configuration,
  ) async {
    _register(getIt, configuration);
    await warm(getIt);
  }

  /// Forces the database stack open so it is ready before the user acts.
  ///
  /// Requires the subsystem to be registered on [getIt] — use [start],
  /// which guarantees it. Open failures throw here and surface through
  /// the startup runner as normal exceptions.
  static Future<void> warm(GetIt getIt) => warmStartDatabase(getIt);

  /// Registers the database (per [configuration]), all DAOs, and the
  /// persistence-free repository contracts with [getIt].
  ///
  /// Instant and side-effect-free: only factories are stored. Nothing
  /// opens until first resolution — typically forced by [warm].
  static void _register(GetIt getIt, SinceWhenConfiguration configuration) {
    switch (configuration) {
      case SinceWhenDocumentsConfiguration(:final fileName):
        registerDocumentDatabaseLazy(getIt, fileName: fileName);
      case SinceWhenAppFolderConfiguration(:final fileName):
        registerAppDatabaseLazy(getIt, fileName: fileName);
      case SinceWhenInMemoryConfiguration():
        registerInMemoryDatabaseLazy(getIt);
    }

    // DAOs
    registerGlossaryItemsDao(getIt);
    registerSinceWhenItemsDao(getIt);
    registerTagItemsDao(getIt);
    // Repositories
    registerGlossaryRepository(getIt);
    registerSinceWhenRepository(getIt);
    registerTagRepository(getIt);
  }
}
