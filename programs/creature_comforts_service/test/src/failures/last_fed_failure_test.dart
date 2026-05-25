// packages/creature_comforts_service/test/src/failures/last_fed_failure_test.dart
import '../../../lib/creature_comforts_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LastFedFailure', () {
    group('LastFedUnauthenticated', () {
      test('has the expected message and no cause', () {
        const failure = LastFedUnauthenticated();

        expect(failure.message, 'No authenticated user.');
        expect(failure.cause, isNull);
      });

      test('toString includes the runtime type and message', () {
        const failure = LastFedUnauthenticated();

        expect(failure.toString(), contains('LastFedUnauthenticated'));
        expect(failure.toString(), contains('No authenticated user.'));
      });
    });

    group('LastFedDocumentMissing', () {
      test('has the expected message and no cause', () {
        const failure = LastFedDocumentMissing();

        expect(failure.message, 'shared/last_fed document not found.');
        expect(failure.cause, isNull);
      });
    });

    group('LastFedRemoteFailure', () {
      test('carries the supplied message and cause', () {
        final cause = Exception('boom');
        final failure = LastFedRemoteFailure(
          message: 'remote exploded',
          cause: cause,
        );

        expect(failure.message, 'remote exploded');
        expect(failure.cause, same(cause));
      });
    });

    group('LastFedDecodeFailure', () {
      test('carries the supplied message; cause is optional', () {
        const failure = LastFedDecodeFailure(message: 'bad type');

        expect(failure.message, 'bad type');
        expect(failure.cause, isNull);
      });

      test('carries the supplied cause when provided', () {
        final cause = StateError('nope');
        final failure = LastFedDecodeFailure(
          message: 'bad type',
          cause: cause,
        );

        expect(failure.cause, same(cause));
      });
    });

    test('exhaustive switch covers every subclass without a default', () {
      // If a new subclass of LastFedFailure is added without updating this
      // switch, the analyzer flags non-exhaustiveness and this test fails to
      // compile. That's the contract: the sealed hierarchy is the source of
      // truth for call sites.
      final failures = <LastFedFailure>[
        const LastFedUnauthenticated(),
        const LastFedDocumentMissing(),
        LastFedRemoteFailure(message: 'x', cause: Exception('y')),
        const LastFedDecodeFailure(message: 'z'),
      ];

      final labels = failures.map((f) {
        return switch (f) {
          LastFedUnauthenticated() => 'unauth',
          LastFedDocumentMissing() => 'missing',
          LastFedRemoteFailure() => 'remote',
          LastFedDecodeFailure() => 'decode',
        };
      }).toList();

      expect(labels, <String>['unauth', 'missing', 'remote', 'decode']);
    });
  });
}
