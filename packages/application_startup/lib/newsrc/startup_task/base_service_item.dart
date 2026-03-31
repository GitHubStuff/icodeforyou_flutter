// ignore_for_file: public_member_api_docs

import 'dart:async' show FutureOr, unawaited;

import 'package:application_startup/newsrc/common.dart' show AsyncTaskRunMode;
import 'package:application_startup/newsrc/services/base_services_provider.dart'
    show BaseServicesProvider;
import 'package:application_startup/newsrc/task_manager/cubit/resigister_services_cubit.dart'
    show RegisterSericesManagerCubit;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase, BlocProvider;
import 'package:get_it/get_it.dart' show GetIt, WaitingTimeOutException;
import 'package:meta/meta.dart';

abstract class BaseServiceItem<T extends BlocBase<Object?>> {
  BaseServiceItem({
    required this.serviceDispatcher,
    required this.registrar,
  });
  String get name;

  final RegisterSericesManagerCubit serviceDispatcher;

  final BaseServicesProvider registrar;

  List<String> get dependencies => const <String>[];

  FutureOr<T> create();

  Duration get timeout;

  AsyncTaskRunMode get startupTaskRunMode;

  @nonVirtual
  bool isFor<S extends Object>() => <T>[] is List<S>;

  @nonVirtual
  Future<void> checkdependencies(
    List<BaseServiceItem<dynamic>> tasks,
  ) async {
    final taskList = tasks.where((task) => dependencies.contains(task.name));
    for (final task in taskList) {
      if (!registrar.isRegistered(serviceName: task.name)) {
        throw StateError('Dependency "${task.name}" is not registered');
      }

      try {
        await registrar.isReadyAsync(
          instanceName: task.name,
          timeout: task.timeout,
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
  Future<void> run(List<BaseServiceItem<dynamic>> tasks) async {
    if (registrar.isReady(serviceName: name)) {
      serviceDispatcher.notify(.alreadyRegisted, taskName: name);
      return;
    }
    serviceDispatcher.notify(.registering, taskName: name);

    await checkdependencies(tasks);

    registrar.registerSingletonAsync<T>(
      () async => create(),
      serviceName: name,
    );
    unawaited(
      registrar.isReadyAsync(instanceName: name, timeout: timeout).then((
        service,
      ) {
        serviceDispatcher.notify(.ready, taskName: name);
      }),
    );
  }

  @nonVirtual
  BlocProvider<BlocBase<Object?>> blocProvider() {
    if (!registrar.isRegistered(serviceName: name)) {
      throw StateError('Dependency "$name" is not registered. No BlocProvider');
    }
    if (!registrar.isReady(serviceName: name)) {
      throw StateError('Task "$name" is not ready. No BlocProvider');
    }
    return BlocProvider<T>.value(
      value: registrar.get(serviceName: name),
    );
  }
}
