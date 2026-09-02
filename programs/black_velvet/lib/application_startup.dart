// programs/black_velvet/lib/application_startup.dart

import 'package:dependency_resolver/dependency_resolver.dart'
    show DependencyResolver;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show RepositoryProvider;
import 'package:theme_framework/theme_framework.dart'
    show DefaultMaterialAppRouter, ThemeCubit, ThemeStorageAbstract;

import 'go_routes/routes_framework.dart' show RoutesFramework;

/// {@template application_startup.dart}
/// Composes the application's root dependencies and launches the app.
///
/// [ApplicationStartup] owns the wiring that must exist before the first
/// frame: it creates the [ThemeCubit] backed by the injected
/// [themeStorage], builds the [RoutesFramework] navigation graph,
/// installs the [resolver] — when one is provided — above the router so
/// the entire tree can resolve services, and hands the assembled
/// [DefaultMaterialAppRouter] to [runApp].
///
/// The class is immutable; all mutable state lives in the cubits and
/// router it constructs inside [runner].
/// {@endtemplate}
@immutable
final class ApplicationStartup {
  /// {@macro application_startup.dart}
  const ApplicationStartup({
    required this.themeStorage,
    required this.tasks,
    this.resolver,
  });

  /// The device store the theme is read from and written to.
  final ThemeStorageAbstract themeStorage;

  /// The application's service resolver, provided to the widget tree.
  ///
  /// Typed as the read-side [DependencyResolver] deliberately: the tree
  /// resolves services; registration authority stays with `main` and
  /// the startup tasks.
  ///
  /// Optional. When null, no provider is installed and the widget tree
  /// must not `context.read<DependencyResolver>()` — doing so throws a
  /// `ProviderNotFoundException` naming the missing type. Apps that use
  /// no resolved services simply omit it.
  final DependencyResolver? resolver;

  /// Tasks to run "under" the splash screen
  final List<Future<void> Function()> tasks;

  /// Builds the app and hands it to [runApp].
  void runner() {
    // The cubit to manage the store of dark/light themes is created here
    // so it can be at the root of the widget tree so changes ripple from
    // the root.
    final themeCubit = ThemeCubit(themeStorage);

    // The routes for navigation.
    final goRouter = RoutesFramework.builtRoutes(tasks: tasks);

    Widget app = DefaultMaterialAppRouter(
      themeCubit: themeCubit,
      routerConfig: goRouter,
    );

    // Above the router, therefore above the Navigator: every route,
    // dialog, and sheet the app pushes can `context.read` the
    // resolver. Installed only when a resolver was supplied.
    final resolver = this.resolver;
    if (resolver != null) {
      app = RepositoryProvider<DependencyResolver>.value(
        value: resolver,
        child: app,
      );
    }

    runApp(app);
  }
}
