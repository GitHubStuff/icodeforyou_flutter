// test/src/since_when_database_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:since_when/since_when.dart';

void main() {
  group('SinceWhenDatabase', () {
    test(
      'openOrCreate returns Left(InvalidDatabaseName) when name is empty',
      () async {
        final result = await SinceWhenDatabase.openOrCreate(dbName: '');

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<InvalidDatabaseName>()),
          (_) => fail('Expected a Left'),
        );
      },
    );
  });
}
