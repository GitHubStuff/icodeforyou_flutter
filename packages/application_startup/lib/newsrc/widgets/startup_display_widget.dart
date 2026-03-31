// application_startup/lib/src/app/startup_display_widget.dart

// ignore_for_file: public_member_api_docs

import 'dart:async' show Timer, unawaited;

import 'package:application_startup/newsrc/common.dart'
    show AsyncTakeManagerState;
import 'package:application_startup/newsrc/task_manager/cubit/resigister_services_cubit.dart'
    show RegisterSericesManagerCubit;
import 'package:application_startup/newsrc/widgets/splash_screen_configuration.dart'
    show SplashScreenConfiguration;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocListener;

/// Displays the splash screen during startup and transitions
/// to [SplashScreenConfiguration.homeScreen] once
/// [AsyncTakeManagerState.done] is emitted
/// and [SplashScreenConfiguration.splashDuration] has elapsed.
class StartupDisplayWidget extends StatefulWidget {
  /// Creates a [StartupDisplayWidget].
  const StartupDisplayWidget({
    required this.configuration,
    super.key,
  });

  final SplashScreenConfiguration configuration;

  @override
  State<StartupDisplayWidget> createState() => _StartupDisplayWidgetState();
}

class _StartupDisplayWidgetState extends State<StartupDisplayWidget> {
  bool _durationElapsed = false;
  bool _cubitDone = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.configuration.splashDuration, _onDurationElapsed);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onDurationElapsed() {
    _durationElapsed = true;
    _attemptTransition();
  }

  void _onCubitDone() {
    _cubitDone = true;
    _attemptTransition();
  }

  void _attemptTransition() {
    if (!_durationElapsed || !_cubitDone) return;
    if (!mounted) return;
    _navigateToHome();
  }

  void _navigateToHome() {
    unawaited(
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder<void>(
          transitionDuration: widget.configuration.transitionDuration,
          pageBuilder: (context, animation, secondaryAnimation) =>
              widget.configuration.homeScreen,
          transitionsBuilder: widget.configuration.transition,
        ),
        (route) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterSericesManagerCubit, AsyncTakeManagerState>(
      listener: (context, state) {
        if (state == AsyncTakeManagerState.done) _onCubitDone();
      },
      child: widget.configuration.splashScreen,
    );
  }
}
