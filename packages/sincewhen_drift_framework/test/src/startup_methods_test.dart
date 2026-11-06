// packages/sincewhen_drift_framework/test/src/startup_methods_test.dart

import 'package:get_it/get_it.dart';
import 'package:sincewhen_drift_framework/sincewhen_drift_framework.dart'
    show
        DriftGlossaryRepository,
        DriftSinceWhenRepository,
        DriftTagRepository,
        GlossaryItemsDao,
        SinceWhenDatabase;
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
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items_dao.dart'
    show SinceWhenItemsDao;
import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items_dao.dart'
    show TagItemsDao;
import 'package:sincewhen_models/sincewhen_models.dart'
    show GlossaryRepository, SinceWhenRepository, TagRepository;
import 'package:test/test.dart';

void main() {
  group('startup_methods', () {
    late GetIt getIt;

    setUp(() {
      getIt = GetIt.asNewInstance();
    });

    tearDown(() async {
      if (getIt.isRegistered<SinceWhenDatabase>()) {
        try {
          await getIt<SinceWhenDatabase>().close();
        } catch (_) {}
      }
      await getIt.reset();
    });

    test(
      'registerInMemoryDatabaseLazy registers and resolves SinceWhenDatabase',
      () {
        registerInMemoryDatabaseLazy(getIt);

        expect(getIt.isRegistered<SinceWhenDatabase>(), isTrue);
        final db = getIt<SinceWhenDatabase>();
        expect(db, isA<SinceWhenDatabase>());
      },
    );

    test(
      'registerDocumentDatabaseLazy registers and resolves SinceWhenDatabase',
      () {
        registerDocumentDatabaseLazy(getIt, fileName: 'test_doc.db');

        expect(getIt.isRegistered<SinceWhenDatabase>(), isTrue);
        final db = getIt<SinceWhenDatabase>();
        expect(db, isA<SinceWhenDatabase>());
      },
    );

    test(
      'registerAppDatabaseLazy registers and resolves SinceWhenDatabase',
      () {
        registerAppDatabaseLazy(getIt, fileName: 'test_app.db');

        expect(getIt.isRegistered<SinceWhenDatabase>(), isTrue);
        final db = getIt<SinceWhenDatabase>();
        expect(db, isA<SinceWhenDatabase>());
      },
    );

    test(
      'registerGlossaryItemsDao registers and resolves GlossaryItemsDao',
      () {
        registerInMemoryDatabaseLazy(getIt);
        registerGlossaryItemsDao(getIt);

        expect(getIt.isRegistered<GlossaryItemsDao>(), isTrue);
        final dao = getIt<GlossaryItemsDao>();
        expect(dao, isA<GlossaryItemsDao>());
      },
    );

    test(
      'registerGlossaryRepository registers and resolves GlossaryRepository',
      () {
        registerInMemoryDatabaseLazy(getIt);
        registerGlossaryItemsDao(getIt);
        registerGlossaryRepository(getIt);

        expect(getIt.isRegistered<GlossaryRepository>(), isTrue);
        final repo = getIt<GlossaryRepository>();
        expect(repo, isA<GlossaryRepository>());
        expect(repo, isA<DriftGlossaryRepository>());
      },
    );

    test(
      'registerSinceWhenItemsDao registers and resolves SinceWhenItemsDao',
      () {
        registerInMemoryDatabaseLazy(getIt);
        registerSinceWhenItemsDao(getIt);

        expect(getIt.isRegistered<SinceWhenItemsDao>(), isTrue);
        final dao = getIt<SinceWhenItemsDao>();
        expect(dao, isA<SinceWhenItemsDao>());
      },
    );

    test(
      'registerSinceWhenRepository registers and resolves SinceWhenRepository',
      () {
        registerInMemoryDatabaseLazy(getIt);
        registerSinceWhenItemsDao(getIt);
        registerSinceWhenRepository(getIt);

        expect(getIt.isRegistered<SinceWhenRepository>(), isTrue);
        final repo = getIt<SinceWhenRepository>();
        expect(repo, isA<SinceWhenRepository>());
        expect(repo, isA<DriftSinceWhenRepository>());
      },
    );

    test('registerTagItemsDao registers and resolves TagItemsDao', () {
      registerInMemoryDatabaseLazy(getIt);
      registerTagItemsDao(getIt);

      expect(getIt.isRegistered<TagItemsDao>(), isTrue);
      final dao = getIt<TagItemsDao>();
      expect(dao, isA<TagItemsDao>());
    });

    test('registerTagRepository registers and resolves TagRepository', () {
      registerInMemoryDatabaseLazy(getIt);
      registerTagItemsDao(getIt);
      registerTagRepository(getIt);

      expect(getIt.isRegistered<TagRepository>(), isTrue);
      final repo = getIt<TagRepository>();
      expect(repo, isA<TagRepository>());
      expect(repo, isA<DriftTagRepository>());
    });

    test(
      'warmStartDatabase resolves GlossaryItemsDao and awaits itemCount()',
      () async {
        registerInMemoryDatabaseLazy(getIt);
        registerGlossaryItemsDao(getIt);

        await expectLater(warmStartDatabase(getIt), completes);
      },
    );
  });
}
