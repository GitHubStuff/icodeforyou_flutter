// packages/sincewhen_drift_framework/test/src/startup_methods_test.dart

import 'package:dependency_resolver/dependency_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/repositories/drift_glossary_repository.dart';
import 'package:sincewhen_drift_framework/src/repositories/drift_since_when_repository.dart';
import 'package:sincewhen_drift_framework/src/repositories/drift_tag_repository.dart';
import 'package:sincewhen_drift_framework/src/startup_methods.dart';
import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items_dao.dart';
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items_dao.dart';
import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items_dao.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

void main() {
  group('startup_methods', () {
    late GetIt getIt;
    late DependencyContainer container;

    setUp(() {
      getIt = GetIt.asNewInstance();
      container = GetItDependencyResolver(getIt: getIt);
    });

    tearDown(() async {
      if (container.isRegistered<SinceWhenDatabase>()) {
        await container.get<SinceWhenDatabase>().close();
      }
      await getIt.reset();
    });

    group('registerInMemoryDatabaseLazy', () {
      test('registers a lazily constructed working database', () async {
        await registerInMemoryDatabaseLazy(container);

        expect(container.isRegistered<SinceWhenDatabase>(), isTrue);
        final database = container.get<SinceWhenDatabase>();
        final rows = await database.customSelect('SELECT 1 AS one').get();
        expect(rows.single.read<int>('one'), 1);
      });
    });

    group('registerDocumentDatabaseLazy', () {
      test('registers without side effects; resolution constructs',
          () async {
        await registerDocumentDatabaseLazy(
          container,
          fileName: 'documents.sqlite',
        );

        expect(container.isRegistered<SinceWhenDatabase>(), isTrue);
        // Constructing runs the registered factory; the LazyDatabase
        // inside defers all file-system work, so no platform stubs are
        // needed here. Actually opening is exercised in
        // database_opening_test.dart.
        expect(container.get<SinceWhenDatabase>, returnsNormally);
      });
    });

    group('registerAppDatabaseLazy', () {
      test('registers without side effects; resolution constructs',
          () async {
        await registerAppDatabaseLazy(container, fileName: 'app.sqlite');

        expect(container.isRegistered<SinceWhenDatabase>(), isTrue);
        expect(container.get<SinceWhenDatabase>, returnsNormally);
      });
    });

    group('dao registrations', () {
      setUp(() async {
        await registerInMemoryDatabaseLazy(container);
      });

      test('registerGlossaryItemsDao resolves the database accessor',
          () async {
        await registerGlossaryItemsDao(container);

        final dao = container.get<GlossaryItemsDao>();
        expect(dao, same(container.get<SinceWhenDatabase>().glossaryItemsDao));
      });

      test('registerSinceWhenItemsDao resolves the database accessor',
          () async {
        await registerSinceWhenItemsDao(container);

        final dao = container.get<SinceWhenItemsDao>();
        expect(
          dao,
          same(container.get<SinceWhenDatabase>().sinceWhenItemsDao),
        );
      });

      test('registerTagItemsDao resolves the database accessor', () async {
        await registerTagItemsDao(container);

        final dao = container.get<TagItemsDao>();
        expect(dao, same(container.get<SinceWhenDatabase>().tagItemsDao));
      });
    });

    group('repository registrations', () {
      setUp(() async {
        await registerInMemoryDatabaseLazy(container);
        await registerGlossaryItemsDao(container);
        await registerSinceWhenItemsDao(container);
        await registerTagItemsDao(container);
      });

      test('registerGlossaryRepository binds the contract to drift',
          () async {
        await registerGlossaryRepository(container);

        expect(
          container.get<GlossaryRepository>(),
          isA<DriftGlossaryRepository>(),
        );
      });

      test('registerSinceWhenRepository binds the contract to drift',
          () async {
        await registerSinceWhenRepository(container);

        expect(
          container.get<SinceWhenRepository>(),
          isA<DriftSinceWhenRepository>(),
        );
      });

      test('registerTagRepository binds the contract to drift', () async {
        await registerTagRepository(container);

        expect(container.get<TagRepository>(), isA<DriftTagRepository>());
      });
    });

    group('warmStartDatabase', () {
      test('forces the stack open through the glossary dao', () async {
        await registerInMemoryDatabaseLazy(container);
        await registerGlossaryItemsDao(container);

        await warmStartDatabase(container);

        // Warm implies open: a direct read now succeeds immediately.
        expect(
          await container.get<SinceWhenDatabase>().glossaryItemsDao
              .itemCount(),
          0,
        );
      });
    });
  });
}
