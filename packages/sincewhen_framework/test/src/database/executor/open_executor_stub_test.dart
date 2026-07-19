// test/src/database/executor/open_executor_stub_test.dart
@TestOn('vm')
library;

// The stub only imports `package:drift/drift.dart`, so unlike the io and web
// siblings it is importable on any platform. Running it on the VM gives it
// LCOV line coverage even though no supported platform ever executes it in
// production.

import 'package:sincewhen_framework/src/database/executor/open_executor_stub.dart';
import 'package:test/test.dart';

void main() {
  group('platformExecutor (stub)', () {
    test('throws UnsupportedError with default arguments', () {
      expect(platformExecutor, throwsUnsupportedError);
    });

    test('throws UnsupportedError regardless of arguments', () {
      expect(
        () => platformExecutor(path: '/any/path.db'),
        throwsUnsupportedError,
      );
      expect(
        () => platformExecutor(inMemory: true),
        throwsUnsupportedError,
      );
    });

    test('error message names the framework', () {
      expect(
        platformExecutor,
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains('SinceWhen'),
          ),
        ),
      );
    });
  });
}
