// programs/{{name.snakeCase()}}/lib/go_routes/routes.goroute.dart
part of 'routes_framework.dart';

//+ COLLECTION OF STARTER/DEFAULT ROUTES +//

/// The route to the app after the splash completes. The
/// [NavigationCubit] is provided here — above [NavigationChooser] and
/// therefore above both navigation screens — so selection and rail
/// visibility survive the dock↔rail swaps that rotation and window
/// resizing trigger. The cubit is seeded with the dock's initial
/// destination name; both enums name their shared members
/// identically, so either enum's `initial` seeds correctly.
GoRoute _appRoute() => GoRoute(
  path: RoutesFramework.app,
  pageBuilder: (context, state) => CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 1300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
          child: child,
        ),
    child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // white status icons
      child: BlocProvider<NavigationCubit>(
        create: (_) => NavigationCubit(
          initialDestinationName: DockDestinationEnum.initial.name,
        ),
        child: const NavigationChooser(),
      ),
    ),
  ),
);

/// GoRoute entry for the terminal crash screen.
GoRoute _crashRoute() => GoRoute(
  path: RoutesFramework.crash,
  builder: (context, state) {
    final args = state.extra as CrashScreenArgs?;

    return CrashScreen(
      error: args?.error ?? 'Unknown error',
      stackTrace: args?.stackTrace,
      resumePath: args?.resumePath,
      onReport: null,
    );
  },
);

/// Splash screens are [no] fun. They display, then transfer to the /app route
/// on success, or to the terminal /crash route with full failure context on
/// error.
GoRoute _splashRoute({required List<Future<void> Function()> tasks}) => GoRoute(
  path: RoutesFramework.splash,
  builder: (context, state) {
    return SplashScreen(
      duration: const Duration(milliseconds: 2500),
      tasks: tasks,
      onComplete: () {
        context.go(RoutesFramework.app);
        unawaited(StatusBarChameleon.setStatusBarHidden(hidden: false));
      },
      onError: (error, stackTrace) {
        context.go(
          RoutesFramework.crash,
          extra: CrashScreenArgs(error: error, stackTrace: stackTrace),
        );
        unawaited(StatusBarChameleon.setStatusBarHidden(hidden: false));
      },
      child: const AnimatedSplashScreen(),
    );
  },
);
