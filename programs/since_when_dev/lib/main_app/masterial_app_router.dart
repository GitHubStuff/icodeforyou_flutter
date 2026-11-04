import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:launch_splash_screen/launch_splash_screen.dart'
    show LaunchSplashScreen;
import 'package:place_holder_widget/place_holder_widget.dart'
    show PlaceholderWidget;
import 'package:since_when_dev/injection/injection.dart' show getIt;
import 'package:splash_framework/splash_framework.dart' show SplashScreen;
import 'package:theme_mode_cubit/theme_mode_cubit.dart' show ThemeModeCubit;

///
class MasterialAppRouter extends StatelessWidget {
  ///
  const MasterialAppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeModeCubit, ThemeMode>(
      bloc: getIt<ThemeModeCubit>(),
      builder: (context, themeMode) => MaterialApp.router(
        title: 'Since When (dev)',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeMode,
        routerConfig: _router,
      ),
    );
  }
}

GoRouter _router = GoRouter(
  initialLocation: SplashScreen.route,
  routes: [
    _splashRoute(tasks: List.empty()),
  ],
);

//// Splash screens are [no] fun. They display, then transfer to the /app route
/// on success, or to the terminal /crash route with full failure context on
/// error.
GoRoute _splashRoute({required List<Future<void> Function()> tasks}) => GoRoute(
  path: SplashScreen.route,
  builder: (context, state) {
    //return Placeholder();
    return LaunchSplashScreen(
      splashDuration: const Duration(milliseconds: 1500),
      timeoutDuration: const Duration(seconds: 2),
      spinner: const CircularProgressIndicator(),
      onCompleted: (context) {
        debugPrint('Completed');
      },
      onFailure: (context, error, stackTrace) {
        debugPrint('Failed: $error');
      },
      child: const PlaceholderWidget(),
    );
  },
);
