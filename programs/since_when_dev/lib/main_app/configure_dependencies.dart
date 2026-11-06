// programs/since_when_dev/lib/main_app/configure_dependencies.dart

import 'package:get_it/get_it.dart' show GetIt;
import 'package:status_bar_visibility/status_bar_visibility.dart'
    show StatusBarVisibility;
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;
import 'package:theme_mode_cubit/theme_mode_cubit.dart'
    show ThemeModeCubit, ThemeModeStorage;

/// The application's service locator.
final GetIt getIt = GetIt.instance;

/// Composition root for `since_when_dev`.
///
/// Every service the app exposes through [GetIt] is registered here and
/// nowhere else. Registration only makes services available; any work a
/// service must do at launch is a startup action and lives with the
/// startup sequence, not here.
///
/// Pass [locator] explicitly in tests (`GetIt.asNewInstance()`) so each
/// test gets an isolated graph.
void configureDependencies({GetIt? locator}) {
  final container = locator ?? getIt;

  _registerStatusBarVisibilityServices(container);
  _registerThemeCubit(container);
}

/// Controls the visibility of the StatusBar
void _registerStatusBarVisibilityServices(GetIt container) {
  container.registerSingleton<StatusBarVisibilityAbstract>(
    StatusBarVisibility(),
  );
}

/// The theme cubit to control or query for the active theme
void _registerThemeCubit(GetIt container) {
  container.registerSingleton<ThemeModeCubit>(
    ThemeModeCubit(storage: ThemeModeStorage(prefs: null)),
  );
}
