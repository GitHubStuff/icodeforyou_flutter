// programs/since_when_dev/test/app/since_when_configurations_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:since_when_dev/app/since_when_configurations.dart'
    show SinceWhenDevConfigurations;
import 'package:sincewhen_drift_framework/sincewhen_drift_framework.dart'
    show
        SinceWhenAppFolderConfiguration,
        SinceWhenDocumentsConfiguration,
        SinceWhenInMemoryConfiguration;

void main() {
  group('SinceWhenDevConfigurations', () {
    test('documents configuration is correctly instantiated', () {
      const config = SinceWhenDevConfigurations.documents;

      expect(config, isA<SinceWhenDocumentsConfiguration>());
      expect(config.fileName, 'since_when_dev');
    });

    test('appFolder configuration is correctly instantiated', () {
      const config = SinceWhenDevConfigurations.appFolder;

      expect(config, isA<SinceWhenAppFolderConfiguration>());
      expect(config.fileName, 'since_when_dev');
    });

    test('inMemory configuration is correctly instantiated', () {
      const config = SinceWhenDevConfigurations.inMemory;

      expect(config, isA<SinceWhenInMemoryConfiguration>());
    });
  });
}
