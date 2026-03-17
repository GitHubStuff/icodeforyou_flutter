// lib/src/_startup_tasks.dart

import 'package:application_setup/application_setup.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:since_when/since_when.dart';

class StartupTasks {
  const StartupTasks._();

  static List<StartupTask> get all => [
    _SinceWhenStartupTask(RootIsolateToken.instance!),
  ];
}

class _SinceWhenStartupTask extends StartupTask {
  const _SinceWhenStartupTask(this._token);

  final RootIsolateToken _token;

  @override
  String get id => 'since_when_db';

  @override
  Future<void> run() async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(_token);
    final result = await SinceWhenDatabase.open();
    final db = result.getOrElse((failure) => throw Exception(failure));
    GetIt.instance.registerSingleton<SinceWhenDatabase>(db);
  }
}
