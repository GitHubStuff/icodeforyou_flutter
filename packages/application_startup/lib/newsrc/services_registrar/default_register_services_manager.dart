// packages/application_startup/newsrc/register_services_manager
// ignore_for_file: public_member_api_docs

import 'dart:async' show FutureOr, unawaited;

import 'package:application_startup/newsrc/common.dart';
import 'package:application_startup/newsrc/service_item/base_service_item.dart'
    show BaseServiceItem;
import 'package:extensions/iterable_ext/iterable_ext.dart' show IterableExt;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase, BlocProvider;
import 'package:get_it/get_it.dart' show GetIt;
import 'package:theme_manager/theme_manager.dart' show ThemeCubitBase;

class DefaultRegisterServicesManager extends BaseRegisteredServicesManager {
  DefaultRegisterServicesManager(ListOfServiceItems tasks)
    : _tasksList = ListOfServiceItems.unmodifiable(tasks) {
    if (tasks.isEmpty) return;
    validateTasks(tasks);
  }

  final ListOfServiceItems _tasksList;

  // ── Public ────────────────────────────────────────────────────────────────

  @override
  ListOfBlocProviders getblocProviders({required BlocProviderRequest forType}) {
    final providers = <BlocProvider<BlocBase<Object?>>>[];
    final tasks = getTasksOf(type: forType);

    for (final BaseServiceItem<dynamic> task in tasks) {
      if (GetIt.I.isRegistered()) {
        providers.add(task.blocProvider());
      } else {
        throw StateError('Task "${task.name}" is not registered.');
      }
    }

    return ListOfBlocProviders.unmodifiable(providers);
  }

  @override
  FutureOr<void> registerTasks(ListOfServiceItems tasks) async {
    for (final BaseServiceItem<dynamic> task in tasks) {
      if (!GetIt.I.isRegistered(instanceName: task.name)) {
        switch (task.startupTaskRunMode) {
          case .async:
            unawaited(task.registerUsing(tasks));
          case .sync || .root:
            await task.registerUsing(tasks);
        }
      }
    }
  }

  @override
  ListOfServiceItems getTasksOf({required BlocProviderRequest type}) {
    switch (type) {
      case .all:
        return _tasksList;
      case .async:
        return _subTasks(_tasksList, .async);
      case .root:
        return _subTasks(_tasksList, .root);
      case .sync:
        return _subTasks(_tasksList, .sync);
    }
  }

  @override
  void validateTasks(ListOfServiceItems tasks) {
    _checkUnknownDependency(tasks);
    tasks.checkForCycles(
      idOf: (task) => task.name,
      dependenciesOf: (task) => task.dependencies,
    );
    _checkForThemeCubit(tasks);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _checkUnknownDependency(ListOfServiceItems tasks) {
    final names = _loadTaskNames(tasks);
    for (final task in tasks) {
      for (final String dependency in task.dependencies) {
        if (!names.contains(dependency)) {
          throw ArgumentError(
            'Task "${task.name}" depends on unknown task "$dependency".',
          );
        }
      }
    }
  }

  void _checkForThemeCubit(ListOfServiceItems tasks) {
    for (final BaseServiceItem<dynamic> task in tasks) {
      if (task.isFor<ThemeCubitBase>()) return;
    }
    throw ArgumentError(
      'No StartupTask assignable to ThemeCubitBase was provided.',
    );
  }

  Set<String> _loadTaskNames(ListOfServiceItems tasks) {
    final Set<String> names = {};
    for (final BaseServiceItem<dynamic> task in tasks) {
      if (!names.add(task.name)) {
        throw ArgumentError('Duplicate task name: ${task.name}');
      }
    }
    return names;
  }

  ListOfServiceItems _subTasks(
    ListOfServiceItems tasks,
    AsyncTaskRunMode runType,
  ) => tasks.where((task) => task.startupTaskRunMode == runType).toList();
}
