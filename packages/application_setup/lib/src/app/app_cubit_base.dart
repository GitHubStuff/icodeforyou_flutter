// lib/src/app/app_cubit_base.dart

import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/app/startup_task.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef ComputeTask = Future<void> Function(
  Future<void> Function(StartupTask) fn,
  StartupTask task,
);

abstract class AppCubitBase extends Cubit<AppState> {
  AppCubitBase({
    required List<StartupTask> tasks,
    required Duration splashDuration,
    ComputeTask? computeTask,
  })  : _tasks = tasks,
        _splashDuration = splashDuration,
        _computeTask = computeTask ?? compute,
        super(const AppInitializing());

  final List<StartupTask> _tasks;
  final Duration _splashDuration;
  final ComputeTask _computeTask;

  @protected
  List<StartupTask> get tasks => _tasks;

  @protected
  Duration get splashDuration => _splashDuration;

  @protected
  ComputeTask get computeTask => _computeTask;

  Future<void> initialize();
}
