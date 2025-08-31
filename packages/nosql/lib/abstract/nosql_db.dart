import 'dart:async' show FutureOr;

import 'package:nosql/abstract/nosql_box_abstract.dart' show NoSqlBoxAbstract;

abstract class NoSqlDB {
  FutureOr<void> init({String dirName = 'nosqldb'});
  FutureOr<bool> deleteFromDevice();
  FutureOr<NoSqlBoxAbstract<T>?> openBox<T>(String boxName);
}
