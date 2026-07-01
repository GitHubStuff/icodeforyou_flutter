// packages/animated_widgets/lib/src/splash_widget/splash_widget.dart

/// A configurable splash flow: splash artwork, then an optional
/// indeterminate progress phase while host background tasks run, then a
/// landing page, with timeout and task-failure handling.
///
/// Wire it up by providing a [SplashCubit] above a [SplashScreen] via
/// `BlocProvider` and supplying the background tasks that gate the
/// transition to the landing page. Tune timing and copy with [SplashConfig].
library;

export 'src/splash_config.dart' show SplashConfig;
export 'src/splash_cubit.dart' show SplashCubit;
export 'src/splash_screen.dart' show SplashScreen;
export 'src/splash_state.dart'
    show
        BackgroundTaskFailed,
        IndeterminateShowing,
        LandingShowing,
        SplashShowing,
        SplashState,
        TimedOut;
