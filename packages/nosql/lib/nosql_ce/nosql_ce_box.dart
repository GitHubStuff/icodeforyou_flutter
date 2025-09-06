// nosql_ce_box.dart
import 'dart:async' show FutureOr;

import 'package:hive_ce_flutter/hive_flutter.dart' show Box;

import '../abstract/nosql_box_abstract.dart' show NoSqlBoxAbstract;

class NoSqlCEBox<T> implements NoSqlBoxAbstract<T> {
  NoSqlCEBox(this._box);

  final Box<T> _box;

  @override
  FutureOr<T?> get(dynamic key, {T? defaultValue}) {
    try {
      return _box.get(key, defaultValue: defaultValue);
    } on Object catch (_) {
      return null;
    }
  }

  @override
  FutureOr<bool> put(dynamic key, T value) async {
    try {
      await _box.put(key, value);
      return true;
    } on Object catch (_) {
      return false;
    }
  }
}
