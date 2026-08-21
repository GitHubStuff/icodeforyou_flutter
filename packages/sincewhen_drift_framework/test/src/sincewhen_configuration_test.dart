// packages/sincewhen_drift_framework/test/src/sincewhen_configuration_test.dart

import 'package:sincewhen_drift_framework/sincewhen_drift_framework.dart';
import 'package:test/test.dart';

void main() {
  group(SinceWhenConfiguration, () {
    // Every construction below goes through a `.new` tear-off bound to a
    // local first, then invoked. A direct `SinceWhenInMemoryConfiguration()`
    // would be const-canonicalized (or lint-pushed toward const), and const
    // construction happens at compile time — zero LCOV hits on the
    // constructor lines. Invoking a bound tear-off is guaranteed runtime
    // execution, which also hits the sealed base class's const constructor
    // via the implicit super call. Binding to a local (rather than invoking
    // `.new(...)` inline) keeps `unnecessary_constructor_name` quiet.
    const documents = SinceWhenDocumentsConfiguration.new;
    const appFolder = SinceWhenAppFolderConfiguration.new;
    const inMemory = SinceWhenInMemoryConfiguration.new;

    group(SinceWhenDocumentsConfiguration, () {
      test('constructs at runtime and stores the file name', () {
        final configuration = documents(fileName: 'since_when.db');

        expect(configuration, isA<SinceWhenConfiguration>());
        expect(configuration.fileName, 'since_when.db');
      });
    });

    group(SinceWhenAppFolderConfiguration, () {
      test('constructs at runtime and stores the file name', () {
        final configuration = appFolder(fileName: 'since_when.db');

        expect(configuration, isA<SinceWhenConfiguration>());
        expect(configuration.fileName, 'since_when.db');
      });
    });

    group(SinceWhenInMemoryConfiguration, () {
      test('constructs at runtime', () {
        final configuration = inMemory();

        expect(configuration, isA<SinceWhenConfiguration>());
      });
    });

    test('sealed hierarchy switches exhaustively over all variants', () {
      final variants = <SinceWhenConfiguration>[
        documents(fileName: 'a.db'),
        appFolder(fileName: 'b.db'),
        inMemory(),
      ];

      final labels = variants
          .map(
            (configuration) => switch (configuration) {
              SinceWhenDocumentsConfiguration() => 'documents',
              SinceWhenAppFolderConfiguration() => 'appFolder',
              SinceWhenInMemoryConfiguration() => 'inMemory',
            },
          )
          .toList();

      expect(labels, ['documents', 'appFolder', 'inMemory']);
    });
  });
}
