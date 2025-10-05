// nosql_box_abstract.dart
import 'dart:async' show FutureOr;

abstract class NoSqlBoxAbstract<T> {
  FutureOr<void> close();
  FutureOr<void> put(dynamic key, T value);
  FutureOr<T?> get(dynamic key, {T? defaultValue});
}
