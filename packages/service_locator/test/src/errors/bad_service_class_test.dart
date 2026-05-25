// service_locator/test/src/errors/bad_service_class_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:service_locator/service_locator.dart';

void main() {
  group('BadServiceClass', () {
    test('is a StateError', () {
      expect(BadServiceClass('foo'), isA<StateError>());
    });

    test('message identifies the offending service name', () {
      final error = BadServiceClass('foo');
      expect(error.message, contains('"foo"'));
    });

    test('message names the constraint that was violated', () {
      final error = BadServiceClass('foo');
      expect(
        error.message,
        allOf(
          contains('concrete subtype of ServiceClass'),
          contains('too generic'),
        ),
      );
    });
  });
}
