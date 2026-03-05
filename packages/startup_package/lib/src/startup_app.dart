// lib/src/startup_app.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/startup_cubit.dart';
import 'navigation/_startup_router.dart';
import 'startup_config.dart';

class StartupApp extends StatelessWidget {
  const StartupApp({required this.config, super.key});

  final StartupConfig config;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StartupCubit(config.tasks)..runTasks(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _StartupShell(config: config),
        builder: (context, child) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          return child!;
        },
      ),
    );
  }
}

class _StartupShell extends StatelessWidget {
  const _StartupShell({required this.config});

  final StartupConfig config;

  @override
  Widget build(BuildContext context) {
    return BlocListener<StartupCubit, StartupState>(
      listener: _onStateChange,
      child: ColoredBox(
        color: Colors.black,
        child: config.splashScreen,
      ),
    );
  }

  void _onStateChange(BuildContext context, StartupState state) {
    switch (state) {
      case StartupComplete():
        StartupRouter.navigateToLanding(context, config.landingPage);
      case StartupError():
        _handleError(context, state.exception);
      case StartupInitial():
      case StartupRunningTasks():
      case StartupShowLoading():
        break;
    }
  }

  void _handleError(BuildContext context, Object exception) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Startup Failed'),
        content: Text(exception.toString()),
      ),
    );
  }
}
