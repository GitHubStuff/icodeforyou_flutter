// programs/since_when_dev/test/app/since_when_configurations_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:since_when_dev/drift_database/drift_database_configurations.dart'
    show DriftDatabaseConfigurations;
import 'package:sincewhen_drift_framework/sincewhen_drift_framework.dart'
    show
        SinceWhenAppFolderConfiguration,
        SinceWhenDocumentsConfiguration,
        SinceWhenInMemoryConfiguration;

void main() {
  group('SinceWhenDevConfigurations', () {
    test('documents configuration is correctly instantiated', () {
      const config = DriftDatabaseConfigurations.documents;

      expect(config, isA<SinceWhenDocumentsConfiguration>());
      expect(config.fileName, 'since_when_dev');
    });

    test('appFolder configuration is correctly instantiated', () {
      const config = DriftDatabaseConfigurations.appFolder;

      expect(config, isA<SinceWhenAppFolderConfiguration>());
      expect(config.fileName, 'since_when_dev');
    });

    test('inMemory configuration is correctly instantiated', () {
      const config = DriftDatabaseConfigurations.inMemory;

      expect(config, isA<SinceWhenInMemoryConfiguration>());
    });
  });
}
