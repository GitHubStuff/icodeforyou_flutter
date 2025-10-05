// cubit_mock.dart
import 'dart:async';
import 'package:nosql/nosql.dart' show NoSqlDBAbstract, NoSqlBoxAbstract;
import 'package:theme_manager/theme_manager.dart';

class MockNoSqlDB extends NoSqlDBAbstract {
  @override
  FutureOr<void> init({String? dirName}) async {
    // Mock initialization - do nothing
  }

  @override
  FutureOr<bool> deleteFromDevice() async {
    // Mock device deletion - do nothing
    return true;
  }

  @override
  Future<NoSqlBoxAbstract<T>?> openBox<T>(String name) async {
    return MockNoSqlBox<T>();
  }

  @override
  Future<void> close() async {}

  Future<void> deleteBox(String name) async {}

  List<String> get boxNames => ['theme_mgr_pkg_b8f4c2e9d1a7f5b3'];
}

class MockNoSqlBox<T> extends NoSqlBoxAbstract<T> {
  final Map<String, T> _storage = {};

  @override
  FutureOr<T?> get(dynamic key, {T? defaultValue}) {
    return _storage[key] ?? defaultValue;
  }

  @override
  FutureOr<bool> put(dynamic key, T value) async {
    _storage[key] = value;
    return true;
  }

  @override
  FutureOr<void> close() async {}

  Future<void> clear() async {
    _storage.clear();
  }

  Iterable<String> get keys => _storage.keys;

  Iterable<T> get values => _storage.values;

  int get length => _storage.length;

  bool get isEmpty => _storage.isEmpty;

  bool get isNotEmpty => _storage.isNotEmpty;
}

// Factory to create real ThemeCubit for testing
class TestThemeCubitFactory {
  static Future<ThemeCubit<MockNoSqlDB>> create() async {
    final mockDb = MockNoSqlDB();
    return await ThemeCubit.create<MockNoSqlDB>(nosqlDB: mockDb);
  }
}
