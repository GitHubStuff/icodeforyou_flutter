// packages/sincewhen_drift_framework/lib/src/startup_methods.dart

import 'package:dependency_resolver/dependency_resolver.dart'
    show DependencyContainer, DependencyRegistrar, DependencyResolver;
import 'package:sincewhen_drift_framework/src/database/database.dart'
    show SinceWhenDatabase;
import 'package:sincewhen_drift_framework/src/database/database_opening.dart'
    show SinceWhenDatabaseOpening;
import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items_dao.dart'
    show GlossaryItemsDao;
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items_dao.dart'
    show SinceWhenItemsDao;
import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items_dao.dart'
    show TagItemsDao;

/// Registers a database lazily, persisted in the application documents
/// folder as [fileName].
///
/// Registration is instant and side-effect-free; construction runs on
/// first resolution.
Future<void> registerDocumentDatabaseLazy(
  DependencyRegistrar registrar, {
  required String fileName,
}) async {
  _registerDatabaseLazy(
    registrar,
    () => SinceWhenDatabaseOpening.inDocumentFolder(fileName: fileName),
  );
}

/// Registers a database lazily, persisted in the application support
/// folder as [fileName].
///
/// Registration is instant and side-effect-free; construction runs on
/// first resolution.
Future<void> registerAppDatabaseLazy(
  DependencyRegistrar registrar, {
  required String fileName,
}) async {
  _registerDatabaseLazy(
    registrar,
    () => SinceWhenDatabaseOpening.inAppFolder(fileName: fileName),
  );
}

/// Registers an ephemeral in-memory database lazily.
///
/// No file name: nothing is persisted, and all data is lost when the
/// database closes. Lazy like the persisted registrations so all three
/// modes share the same lifecycle — construction runs on first
/// resolution, typically forced by [warmStartDatabase].
Future<void> registerInMemoryDatabaseLazy(DependencyRegistrar registrar) async {
  _registerDatabaseLazy(registrar, SinceWhenDatabaseOpening.inMemory);
}

/// Registers the glossary items DAO lazily, derived from the database.
///
/// Takes the full [DependencyContainer] because the factory both
/// registers (now) and resolves (later, when it runs).
Future<void> registerGlossaryItemsDao(DependencyContainer container) async {
  container.registerLazySingleton<GlossaryItemsDao>(
    () => container.get<SinceWhenDatabase>().glossaryItemsDao,
  );
}

/// Registers the since-when items DAO lazily, derived from the database.
///
/// Takes the full [DependencyContainer] because the factory both
/// registers (now) and resolves (later, when it runs).
Future<void> registerSinceWhenItemsDao(DependencyContainer container) async {
  container.registerLazySingleton<SinceWhenItemsDao>(
    () => container.get<SinceWhenDatabase>().sinceWhenItemsDao,
  );
}

/// Registers the tag items DAO lazily, derived from the database.
///
/// Takes the full [DependencyContainer] because the factory both
/// registers (now) and resolves (later, when it runs).
Future<void> registerTagItemsDao(DependencyContainer container) async {
  container.registerLazySingleton<TagItemsDao>(
    () => container.get<SinceWhenDatabase>().tagItemsDao,
  );
}

/// Spins the database up so it is ready before the user acts.
///
/// Resolving the DAO transitively constructs the database; awaiting
/// [GlossaryItemsDao.itemCount] forces the stack open — for persisted
/// modes that is folder resolution, file creation, schema setup, the
/// background isolate, and a real table read; for the in-memory mode
/// it is schema creation and the read.
Future<void> warmStartDatabase(DependencyResolver resolver) async {
  final dao = resolver.get<GlossaryItemsDao>();
  await dao.itemCount();
}

/// Registers [open] as the lazy factory for the concrete
/// [SinceWhenDatabase].
///
/// The concrete type is registered — not a drift base type — because
/// the generated DAO accessors exist only on the concrete class, and
/// the DAO registration factories resolve it by exactly this type.
void _registerDatabaseLazy(
  DependencyRegistrar registrar,
  SinceWhenDatabase Function() open,
) {
  registrar.registerLazySingleton<SinceWhenDatabase>(open);
}
