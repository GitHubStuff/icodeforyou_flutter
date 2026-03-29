// application_startup/lib/src/app/_splash_screen.dart
import 'dart:async';

import 'package:application_startup/application_startup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A full-screen splash widget that dismisses itself after
/// [SplashScreenConfiguration.splashDuration].
///
/// Displays an optional spinner overlay while startup tasks are in progress.
@immutable
class SplashScreen extends StatefulWidget {
  /// Creates a [SplashScreen] driven by the given [config].
  const SplashScreen({required this.config, super.key});

  /// Configuration controlling the splash content, duration, and spinner.
  final SplashScreenConfiguration config;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      widget.config.splashDuration,
      () => context.read<AppCubit>().onSplashDone(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: _rebuildOn,
      builder: (context, state) => Stack(
        fit: StackFit.expand,
        children: [
          widget.config.splashWidget,
          if (state is AppSplashWaiting)
            _SpinnerOverlay(spinner: widget.config.spinnerWidget),
        ],
      ),
    );
  }

  static bool _rebuildOn(AppState previous, AppState current) =>
      current is AppSplashVisible ||
      current is AppSplashWaiting ||
      current is AppTasksComplete;
}

/// Semi-transparent overlay centred on the splash, shown during
/// long-running startup tasks.
class _SpinnerOverlay extends StatelessWidget {
  const _SpinnerOverlay({this.spinner});

  /// Optional custom spinner; falls back to [CircularProgressIndicator].
  final Widget? spinner;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black38,
      child: Center(child: spinner ?? const CircularProgressIndicator()),
    );
  }
}
