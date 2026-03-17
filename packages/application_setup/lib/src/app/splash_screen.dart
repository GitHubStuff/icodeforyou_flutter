// lib/src/app/splash_screen.dart

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: _showSpinner,
      builder: (context, state) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (state is AppSplashWaiting) const _SpinnerOverlay(),
          ],
        );
      },
    );
  }

  /// Shows the spinner only when the splash is done but tasks are still
  /// running.
  static bool _showSpinner(AppState previous, AppState current) =>
      current is AppSplashVisible ||
      current is AppSplashWaiting ||
      current is AppTasksComplete;
}

class _SpinnerOverlay extends StatelessWidget {
  const _SpinnerOverlay();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black38,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
