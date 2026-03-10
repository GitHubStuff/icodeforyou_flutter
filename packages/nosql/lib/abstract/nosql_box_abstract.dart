// nosql_box_abstract.dart
// ignore_for_file: public_member_api_docs

import 'dart:async' show FutureOr;

abstract class NoSqlBoxAbstract<T> {
  FutureOr<void> close();
  FutureOr<bool> put(dynamic key, T value);
  FutureOr<T?> get(dynamic key, {T? defaultValue});
}
