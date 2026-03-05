// lib/src/cubit/startup_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

part '_startup_state.dart';

class StartupCubit extends Cubit<StartupState> {
  StartupCubit(this._tasks) : super(const StartupInitial());

  final List<Future<void> Function()> _tasks;

  bool _animationComplete = false;
  bool _tasksComplete = false;

  Future<void> runTasks() async {
    emit(const StartupRunningTasks());
    try {
      await Future.wait(
        _tasks.map((task) => task()),
        eagerError: true,
      );
      _tasksComplete = true;
      _emitCompletionIfReady();
    } catch (e) {
      emit(StartupError(e));
    }
  }

  void signalAnimationComplete() {
    _animationComplete = true;
    if (!_tasksComplete) {
      emit(const StartupShowLoading());
    } else {
      _emitCompletionIfReady();
    }
  }

  void _emitCompletionIfReady() {
    if (_animationComplete && _tasksComplete) {
      emit(const StartupComplete());
    }
  }
}
