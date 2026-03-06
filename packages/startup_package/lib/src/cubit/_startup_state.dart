// lib/src/cubit/_startup_state.dart

// ignore_for_file: document_ignores, public_member_api_docs

part of 'startup_cubit.dart';

sealed class StartupState {
  const StartupState();
}

final class StartupInitial extends StartupState {
  const StartupInitial();
}

final class StartupRunningTasks extends StartupState {
  const StartupRunningTasks();
}

final class StartupShowLoading extends StartupState {
  const StartupShowLoading();
}

final class StartupComplete extends StartupState {
  const StartupComplete();
}

final class StartupError extends StartupState {
  const StartupError(this.exception);

  final Object exception;
}
