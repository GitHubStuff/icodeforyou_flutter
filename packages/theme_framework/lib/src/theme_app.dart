// packages/theme_framework/lib/src/theme_app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_framework/src/state/theme_cubit.dart' show ThemeCubit;
import 'package:theme_framework/theme_framework.dart' show ThemeStore;

class ThemeApp extends StatelessWidget {
  const ThemeApp({
    required this.themeStore,
    required this.routerConfig,
    super.key,
  });

  final ThemeStore themeStore;
  final RouterConfig<Object> routerConfig;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(themeStore),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            routerConfig: routerConfig,
            themeMode: themeMode,
            theme: ThemeData(brightness: Brightness.light),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
            ),
          );
        },
      ),
    );
  }
}
