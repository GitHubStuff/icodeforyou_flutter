// packages/sincewhen_drift_framework/lib/src/startup_methods.dart

import 'package:get_it/get_it.dart' show GetIt;
import 'package:sincewhen_drift_framework/src/database/database.dart'
    show SinceWhenDatabase;
import 'package:sincewhen_drift_framework/src/database/database_opening.dart'
    show SinceWhenDatabaseOpening;
import 'package:sincewhen_drift_framework/src/repositories/drift_glossary_repository.dart'
    show DriftGlossaryRepository;
import 'package:sincewhen_drift_framework/src/repositories/drift_since_when_repository.dart'
    show DriftSinceWhenRepository;
import 'package:sincewhen_drift_framework/src/repositories/drift_tag_repository.dart'
    show DriftTagRepository;
import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items_dao.dart'
    show GlossaryItemsDao;
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items_dao.dart'
    show SinceWhenItemsDao;
import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items_dao.dart'
    show TagItemsDao;
import 'package:sincewhen_models/sincewhen_models.dart'
    show GlossaryRepository, SinceWhenRepository, TagRepository;

/// Registers a database lazily, persisted in the application documents
/// folder as [fileName].
///
/// Registration is instant and side-effect-free; construction runs on
/// first resolution.
void registerDocumentDatabaseLazy(
  GetIt getIt, {
  required String fileName,
}) {
  _registerDatabaseLazy(
    getIt,
    () => SinceWhenDatabaseOpening.inDocumentFolder(fileName: fileName),
  );
}

/// Registers a database lazily, persisted in the application support
/// folder as [fileName].
///
/// Registration is instant and side-effect-free; construction runs on
/// first resolution.
void registerAppDatabaseLazy(
  GetIt getIt, {
  required String fileName,
}) {
  _registerDatabaseLazy(
    getIt,
    () => SinceWhenDatabaseOpening.inAppFolder(fileName: fileName),
  );
}

/// Registers an ephemeral in-memory database lazily.
///
/// No file name: nothing is persisted, and all data is lost when the
/// database closes. Lazy like the persisted registrations so all three
/// modes share the same lifecycle — construction runs on first
/// resolution, typically forced by [warmStartDatabase].
void registerInMemoryDatabaseLazy(GetIt getIt) {
  _registerDatabaseLazy(getIt, SinceWhenDatabaseOpening.inMemory);
}

/// Registers the glossary items DAO lazily, derived from the database.
///
/// The factory resolves [SinceWhenDatabase] from the same [getIt] when
/// it runs, so the database must be registered first.
void registerGlossaryItemsDao(GetIt getIt) {
  getIt.registerLazySingleton<GlossaryItemsDao>(
    () => getIt<SinceWhenDatabase>().glossaryItemsDao,
  );
}

/// Registers the persistence-free [GlossaryRepository] contract lazily,
/// bound to the drift implementation.
///
/// Registered against the interface from `sincewhen_models` — not the
/// concrete [DriftGlossaryRepository] — so consumers resolve and depend
/// on the contract only. Requires [registerGlossaryItemsDao] to have
/// been called on the same [getIt].
void registerGlossaryRepository(GetIt getIt) {
  getIt.registerLazySingleton<GlossaryRepository>(
    () => DriftGlossaryRepository(getIt<GlossaryItemsDao>()),
  );
}

/// Registers the since-when items DAO lazily, derived from the database.
///
/// The factory resolves [SinceWhenDatabase] from the same [getIt] when
/// it runs, so the database must be registered first.
void registerSinceWhenItemsDao(GetIt getIt) {
  getIt.registerLazySingleton<SinceWhenItemsDao>(
    () => getIt<SinceWhenDatabase>().sinceWhenItemsDao,
  );
}

/// Registers the persistence-free [SinceWhenRepository] contract lazily,
/// bound to the drift implementation.
///
/// Registered against the interface from `sincewhen_models` — not the
/// concrete [DriftSinceWhenRepository] — so consumers resolve and depend
/// on the contract only. Requires [registerSinceWhenItemsDao] to have
/// been called on the same [getIt].
void registerSinceWhenRepository(GetIt getIt) {
  getIt.registerLazySingleton<SinceWhenRepository>(
    () => DriftSinceWhenRepository(getIt<SinceWhenItemsDao>()),
  );
}

/// Registers the tag items DAO lazily, derived from the database.
///
/// The factory resolves [SinceWhenDatabase] from the same [getIt] when
/// it runs, so the database must be registered first.
void registerTagItemsDao(GetIt getIt) {
  getIt.registerLazySingleton<TagItemsDao>(
    () => getIt<SinceWhenDatabase>().tagItemsDao,
  );
}

/// Registers the persistence-free [TagRepository] contract lazily,
/// bound to the drift implementation.
///
/// Registered against the interface from `sincewhen_models` — not the
/// concrete [DriftTagRepository] — so consumers resolve and depend on
/// the contract only. Requires [registerTagItemsDao] to have been
/// called on the same [getIt].
void registerTagRepository(GetIt getIt) {
  getIt.registerLazySingleton<TagRepository>(
    () => DriftTagRepository(getIt<TagItemsDao>()),
  );
}

/// Spins the database up so it is ready before the user acts.
///
/// Resolving the DAO transitively constructs the database; awaiting
/// [GlossaryItemsDao.itemCount] forces the stack open — for persisted
/// modes that is folder resolution, file creation, schema setup, the
/// background isolate, and a real table read; for the in-memory mode
/// it is schema creation and the read.
Future<void> warmStartDatabase(GetIt getIt) async {
  final dao = getIt<GlossaryItemsDao>();
  await dao.itemCount();
}

/// Registers [open] as the lazy factory for the concrete
/// [SinceWhenDatabase].
///
/// The concrete type is registered — not a drift base type — because
/// the generated DAO accessors exist only on the concrete class, and
/// the DAO registration factories resolve it by exactly this type.
void _registerDatabaseLazy(GetIt getIt, SinceWhenDatabase Function() open) {
  getIt.registerLazySingleton<SinceWhenDatabase>(open);
}
