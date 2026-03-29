// application_startup/lib/src/runner/_app_widget.dart
import 'dart:async' show unawaited;

import 'package:application_startup/application_startup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:theme_manager/theme_manager.dart';

/// Root application widget that wires together theming, [AppCubit],
/// and the splash-to-home transition.
class AppWidget extends StatefulWidget {
  /// Creates an [AppWidget] with the required cubit, splash config,
  /// home screen, startup tasks, and light/dark themes.
  const AppWidget({
    required this.appCubit,
    required this.splashConfig,
    required this.homeScreen,
    required this.tasks,
    required this.lightTheme,
    required this.darkTheme,
    super.key,
  });

  /// The cubit that drives the startup state machine.
  final AppCubit appCubit;

  /// Configuration for the splash screen and its transition.
  final SplashScreenConfiguration splashConfig;

  /// The widget shown after startup completes.
  final Widget homeScreen;

  /// Ordered list of tasks executed during startup.
  final List<StartupTask> tasks;

  /// The light [ThemeData] supplied to [MaterialApp].
  final ThemeData lightTheme;

  /// The dark [ThemeData] supplied to [MaterialApp].
  final ThemeData darkTheme;

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  // Held as a field so theme-driven rebuilds of MaterialApp never
  // re-create this widget and reset the SplashScreen timer.
  late final _AppEntry _entry = _AppEntry(
    splashConfig: widget.splashConfig,
    homeScreen: widget.homeScreen,
    tasks: widget.tasks,
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: GetIt.instance<ThemeCubitBase>()),
        BlocProvider.value(value: widget.appCubit),
      ],
      child: BlocBuilder<ThemeCubitBase, ThemeMode>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, themeMode) => MaterialApp(
          themeMode: themeMode,
          theme: widget.lightTheme,
          darkTheme: widget.darkTheme,
          home: _entry,
        ),
      ),
    );
  }
}

/// Private entry point that triggers startup tasks and transitions
/// to [AppShell] once [AppReady] is emitted.
class _AppEntry extends StatefulWidget {
  const _AppEntry({
    required this.splashConfig,
    required this.homeScreen,
    required this.tasks,
  });

  final SplashScreenConfiguration splashConfig;
  final Widget homeScreen;
  final List<StartupTask> tasks;

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<AppCubit>().runStartupTasks());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listenWhen: (_, current) => current is AppReady,
      listener: _onReady,
      child: SplashScreen(config: widget.splashConfig),
    );
  }

  /// Replaces the splash screen with [AppShell] using the configured transition
  void _onReady(BuildContext context, AppState state) {
    unawaited(
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: widget.splashConfig.transitionDuration,
          pageBuilder: (_, _, _) =>
              AppShell(homeScreen: widget.homeScreen, tasks: widget.tasks),
          transitionsBuilder: widget.splashConfig.transition,
        ),
      ),
    );
  }
}
