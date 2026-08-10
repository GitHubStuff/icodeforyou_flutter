// packages/splash_framework/lib/src/splash_screen.dart

import 'package:custom_widgets/custom_widgets.dart' show SolidScreenColor;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/splash_cubit.dart';
import 'cubit/splash_state.dart';

@immutable
final class SplashScreenArgs {
  const SplashScreenArgs({
    required this.duration,
    required this.tasks,
    required this.child,
    required this.onComplete,
    required this.onError,
  });

  final Duration duration;
  final List<Future<void> Function()> tasks;
  final Widget child;
  final VoidCallback onComplete;
  final ValueChanged<Object> onError;
}

@immutable
final class SplashScreen extends StatelessWidget {
  const SplashScreen({
    required this.duration,
    required this.tasks,
    required this.onComplete,
    required this.onError,
    required this.child,
    super.key,
  });

  final Duration duration;
  final List<Future<void> Function()> tasks;
  final Widget child;
  final VoidCallback onComplete;
  final ValueChanged<Object> onError;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>(
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
              SolidScreenColor(),
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
