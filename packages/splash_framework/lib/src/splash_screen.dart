// packages/splash_framework/lib/src/splash_screen.dart
import 'package:custom_widgets/custom_widgets.dart' show SolidScreenColor;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splash_framework/src/cubit/splash_cubit.dart' show SplashCubit;
import 'package:splash_framework/src/cubit/splash_state.dart'
    show SplashComplete, SplashError, SplashState, SplashWaiting;

/// {@template SplashScreen.widget}
/// A configurable splash screen that runs asynchronous tasks before revealing
/// the main application content.
///
/// The [SplashScreen] uses a [SplashCubit] to manage its lifecycle:
/// - It displays a background color via [SolidScreenColor].
/// - It shows the provided [child] widget.
/// - While tasks are running, it overlays a [CircularProgressIndicator].
/// - When tasks complete, it triggers [onComplete].
/// - When an error occurs, it triggers [onError].
///
/// This widget is typically placed at the root of an app to perform startup
/// initialization such as loading configuration, preparing services, or
/// validating authentication state.
/// {@endtemplate}
@immutable
final class SplashScreen extends StatelessWidget {
  /// Creates a new [SplashScreen].
  ///
  /// The splash screen will remain visible for at least [duration] and will
  /// execute each function in [tasks]. Completion or failure is reported
  /// through [onComplete] and [onError] respectively.
  const SplashScreen({
    required this.duration,
    required this.tasks,
    required this.onComplete,
    required this.onError,
    required this.child,
    super.key,
  });

  /// The minimum duration the splash screen should remain visible.
  final Duration duration;

  /// A list of asynchronous startup tasks executed by the [SplashCubit].
  final List<Future<void> Function()> tasks;

  /// The widget displayed behind the splash overlay and progress indicator.
  final Widget child;

  /// Callback invoked when all tasks finish successfully.
  final VoidCallback onComplete;

  /// Callback invoked when any task throws an error.
  final ValueChanged<Object> onError;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>(
      // ignore: discarded_futures
      create: (_) => SplashCubit(duration: duration, tasks: tasks)..start(),
      child: BlocConsumer<SplashCubit, SplashState>(
        listener: (context, state) {
          switch (state) {
            case SplashComplete():
              onComplete();

            case SplashError(:final error):
              onError(error);

            default:
              break;
          }
        },
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              const SolidScreenColor(),
              child,
              if (state is SplashWaiting)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }
}
