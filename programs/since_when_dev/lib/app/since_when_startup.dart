// programs/since_when_dev/lib/app/since_when_startup.dart

import 'package:dependency_resolver/dependency_resolver.dart'
    show DependencyContainer, DependencyResolver;
import 'package:sincewhen_drift_framework/sincewhen_drift_framework.dart'
    show
        registerAppDatabaseLazy,
        registerDocumentDatabaseLazy,
        registerGlossaryItemsDao,
        registerInMemoryDatabaseLazy,
        registerSinceWhenItemsDao,
        registerTagItemsDao,
        warmStartDatabase;

/// Where the since_when database lives for this program.
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

/// Composition root for the since_when subsystem.
abstract final class SinceWhenStartup {
  /// Persisted development database in the documents folder.
  static const databaseConfiguration = SinceWhenDocumentsConfiguration(
    fileName: 'since_when_dev',
  );

  /// Persisted development database in the application support folder.
  static const appFolderConfiguration = SinceWhenAppFolderConfiguration(
    fileName: 'since_when_dev',
  );

  /// Ephemeral database for development runs.
  static const inMemoryConfiguration = SinceWhenInMemoryConfiguration();

  /// Registers the database (per [configuration]) and all DAOs with
  /// [container].
  ///
  /// Instant and side-effect-free: only factories are stored. Nothing
  /// opens until first resolution — typically forced by [warm].
  static Future<void> setup(
    DependencyContainer resolver,
    SinceWhenConfiguration configuration,
  ) async {
    switch (configuration) {
      case SinceWhenDocumentsConfiguration(:final fileName):
        await registerDocumentDatabaseLazy(resolver, fileName: fileName);
      case SinceWhenAppFolderConfiguration(:final fileName):
        await registerAppDatabaseLazy(resolver, fileName: fileName);
      case SinceWhenInMemoryConfiguration():
        await registerInMemoryDatabaseLazy(resolver);
    }

    await registerGlossaryItemsDao(resolver);
    await registerSinceWhenItemsDao(resolver);
    await registerTagItemsDao(resolver);
  }

  /// Forces the database stack open so it is ready before the user acts.
  ///
  /// Run as a startup task after [setup]. Open failures throw here and
  /// surface through the startup runner as normal exceptions.
  static Future<void> warm(DependencyResolver resolver) =>
      warmStartDatabase(resolver);
}
