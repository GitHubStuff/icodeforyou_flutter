// lib/src/app/splash_screen.dart

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Abstract base for all splash screen widgets used with [ApplicationRunner].
///
/// Subclasses must call [onComplete] when their animation finishes so the
/// app lifecycle can proceed. Failing to call [onComplete] will leave the
/// app on the splash screen indefinitely.
///
/// ```dart
/// class MySplash extends SplashScreenAbstract {
///   const MySplash({required super.onComplete, super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return MyAnimatedWidget(onDone: onComplete);
///   }
/// }
/// ```
abstract class SplashScreenAbstract extends StatelessWidget {
  const SplashScreenAbstract({required this.onComplete, super.key});

  /// Must be called by the subclass when the splash animation completes.
  final VoidCallback onComplete;
}

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
