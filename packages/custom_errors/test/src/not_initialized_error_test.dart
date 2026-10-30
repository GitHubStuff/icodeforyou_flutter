// packages/custom_errors/test/src/not_initialized_error_test.dart

import 'package:custom_errors/src/not_initialized_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotInitializedError', () {
    test('can be instantiated with a message', () {
      final error = NotInitializedError('_isHidden');

      expect(error.message, equals('_isHidden'));
      expect(error, isA<Error>());
    });

    test('toString formats correctly with the provided message', () {
      final error = NotInitializedError('_isHidden');

      expect(
        error.toString(),
        equals(
          'NotInitializedError: _isHidden must be initialized '
          'before use.',
        ),
      );
    });
  });
}
