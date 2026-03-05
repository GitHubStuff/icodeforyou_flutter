// lib/packages/startup_package/startup_package.usecase.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startup_package/startup_package.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// Splash Screen — black background, animation, spinner on loading state
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Splash — tasks finish after animation',
  type: _DemoSplashScreen,
)
Widget buildSplashWithLoadingUseCase(BuildContext context) {
  return _StartupUseCaseWrapper(
    tasks: [() => Future<void>.delayed(const Duration(seconds: 3))],
    child: const _DemoSplashScreen(),
  );
}

@widgetbook.UseCase(
  name: 'Splash — tasks finish before animation',
  type: _DemoSplashScreen,
)
Widget buildSplashTasksFirstUseCase(BuildContext context) {
  return _StartupUseCaseWrapper(
    tasks: [() async {}],
    child: const _DemoSplashScreen(),
  );
}

@widgetbook.UseCase(
  name: 'Splash — task failure',
  type: _DemoSplashScreen,
)
Widget buildSplashErrorUseCase(BuildContext context) {
  return _StartupUseCaseWrapper(
    tasks: [() async => throw Exception('Simulated task failure')],
    child: const _DemoSplashScreen(),
  );
}

// ---------------------------------------------------------------------------
// _DemoSplashScreen — concrete StartupSplashScreen for widgetbook demos
// ---------------------------------------------------------------------------

class _DemoSplashScreen extends StartupSplashScreen {
  const _DemoSplashScreen();

  @override
  State<_DemoSplashScreen> createState() => _DemoSplashScreenState();
}

class _DemoSplashScreenState extends State<_DemoSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward().whenComplete(() => widget.signalAnimationComplete(context));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StartupCubit, StartupState>(
      builder: (context, state) {
        return ColoredBox(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (_, _) => Opacity(
                  opacity: _controller.value,
                  child: const FlutterLogo(size: 120),
                ),
              ),
              if (state is StartupShowLoading)
                const Positioned(
                  bottom: 80,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              if (state is StartupError)
                Positioned(
                  bottom: 80,
                  child: Text(
                    'Error: ${(state).exception}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Positioned(
                top: 48,
                child: _StateLabel(state: state),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _StateLabel — visible state indicator for widgetbook demos
// ---------------------------------------------------------------------------

class _StateLabel extends StatelessWidget {
  const _StateLabel({required this.state});

  final StartupState state;

  @override
  Widget build(BuildContext context) {
    final label = switch (state) {
      StartupInitial() => 'State: Initial',
      StartupRunningTasks() => 'State: Running Tasks',
      StartupShowLoading() => 'State: Show Loading',
      StartupComplete() => 'State: Complete',
      StartupError() => 'State: Error',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _StartupUseCaseWrapper — provides StartupCubit without StartupApp shell
// ---------------------------------------------------------------------------

class _StartupUseCaseWrapper extends StatelessWidget {
  const _StartupUseCaseWrapper({
    required this.tasks,
    required this.child,
  });

  final List<Future<void> Function()> tasks;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StartupCubit(tasks)..runTasks(),
      child: SizedBox.expand(
        child: ColoredBox(
          color: Colors.black,
          child: child,
        ),
      ),
    );
  }
}
