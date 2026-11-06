part of 'material_app_router.dart';

/// The post-splash root screen. It fades in over whatever page it
/// replaces, which gives the splash-to-home cross-fade.
final GoRoute _homeRoute = GoRoute(
  path: HomeScreen.route,
  pageBuilder: (_, state) => CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: _crossFadeDuration,
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
    child: MenuBarScreen(),
  ),
);
