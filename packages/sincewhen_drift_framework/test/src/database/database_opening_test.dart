// packages/sincewhen_drift_framework/test/src/database/database_opening_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/database/database_opening.dart';

/// Fake platform routing both persisted folders to a test-owned
/// directory, so the persisted opening paths run against the real file
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

  group('SinceWhenDatabaseOpening', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'sincewhen_opening_test',
      );
      PathProviderPlatform.instance = _FakePathProviderPlatform(
        rootPath: tempDirectory.path,
      );
    });

    tearDown(() {
      tempDirectory.deleteSync(recursive: true);
    });

    test('inMemory opens an ephemeral database', () async {
      final database = SinceWhenDatabaseOpening.inMemory();
      addTearDown(database.close);

      final rows = await database.customSelect('SELECT 1 AS one').get();

      expect(rows.single.read<int>('one'), 1);
    });

    test('inAppFolder persists to the application support folder', () async {
      const fileName = 'app_folder.sqlite';
      final database = SinceWhenDatabaseOpening.inAppFolder(
        fileName: fileName,
      );
      addTearDown(database.close);

      // Any statement forces the lazy stack open, which resolves the
      // folder and creates the file.
      await database.customSelect('SELECT 1').get();

      expect(File(p.join(tempDirectory.path, fileName)).existsSync(), isTrue);
    });

    test('inDocumentFolder persists to the documents folder', () async {
      const fileName = 'documents_folder.sqlite';
      final database = SinceWhenDatabaseOpening.inDocumentFolder(
        fileName: fileName,
      );
      addTearDown(database.close);

      await database.customSelect('SELECT 1').get();

      expect(File(p.join(tempDirectory.path, fileName)).existsSync(), isTrue);
    });
  });
}
