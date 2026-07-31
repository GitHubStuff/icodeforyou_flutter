// packages/splash_framework/lib/src/splash_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_state.dart';

final class SplashCubit extends Cubit<SplashState> {
  SplashCubit({required this.duration, required this.tasks})
    : super(const SplashRunning());

  final Duration duration;
  final List<Future<void> Function()> tasks;

  Future<void> start() async {
    try {
      var tasksComplete = false;

      final tasksFuture = Future.wait(tasks.map((task) => task())).then((_) {
        tasksComplete = true;
      });

      await Future<void>.delayed(duration);

      if (!tasksComplete) {
        emit(const SplashWaiting());
      }

      await tasksFuture;

      emit(const SplashComplete());
    } catch (error) {
      emit(SplashError(error));
    }
  }
}
