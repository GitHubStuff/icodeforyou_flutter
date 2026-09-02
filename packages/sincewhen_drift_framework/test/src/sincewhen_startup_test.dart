// packages/sincewhen_drift_framework/test/src/sincewhen_startup_test.dart

import 'dart:io';

import 'package:dependency_resolver/dependency_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/sincewhen_startup.dart';
import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items_dao.dart';
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items_dao.dart';
import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items_dao.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

/// Fake platform routing both persisted folders to a test-owned
/// directory, so the persisted configurations run against the real file
/// system without a host platform channel.
final class _FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProviderPlatform({required this.rootPath});

  final String rootPath;

  @override
  Future<String?> getApplicationSupportPath() async => rootPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => rootPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(SinceWhenDocumentsConfiguration, () {
    test('carries the file name', () {
      const configuration = SinceWhenDocumentsConfiguration(
        fileName: 'documents.sqlite',
      );

      expect(configuration, isA<SinceWhenConfiguration>());
      expect(configuration.fileName, 'documents.sqlite');
    });
  });

  group(SinceWhenAppFolderConfiguration, () {
    test('carries the file name', () {
      const configuration = SinceWhenAppFolderConfiguration(
        fileName: 'app.sqlite',
      );

      expect(configuration, isA<SinceWhenConfiguration>());
      expect(configuration.fileName, 'app.sqlite');
    });
  });

  group(SinceWhenInMemoryConfiguration, () {
    test('constructs as a configuration', () {
      const configuration = SinceWhenInMemoryConfiguration();

      expect(configuration, isA<SinceWhenConfiguration>());
    });
  });

  group(SinceWhenStartup, () {
    late GetIt getIt;
    late DependencyContainer container;
    late Directory tempDirectory;

    setUp(() {
      getIt = GetIt.asNewInstance();
      container = GetItDependencyResolver(getIt: getIt);
      tempDirectory = Directory.systemTemp.createTempSync(
        'sincewhen_startup_test',
      );
      PathProviderPlatform.instance = _FakePathProviderPlatform(
        rootPath: tempDirectory.path,
      );
    });

    tearDown(() async {
      if (container.isRegistered<SinceWhenDatabase>()) {
        await container.get<SinceWhenDatabase>().close();
      }
      await getIt.reset();
      tempDirectory.deleteSync(recursive: true);
    });

    /// Asserts every registration the subsystem promises.
    void expectFullRegistration() {
      expect(container.isRegistered<SinceWhenDatabase>(), isTrue);
      expect(container.isRegistered<GlossaryItemsDao>(), isTrue);
      expect(container.isRegistered<SinceWhenItemsDao>(), isTrue);
      expect(container.isRegistered<TagItemsDao>(), isTrue);
      expect(container.isRegistered<GlossaryRepository>(), isTrue);
      expect(container.isRegistered<SinceWhenRepository>(), isTrue);
      expect(container.isRegistered<TagRepository>(), isTrue);
    }

    test('start with the in-memory configuration registers and warms',
        () async {
      await SinceWhenStartup.start(
        container,
        const SinceWhenInMemoryConfiguration(),
      );

      expectFullRegistration();
      expect(await container.get<GlossaryItemsDao>().itemCount(), 0);
    });

    test('start with the documents configuration registers and warms',
        () async {
      const fileName = 'startup_documents.sqlite';

      await SinceWhenStartup.start(
        container,
        const SinceWhenDocumentsConfiguration(fileName: fileName),
      );

      expectFullRegistration();
      expect(File(p.join(tempDirectory.path, fileName)).existsSync(), isTrue);
    });

    test('start with the app-folder configuration registers and warms',
        () async {
      const fileName = 'startup_app.sqlite';

      await SinceWhenStartup.start(
        container,
        const SinceWhenAppFolderConfiguration(fileName: fileName),
      );

      expectFullRegistration();
      expect(File(p.join(tempDirectory.path, fileName)).existsSync(), isTrue);
    });

    test('warm forces the stack open on an already-registered container',
        () async {
      await SinceWhenStartup.start(
        container,
        const SinceWhenInMemoryConfiguration(),
      );

      await expectLater(SinceWhenStartup.warm(container), completes);
    });
  });
}
