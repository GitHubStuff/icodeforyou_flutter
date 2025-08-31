import 'dart:async' show FutureOr;
import 'dart:io' show FileSystemException;

import 'package:hive_ce_flutter/hive_flutter.dart' show Box;

import '../abstract/nosql_box_abstract.dart' show NoSqlBoxAbstract;

class NoSqlBox<T> extends NoSqlBoxAbstract<T> {
  NoSqlBox(this._box);

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
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  FutureOr<bool> close() async {
    try {
      await _box.close();
      return true;
    } on FileSystemException catch (e) {
      // Treat missing lock file / directory as already-closed success.
      final enoent =
          (e.osError?.errorCode == 2) ||
          (e.osError?.message.contains('No such file or directory') ?? false);
      return enoent ? true : false;
    } catch (_) {
      // Any other Exception/Error -> failure
      return false;
    }
  }
}
