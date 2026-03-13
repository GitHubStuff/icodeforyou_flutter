// lib/src/runner/_app_widget.dart

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_view.dart';
import 'package:application_setup/src/app/landing_page.dart';
import 'package:application_setup/src/app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_manager/theme_manager.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({
    required this.themeCubit,
    required this.appCubit,
    required this.splashChild,
    required this.landingChild,
    required this.transitionDuration,
    required this.splashDuration,
    required this.lightTheme,
    required this.darkTheme,
    this.transitionsBuilder = AppView.crossFade,
    super.key,
  });

  final ThemeCubit themeCubit;
  final AppCubit appCubit;
  final Widget splashChild;
  final Widget landingChild;
  final Duration transitionDuration;
  final Duration splashDuration;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final RouteTransitionsBuilder transitionsBuilder;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeCubit),
        BlocProvider.value(value: appCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, themeMode) {
          return MaterialApp(
            themeMode: themeMode,
            theme: lightTheme,
            darkTheme: darkTheme,
            home: AppView(
              transitionDuration: transitionDuration,
              transitionsBuilder: transitionsBuilder,
              splashScreen: SplashScreen(child: splashChild),
              landingPage: LandingPage(child: landingChild),
            ),
          );
        },
      ),
    );
  }
}
