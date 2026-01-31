// test/src/error_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:theme_package/theme_package.dart';

void main() {
  group('ThemeError', () {
    group('initializationFailed', () {
      test('creates instance with message', () {
        const error = ThemeError.initializationFailed('test error message');

        expect(error, isA<ThemeError>());
      });

      test('toString returns formatted message', () {
        const error = ThemeError.initializationFailed('test error message');

        expect(
          error.toString(),
          'ThemeError.initializationFailed: test error message',
        );
      });

      test('can pattern match on initializationFailed', () {
        const ThemeError error =
            ThemeError.initializationFailed('init failed');

        final message = switch (error) {
          final ThemeError e when e.toString().contains('initializationFailed') =>
            'initialization',
          _ => 'other',
        };

        expect(message, 'initialization');
      });
    });

    group('persistenceFailed', () {
      test('creates instance with message', () {
        const error = ThemeError.persistenceFailed('persistence error');

        expect(error, isA<ThemeError>());
      });

      test('toString returns formatted message', () {
        const error = ThemeError.persistenceFailed('persistence error');

        expect(
          error.toString(),
          'ThemeError.persistenceFailed: persistence error',
        );
      });

      test('can pattern match on persistenceFailed', () {
        const ThemeError error =
            ThemeError.persistenceFailed('save failed');

        final message = switch (error) {
          final ThemeError e when e.toString().contains('persistenceFailed') =>
            'persistence',
          _ => 'other',
        };

        expect(message, 'persistence');
      });
    });
  });
}
