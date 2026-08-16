// packages/splash_framework/lib/src/splash_cubit.dart

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_state.dart';

/// A cubit that manages the lifecycle of the splash initialization process.
///
/// [SplashCubit] coordinates two parallel flows:
/// - A required minimum splash [duration].
/// - A set of asynchronous startup [tasks].
///
/// The cubit ensures the splash screen remains visible for at least [duration].
/// If tasks take longer than the duration, the cubit emits [SplashWaiting] so
/// the UI can show a loading indicator. When all tasks finish, it emits
/// [SplashComplete]. If any task throws, it emits [SplashError].
///
/// This cubit is typically used by [SplashScreen] to drive its visual state.
final class SplashCubit extends Cubit<SplashState> {
  /// Creates a new [SplashCubit] with a required minimum [duration] and a list
  /// of asynchronous [tasks] to execute.
  ///
  /// The cubit begins in the [SplashRunning] state. Call [start] to begin
  /// executing tasks and managing the splash lifecycle.
  SplashCubit({required this.duration, required this.tasks})
    : super(const SplashRunning());

  /// The minimum amount of time the splash screen must remain visible.
  final Duration duration;

  /// A list of asynchronous startup tasks that must complete before the splash
  /// process can finish.
  ///
  /// Each task is a function returning a `Future<void>`. All tasks are executed
  /// concurrently using `Future.wait`.
  final List<Future<void> Function()> tasks;

  /// Starts the splash process by executing all tasks and enforcing the
  /// minimum [duration].
  ///
  /// Flow:
  /// - All [tasks] begin executing concurrently, invoked exactly once.
  /// - The cubit waits for [duration] to elapse.
  /// - If tasks are still running after the duration, [SplashWaiting] is
  ///   emitted.
  /// - When all tasks complete, [SplashComplete] is emitted.
  /// - If any task throws, [SplashError] is emitted with the error and its
  ///   stack trace. In debug builds the error is then rethrown so programmer
  ///   errors crash loudly at the throw site instead of only rendering as a
  ///   crash screen.
  ///
  /// This method should be called once, typically immediately after cubit
  /// creation.
  Future<void> start() async {
    try {
      var tasksComplete = false;

      final futures = tasks.map((task) => task()).toList();

      final tasksFuture = Future.wait(futures).then((_) {
        tasksComplete = true;
      });

      await Future<void>.delayed(duration);

      if (!tasksComplete && !isClosed) {
        emit(const SplashWaiting());
      }

      await tasksFuture;

      if (!isClosed) {
        emit(const SplashComplete());
      }
    } on Object catch (error, stackTrace) {
      if (!isClosed) {
        emit(SplashError(error, stackTrace));
      }
      if (kDebugMode) {
        rethrow;
      }
    }
  }
}
