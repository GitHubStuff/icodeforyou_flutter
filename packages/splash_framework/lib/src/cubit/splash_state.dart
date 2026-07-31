// packages/splash_framework/lib/src/splash_state.dart

sealed class SplashState {
  const SplashState();
}

final class SplashRunning extends SplashState {
  const SplashRunning();
}

final class SplashWaiting extends SplashState {
  const SplashWaiting();
}

final class SplashComplete extends SplashState {
  const SplashComplete();
}

final class SplashError extends SplashState {
  const SplashError(this.error);

  final Object error;
}
