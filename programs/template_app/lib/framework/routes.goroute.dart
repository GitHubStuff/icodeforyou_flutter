// programs/template_app/lib/framework/routes_goroute.dart
part of 'routes_framework.dart';

//+ COLLECTION OF STARTER/DEFAULT ROUTES +//

/// The route to the app after the splash completes {currently a rail-based
/// navigation app}
GoRoute _appRoute() => GoRoute(
  path: RoutesFramework.app,
  builder: (context, state) {
    return Rails(
      selection: .main,
      placement: .bottom,
      transition: .fadeThrough,
      haptics: .light,
      contents: RailDestinationEnum.railContents(),
    );
  },
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
GoRoute _splashRoute() => GoRoute(
  path: RoutesFramework.splash,
  builder: (context, state) {
    return SplashScreen(
      duration: const Duration(milliseconds: 2500),
      tasks: const [],
      onComplete: () {
        context.go(RoutesFramework.app);
        unawaited(StatusBarChameleon.setStatusBarHidden(hidden: false));
      },
      onError: (_) => context.go(RoutesFramework.crash),
      child: const DefaultSplashScreen(),
    );
  },
);
