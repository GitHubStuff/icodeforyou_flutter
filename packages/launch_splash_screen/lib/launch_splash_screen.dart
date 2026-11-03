// packages/launch_splash_screen/lib/launch_splash_screen.dart
/// Shows a splash child while launch tasks run, then hands off to the app.
library;

export 'src/cubit/launch_splash_cubit.dart'
    show LaunchSplashCubit, minimumTimeoutMargin;
export 'src/cubit/launch_splash_state.dart'
    show
        LaunchSplashCompleted,
        LaunchSplashFailed,
        LaunchSplashShowing,
        LaunchSplashState,
        LaunchSplashWaiting;
export 'src/launch_splash_screen.dart'
    show LaunchCompletedCallback, LaunchFailureCallback, LaunchSplashScreen;
export 'src/launch_task.dart' show LaunchTask;
