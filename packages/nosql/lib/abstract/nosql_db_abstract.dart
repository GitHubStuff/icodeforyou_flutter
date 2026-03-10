// nosql_db_abtract.dart
// ignore_for_file: public_member_api_docs

import 'dart:async' show FutureOr;

import 'package:nosql/abstract/nosql_box_abstract.dart' show NoSqlBoxAbstract;

abstract class NoSqlDBAbstract {
  FutureOr<void> init({String dirName = 'nosqldb'});
  FutureOr<void> close();
  FutureOr<bool> deleteFromDevice();
  FutureOr<NoSqlBoxAbstract<T>?> openBox<T>(String boxName);
}
