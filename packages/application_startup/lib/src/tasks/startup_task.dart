// application_startup/lib/src/app/startup_task.dart
import 'dart:async' show FutureOr;

import 'package:flutter_bloc/flutter_bloc.dart';

/// Defines a single unit of work executed during application startup.
///
/// Tasks are resolved in dependency order by thee Application  Runner
/// Each task may optionally expose a [BlocProvider] to be mounted
/// into the widget tree before [run] is called.
abstract class StartupTask<T> {
  // coverage:ignore-line
  // ignore: public_member_api_docs
  const StartupTask();

  /// Unique identifier for this task, used for dependency resolution.
  String get id;

  /// IDs of tasks that must complete before this task runs.
  List<String> get dependencies => [];

  /// An optional [BlocProvider] to mount into the widget tree for this task.
  BlocProvider<BlocBase<Object?>>? get blocProvider => null;

  /// Executes the startup work for this task.
  FutureOr<void> run();
}
