// lib/src/app/app_view.dart

import 'dart:async' show unawaited;

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/app/landing_page.dart';
import 'package:application_setup/src/app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppView extends StatefulWidget {
  const AppView({
    required this.splashScreen,
    required this.landingPage,
    required this.transitionDuration,
    this.transitionsBuilder = AppView.crossFade,
    super.key,
  });

  final SplashScreen splashScreen;
  final LandingPage landingPage;
  final Duration transitionDuration;
  final RouteTransitionsBuilder transitionsBuilder;

  static Widget crossFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> _,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<AppCubit>().initialize());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listenWhen: (_, current) => current is AppReady,
      listener: _onReady,
      child: widget.splashScreen,
    );
  }

  void _onReady(BuildContext context, AppState state) {
    unawaited(
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: widget.transitionDuration,
          pageBuilder: (_, _, _) => widget.landingPage,
          transitionsBuilder: widget.transitionsBuilder,
        ),
      ),
    );
  }
}
