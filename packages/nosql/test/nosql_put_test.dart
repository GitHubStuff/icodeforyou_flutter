// dart_test
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart' show Box;
import 'package:mocktail/mocktail.dart';

class MockBox<T> extends Mock implements Box<T> {}

class Store<T> {
  final Box<T> _box;
  Store(this._box);

  Future<bool> put(dynamic key, T value) async {
    try {
      await _box.put(key, value);
      return true;
    } on Exception {
      return false;
    }
  }
}

void main() {
  test('put returns false when _box.put throws Exception', () async {
    final box = MockBox<String>();
    final sut = Store<String>(box);

    when(() => box.put('k', 'v')).thenThrow(Exception('boom'));

    final result = await sut.put('k', 'v');

    expect(result, isFalse);
    verify(() => box.put('k', 'v')).called(1);
  });
}
