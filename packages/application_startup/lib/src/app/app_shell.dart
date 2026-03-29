// application_startup/lib/src/app/_app_shell.dart
import 'package:application_startup/src/tasks/startup_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A [StatefulWidget] that wraps the home screen with any [BlocProvider]s
/// declared by the provided [StartupTask] list.
///
/// Also observes widget binding lifecycle events via [WidgetsBindingObserver]
/// to allow tasks to react to metrics and brightness changes.
class AppShell extends StatefulWidget {
  /// Creates an [AppShell] with the required [homeScreen] and [tasks].
  const AppShell({
    required this.homeScreen,
    required this.tasks,
    super.key,
  });

  /// The root screen displayed after startup completes.
  final Widget homeScreen;

  /// The startup tasks whose [BlocProvider]s will be hoisted
  /// above [homeScreen].
  final List<StartupTask> tasks;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  Widget build(BuildContext context) {
    final providers = widget.tasks
        .map((t) => t.blocProvider)
        .whereType<BlocProvider<BlocBase<Object?>>>()
        .toList();

    if (providers.isEmpty) return widget.homeScreen;

    return MultiBlocProvider(
      providers: providers,
      child: widget.homeScreen,
    );
  }
}
