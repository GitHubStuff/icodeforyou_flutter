// widgetbook_workspace/lib/splash_widget/splash_flow.usecase.dart
// ignore_for_file: comment_references, public_member_api_docs

import 'dart:async';

import 'package:animated_widgets/animated_widgets.dart'
    show SplashConfig, SplashCubit, SplashFlow;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// Scenarios
//
// SplashFlow is driven by SplashConfig (via SplashCubit) and gated by the
// background `tasks` it is given. Each scenario is realized by the timing
// relationship between the splash duration, the timeout duration, and the
// tasks. Every SplashConfig property is exposed as a knob; the per-scenario
// default knob values plus the supplied tasks produce the named outcome.
// ---------------------------------------------------------------------------

/// Splash duration elapses *before* the tasks finish, so the indeterminate
/// spinner is shown while they continue, then the landing page appears.
///
/// Defaults: splash 1000ms, tasks complete at 3000ms, timeout 10000ms.
@widgetbook.UseCase(
  name: 'Splash ends before tasks (spinner shown)',
  type: SplashFlow,
)
Widget buildSplashFlowSpinnerShownUseCase(BuildContext context) {
  final config = _splashConfigKnobs(context, splashMs: 1000, timeoutMs: 10000);
  return _Scenario(
    key: _flowKey(config),
    config: config,
    taskFactory: () => <Future<void>>[
      Future<void>.delayed(const Duration(seconds: 3)),
    ],
  );
}

/// Tasks finish *before* the splash duration elapses, so the flow goes
/// straight from splash to landing and the spinner is never shown.
///
/// Defaults: tasks complete at 800ms, splash 3000ms, timeout 10000ms.
@widgetbook.UseCase(
  name: 'Splash ends after tasks (no spinner)',
  type: SplashFlow,
)
Widget buildSplashFlowNoSpinnerUseCase(BuildContext context) {
  final config = _splashConfigKnobs(context, splashMs: 3000, timeoutMs: 10000);
  return _Scenario(
    key: _flowKey(config),
    config: config,
    taskFactory: () => <Future<void>>[
      Future<void>.delayed(const Duration(milliseconds: 800)),
    ],
  );
}

/// The tasks never finish, so the indeterminate phase exceeds the timeout
/// and the timeout widget (driven by the `timeout text` knob) is shown.
///
/// Defaults: splash 1000ms, timeout 2000ms (fires at 3000ms), tasks pending.
@widgetbook.UseCase(name: 'Tasks time out', type: SplashFlow)
Widget buildSplashFlowTimeoutUseCase(BuildContext context) {
  final config = _splashConfigKnobs(context, splashMs: 1000, timeoutMs: 2000);
  return _Scenario(
    key: _flowKey(config),
    config: config,
    taskFactory: () => <Future<void>>[Completer<void>().future],
  );
}

/// A task throws, so the flow short-circuits to the failure widget (driven
/// by the `background task failed text` knob) regardless of the splash phase.
///
/// Defaults: splash 2000ms, task throws at 1000ms, timeout 10000ms.
@widgetbook.UseCase(name: 'Task error', type: SplashFlow)
Widget buildSplashFlowTaskErrorUseCase(BuildContext context) {
  final config = _splashConfigKnobs(context, splashMs: 2000, timeoutMs: 10000);
  return _Scenario(
    key: _flowKey(config),
    config: config,
    taskFactory: () => <Future<void>>[
      Future<void>.delayed(
        const Duration(seconds: 1),
        () => throw Exception('Background task failed'),
      ),
    ],
  );
}

/// Builds a [SplashConfig] from knobs for every one of its properties.
///
/// [splashMs] and [timeoutMs] are the per-scenario default values; the user
/// can still retune them, which changes which path the flow takes.
SplashConfig _splashConfigKnobs(
  BuildContext context, {
  required int splashMs,
  required int timeoutMs,
}) {
  return SplashConfig(
    splashDuration: _msKnob(
      context,
      label: 'splash duration (ms)',
      min: 250,
      max: 5000,
      divisions: 95,
      initialMs: splashMs,
    ),
    timeoutDuration: _msKnob(
      context,
      label: 'timeout duration (ms)',
      min: 500,
      max: 10000,
      divisions: 95,
      initialMs: timeoutMs,
    ),
    crossfadeDuration: _msKnob(
      context,
      label: 'crossfade duration (ms)',
      min: 0,
      max: 1000,
      divisions: 100,
      initialMs: 300,
    ),
    timeoutText: context.knobs.string(
      label: 'timeout text',
      initialValue: 'Time Out',
    ),
    backgroundTaskFailedText: context.knobs.string(
      label: 'background task failed text',
      initialValue: 'Background task failed',
    ),
  );
}

/// Millisecond-valued [Duration] slider knob.
Duration _msKnob(
  BuildContext context, {
  required String label,
  required int min,
  required int max,
  required int divisions,
  required int initialMs,
}) => Duration(
  milliseconds: context.knobs.int.slider(
    label: label,
    min: min,
    max: max,
    divisions: divisions,
    initialValue: initialMs,
  ),
);

/// Key derived from the config so any knob change recreates [_Scenario],
/// rebuilding the cubit with the new config and restarting the flow with a
/// fresh set of tasks.
Key _flowKey(SplashConfig config) => ValueKey<int>(
  Object.hash(
    config.splashDuration,
    config.timeoutDuration,
    config.crossfadeDuration,
    config.timeoutText,
    config.backgroundTaskFailedText,
  ),
);

/// Hosts one [SplashFlow] run.
///
/// Provides the required [SplashCubit] above [SplashFlow] and builds the
/// background tasks exactly once (in [initState]) so that ordinary rebuilds
/// never spawn stray futures — a new run only happens when this widget is
/// recreated via a changed [Key].
class _Scenario extends StatefulWidget {
  const _Scenario({
    required this.config,
    required this.taskFactory,
    super.key,
  });

  final SplashConfig config;
  final List<Future<void>> Function() taskFactory;

  @override
  State<_Scenario> createState() => _ScenarioState();
}

class _ScenarioState extends State<_Scenario> {
  late final List<Future<void>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = widget.taskFactory();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>(
      create: (_) => SplashCubit(splashConfig: widget.config),
      child: SplashFlow(
        splashWidget: const _SplashArt(),
        intermediateWidget: const _SpinnerPhase(),
        landingPage: const _LandingPage(),
        tasks: _tasks,
      ),
    );
  }
}

/// Initial splash artwork. Themed via [ColorScheme] for light/dark.
class _SplashArt extends StatelessWidget {
  const _SplashArt();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.flutter_dash, size: 96, color: scheme.primary),
        const SizedBox(height: 16),
        Text(
          'My App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Indeterminate phase: a labelled spinner.
class _SpinnerPhase extends StatelessWidget {
  const _SpinnerPhase();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const CircularProgressIndicator.adaptive(),
        const SizedBox(height: 16),
        Text('Loading…', style: TextStyle(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

/// Terminal landing page, rendered full-screen.
class _LandingPage extends StatelessWidget {
  const _LandingPage();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.check_circle, size: 72, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
