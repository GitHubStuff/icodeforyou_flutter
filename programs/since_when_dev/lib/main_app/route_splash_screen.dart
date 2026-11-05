part of 'material_app_router.dart';

/// How long the splash stays visible before completing.
const _splashDuration = Duration(milliseconds: 2500);

/// Launch splash. On completion it replaces itself with [HomeScreen] via
/// `context.go`, leaving [HomeScreen] as the sole root of the stack.
/// Failure handling is not yet wired; failures are only logged.
final GoRoute _splashRoute = GoRoute(
  path: SplashScreen.route,
  builder: (_, _) => LaunchSplashScreen(
    splashDuration: _splashDuration,
    timeoutDuration: _splashTimeout,
    spinner: const CircularProgressIndicator(),
    onCompleted: (context) {
      unawaited(showStatusBarAfterSplashScreen());
      context.go(HomeScreen.route);
    },
    onFailure: (context, error, stackTrace) {
      unawaited(showStatusBarAfterSplashScreen());
      debugPrint('Splash failed: $error');
    },
    child: _animations(),
  ),
);

Widget _animations() {
  return const AnimatedTransparency(
    range: TransparencyRange(0.1, 1),
    duration: Duration(milliseconds: 1250),
    child: PlaceholderWidget(),
  );
}

/// If the splash screen completes, or errors out, restore the status bar
Future<void> showStatusBarAfterSplashScreen() async {
  await getIt<StatusBarVisibilityAbstract>().setStatusBarVisibility(
    isHidden: false,
  );
}
