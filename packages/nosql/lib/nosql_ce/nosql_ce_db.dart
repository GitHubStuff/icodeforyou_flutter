// nosql_ce_db.dart
// ignore_for_file: avoid_slow_async_io

import 'dart:async' show FutureOr;
import 'dart:io' show Directory;

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart' show Hive, HiveX;
import 'package:nosql/abstract/abstract.dart' show NoSqlDBAbstract;
// ignore: library_prefixes
import 'package:path/path.dart' as P;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

import 'nosql_ce_box.dart' show NoSqlCEBox;

@visibleForTesting
void resetForTesting() => NoSqlCEdb._fullPath = null;

abstract class PlatformChecker {
  bool get isWeb;
}

class DefaultPlatformChecker implements PlatformChecker {
  const DefaultPlatformChecker();

  @override
  bool get isWeb => kIsWeb;
}

class NoSqlCEdb implements NoSqlDBAbstract {
  const NoSqlCEdb([this.platformChecker = const DefaultPlatformChecker()]);

  final PlatformChecker platformChecker;

  static String? _fullPath;

  Future<void> _deleteDirectory() async {
    if (platformChecker.isWeb) return;
    if (_fullPath == null) {
      throw Exception('Full path not initialized. Call initPath() first.');
    }
    final directory = Directory(_fullPath!);
    final exists = await directory.exists();
    if (exists) {
      await directory.delete(recursive: true);
    }
  }

  Future<String> _getFullPath(String dirPath) async {
    if (P.isAbsolute(dirPath)) {
      return dirPath;
    } else {
      // ignore: omit_local_variable_types
      final Directory documentsDir = await getApplicationDocumentsDirectory();
      return P.join(documentsDir.path, dirPath);
    }
  }

  @override
  FutureOr<void> init({String dirName = 'nosqldb'}) async {
    if (platformChecker.isWeb) return await Hive.initFlutter();
    final fullPath = await _getFullPath(dirName);

    _fullPath ??= fullPath;
    if (_fullPath != fullPath) {
      throw Exception('NoSqlHive has already been initialized with $_fullPath');
    }
    Hive.init(_fullPath);
  }

  @override
  FutureOr<bool> deleteFromDevice() async {
    try {
      await Hive.deleteFromDisk();
      if (!platformChecker.isWeb) await _deleteDirectory();
      _fullPath = null;
      return true;
    } on Exception {
      return false;
    }
  }

  @override
  FutureOr<NoSqlCEBox<T>?> openBox<T>(String boxName) async {
    final box = await Hive.openBox<T>(boxName);
    return NoSqlCEBox<T>(box);
  }
}
