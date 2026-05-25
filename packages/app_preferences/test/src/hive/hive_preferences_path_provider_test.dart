// app_preferences/test/src/hive/hive_preferences_path_provider_test.dart

import 'dart:io';

import 'package:app_preferences/app_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HivePreferences init via path_provider', () {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    late Directory documentsDir;
    late Directory supportDir;

    setUp(() async {
      documentsDir = await Directory.systemTemp.createTemp('hive_pp_docs_');
      supportDir = await Directory.systemTemp.createTemp('hive_pp_support_');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            switch (call.method) {
              case 'getApplicationDocumentsDirectory':
                return documentsDir.path;
              case 'getApplicationSupportDirectory':
                return supportDir.path;
            }
            return null;
          });

      await Hive.close();
      HivePreferences.resetForTesting();
    });

    tearDown(() async {
      await Hive.close();
      HivePreferences.resetForTesting();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      if (documentsDir.existsSync()) {
        await documentsDir.delete(recursive: true);
      }
      if (supportDir.existsSync()) {
        await supportDir.delete(recursive: true);
      }
    });

    test(
      'productionDocuments resolves via getApplicationDocumentsDirectory',
      () async {
        await HivePreferences.init(mode: HiveInitMode.productionDocuments);
        final prefs = await HivePreferences.create(boxName: 'docs_box');
        await prefs.setString('k', 'v');

        final hiveDir = Directory('${documentsDir.path}/hive');
        expect(hiveDir.existsSync(), isTrue);
        expect(
          hiveDir.listSync().any((f) => f.path.endsWith('docs_box.hive')),
          isTrue,
        );
      },
    );

    test(
      'productionSupport resolves via getApplicationSupportDirectory',
      () async {
        await HivePreferences.init(mode: HiveInitMode.productionSupport);
        final prefs = await HivePreferences.create(boxName: 'support_box');
        await prefs.setString('k', 'v');

        final hiveDir = Directory('${supportDir.path}/hive');
        expect(hiveDir.existsSync(), isTrue);
        expect(
          hiveDir.listSync().any((f) => f.path.endsWith('support_box.hive')),
          isTrue,
        );
      },
    );
  });
}
