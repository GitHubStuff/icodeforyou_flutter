// ignore_for_file: document_ignores, public_member_api_docs

import 'dart:async' show FutureOr;

import 'package:application_startup/newsrc/common.dart' show AsyncTaskRunMode;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase, BlocProvider;
import 'package:get_it/get_it.dart' show GetIt, WaitingTimeOutException;
import 'package:meta/meta.dart';

abstract class StartupTask<T extends BlocBase<Object?>> {
  const StartupTask();

  String get name;

  List<String> get dependencies => const <String>[];

  FutureOr<T> create();

  Duration get timeout;

  AsyncTaskRunMode get startupTaskRunMode;

  @nonVirtual
  bool isFor<S extends Object>() => <T>[] is List<S>;

  Future<void> checkdependencies(List<StartupTask<dynamic>> tasks) async {
    final taskList = tasks.where((task) => dependencies.contains(task.name));
    for (final task in taskList) {
      if (!GetIt.I.isRegistered(instanceName: task.name)) {
        throw StateError('Dependency "${task.name}" is not registered');
      }

      try {
        await GetIt.I.isReady(
          instanceName: task.name,
          timeout: timeout,
        );
      } on WaitingTimeOutException catch (_) {
        throw StateError(
          'Dependency "${task.name}" did not become ready within '
          '${timeout.inMilliseconds} milliseconds.',
        );
      }
    }
  }

  @nonVirtual
  Future<void> run(List<StartupTask<dynamic>> tasks) async {
    if (GetIt.I.isReadySync(instanceName: name)) return;

    switch (startupTaskRunMode) {
      case .async:
        GetIt.I.registerSingletonAsync<T>(
          () async => await create(),
          instanceName: name,
        );
      case .sync || .root:
        GetIt.I.registerSingleton<T>(
          await create(),
          instanceName: name,
        );
        await GetIt.I.isReady<T>();
    }
  }

  @nonVirtual
  BlocProvider<BlocBase<Object?>> blocProvider() {
    if (!GetIt.I.isReadySync(instanceName: name)) {
      throw StateError('Ready state for "$name" was not properly managed');
    }
    return BlocProvider<T>.value(
      value: GetIt.I.get<T>(instanceName: name),
    );
  }
}
