// packages/splash_framework/lib/src/splash_screen_args.dart

import 'package:flutter/widgets.dart';

/// {@template splash_screen_args.dart}
/// Arguments used to configure and launch a [SplashScreen].
///
/// This object bundles all parameters required to run the splash flow:
/// - A fixed [duration] the splash screen should remain visible.
/// - A list of asynchronous [tasks] that must complete before the app proceeds.
/// - The visual [child] displayed behind the loading indicator.
/// - A callback [onComplete] fired when all tasks finish successfully.
/// - A callback [onError] fired when any task throws an exception.
/// {@endtemplate}
@immutable
final class SplashScreenArgs {
  /// {@macro splash_screen_args.dart}
  const SplashScreenArgs({
    required this.duration,
    required this.tasks,
    required this.child,
    required this.onComplete,
    required this.onError,
  });

  /// The minimum amount of time the splash screen should remain visible.
  final Duration duration;

  /// A list of asynchronous operations that must complete before the splash
  /// screen finishes. Each function returns a `Future<void>` and is executed
  /// by the [SplashCubit].
  final List<Future<void> Function()> tasks;

  /// The widget displayed underneath the loading indicator and splash overlay.
  final Widget child;

  /// Callback invoked when all tasks complete successfully.
  final VoidCallback onComplete;

  /// Callback invoked when any task throws an error.
  ///
  /// The thrown error is passed as the callback argument.
  final ValueChanged<Object> onError;
}
