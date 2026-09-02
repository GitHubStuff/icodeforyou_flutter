// packages/sincewhen_drift_framework/lib/src/sincewhen_startup.dart

import 'package:dependency_resolver/dependency_resolver.dart'
    show DependencyContainer, DependencyResolver;
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
  /// Registers and warm-starts the subsystem: [setup] then [warm], in
  /// that order, guaranteed.
  ///
  /// The one-call entry point for startup task lists. The
  /// setup-before-warm ordering is owned here so no call site can
  /// invert it.
  static Future<void> start(
    DependencyContainer container,
    SinceWhenConfiguration configuration,
  ) async {
    await _setup(container, configuration);
    await warm(container);
  }

  /// Registers the database (per [configuration]), all DAOs, and the
  /// persistence-free repository contracts with [container].
  ///
  /// Instant and side-effect-free: only factories are stored. Nothing
  /// opens until first resolution — typically forced by [warm].
  static Future<void> _setup(
    DependencyContainer container,
    SinceWhenConfiguration configuration,
  ) async {
    switch (configuration) {
      case SinceWhenDocumentsConfiguration(:final fileName):
        await registerDocumentDatabaseLazy(container, fileName: fileName);
      case SinceWhenAppFolderConfiguration(:final fileName):
        await registerAppDatabaseLazy(container, fileName: fileName);
      case SinceWhenInMemoryConfiguration():
        await registerInMemoryDatabaseLazy(container);
    }

    // Daos
    await registerGlossaryItemsDao(container);
    await registerSinceWhenItemsDao(container);
    await registerTagItemsDao(container);
    // Repos
    await registerGlossaryRepository(container);
    await registerSinceWhenRepository(container);
    await registerTagRepository(container);
  }

  /// Forces the database stack open so it is ready before the user acts.
  ///
  /// Run after [setup] — or use [start], which guarantees it. Open
  /// failures throw here and surface through the startup runner as
  /// normal exceptions.
  static Future<void> warm(DependencyResolver resolver) =>
      warmStartDatabase(resolver);
}
