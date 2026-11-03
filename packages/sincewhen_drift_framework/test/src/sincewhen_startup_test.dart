import 'package:get_it/get_it.dart';
import 'package:sincewhen_drift_framework/sincewhen_drift_framework.dart'
    show
        GlossaryItemsDao,
        SinceWhenAppFolderConfiguration,
        SinceWhenDatabase,
        SinceWhenDocumentsConfiguration,
        SinceWhenInMemoryConfiguration,
        SinceWhenStartup;
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items_dao.dart' show SinceWhenItemsDao;
import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items_dao.dart' show TagItemsDao;
import 'package:sincewhen_models/sincewhen_models.dart' show GlossaryRepository, SinceWhenRepository, TagRepository;
import 'package:test/test.dart';

void main() {
  group('SinceWhenConfiguration', () {
    test('SinceWhenDocumentsConfiguration instantiates with fileName', () {
      const config = SinceWhenDocumentsConfiguration(fileName: 'docs.db');
      expect(config.fileName, equals('docs.db'));
    });

    test('SinceWhenAppFolderConfiguration instantiates with fileName', () {
      const config = SinceWhenAppFolderConfiguration(fileName: 'app.db');
      expect(config.fileName, equals('app.db'));
    });

    test('SinceWhenInMemoryConfiguration instantiates correctly', () {
      const config = SinceWhenInMemoryConfiguration();
      expect(config, isA<SinceWhenInMemoryConfiguration>());
    });
  });

  group('SinceWhenStartup', () {
    late GetIt getIt;

    setUp(() {
      getIt = GetIt.asNewInstance();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test(
      'start with SinceWhenInMemoryConfiguration registers and warms db',
      () async {
        const config = SinceWhenInMemoryConfiguration();

        await SinceWhenStartup.start(getIt, config);

        // Verify database and DAOs/repositories are registered and warmed
        expect(getIt.isRegistered<SinceWhenDatabase>(), isTrue);
        expect(getIt.isRegistered<GlossaryItemsDao>(), isTrue);
        expect(getIt.isRegistered<SinceWhenItemsDao>(), isTrue);
        expect(getIt.isRegistered<TagItemsDao>(), isTrue);
        expect(getIt.isRegistered<GlossaryRepository>(), isTrue);
        expect(getIt.isRegistered<SinceWhenRepository>(), isTrue);
        expect(getIt.isRegistered<TagRepository>(), isTrue);
      },
    );

    test(
      'start with SinceWhenDocumentsConfiguration registers database branch',
      () async {
        const config = SinceWhenDocumentsConfiguration(
          fileName: 'test_docs.db',
        );

        await SinceWhenStartup.start(getIt, config);

        expect(getIt.isRegistered<SinceWhenDatabase>(), isTrue);
        expect(getIt.isRegistered<GlossaryItemsDao>(), isTrue);
        expect(getIt.isRegistered<SinceWhenItemsDao>(), isTrue);
        expect(getIt.isRegistered<TagItemsDao>(), isTrue);
      },
    );

    test(
      'start with SinceWhenAppFolderConfiguration registers database branch',
      () async {
        const config = SinceWhenAppFolderConfiguration(fileName: 'test_app.db');

        await SinceWhenStartup.start(getIt, config);

        expect(getIt.isRegistered<SinceWhenDatabase>(), isTrue);
        expect(getIt.isRegistered<GlossaryItemsDao>(), isTrue);
        expect(getIt.isRegistered<SinceWhenItemsDao>(), isTrue);
        expect(getIt.isRegistered<TagItemsDao>(), isTrue);
      },
    );

    test('warm invokes warmStartDatabase directly', () async {
      // Register dependencies first per the contract requirements
      const config = SinceWhenInMemoryConfiguration();
      await SinceWhenStartup.start(getIt, config);

      // Explicitly exercise the static warm method directly for full coverage
      await expectLater(SinceWhenStartup.warm(getIt), completes);
    });
  });
}
