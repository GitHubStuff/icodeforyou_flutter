// loading_error_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:splash_screen_package/src/loading_error.dart';

void main() {
  group('LoadingError', () {
    test('two instances with same message and details are equal', () {
      const error1 = LoadingError('Test error', {'key': 'value'});
      const error2 = LoadingError('Test error', {'key': 'value'});

      expect(error1, equals(error2));
    });

    test('two instances with different messages are not equal', () {
      const error1 = LoadingError('Error 1');
      const error2 = LoadingError('Error 2');

      expect(error1, isNot(equals(error2)));
    });

    test('two instances with same message but different details are not equal', () {
      const error1 = LoadingError('Test error', {'key': 'value1'});
      const error2 = LoadingError('Test error', {'key': 'value2'});

      expect(error1, isNot(equals(error2)));
    });

    test('two instances without details are equal', () {
      const error1 = LoadingError('Test error');
      const error2 = LoadingError('Test error');

      expect(error1, equals(error2));
    });

    test('instance with null details is not equal to instance with empty map', () {
      const error1 = LoadingError('Test error');
      const error2 = LoadingError('Test error', {});

      expect(error1, isNot(equals(error2)));
    });

    test('toString includes message and details', () {
      const error = LoadingError('Test error', {'key': 'value'});
      final result = error.toString();

      expect(result, contains('Test error'));
      expect(result, contains('key'));
      expect(result, contains('value'));
    });

    test('toString with null details shows null', () {
      const error = LoadingError('Test error');
      final result = error.toString();

      expect(result, contains('Test error'));
      expect(result, contains('null'));
    });

    test('props includes errorMessage and errorDetails', () {
      const error = LoadingError('Test error', {'key': 'value'});

      expect(error.props, equals(const ['Test error', {'key': 'value'}]));
    });
  });
}
