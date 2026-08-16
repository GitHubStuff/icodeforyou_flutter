// programs/widgetbook_workspace/lib/packages/splash_framework/splash_screen.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' show showToast;
import 'package:splash_framework/splash_framework.dart' show SplashScreen;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const int _kDurationMinMs = 250;
const int _kDurationMaxMs = 5000;
const int _kSplashDurationInitialMs = 1500;
const int _kTaskDurationInitialMs = 3000;

@widgetbook.UseCase(name: 'Default', type: SplashScreen)
Widget buildSplashScreenUseCase(BuildContext context) {
  final splashDurationMs = context.knobs.int.slider(
    label: 'duration (ms)',
    initialValue: _kSplashDurationInitialMs,
    min: _kDurationMinMs,
    max: _kDurationMaxMs,
    description: 'The minimum time the splash stays up.',
  );
  final taskDurationMs = context.knobs.int.slider(
    label: 'simulated task (ms)',
    initialValue: _kTaskDurationInitialMs,
    min: _kDurationMinMs,
    max: _kDurationMaxMs,
    description:
        'The relationship to duration is the demo: a task '
        'shorter than duration never shows the spinner; a longer one '
        'shows it from the moment duration elapses until the task '
        'completes (SplashWaiting).',
  );
  final failTask = context.knobs.boolean(
    label: 'task throws',
    description:
        'The task throws an Exception after its delay, '
        'exercising SplashError and onError.',
  );

  return _SplashScreenUseCaseHarness(
    duration: Duration(milliseconds: splashDurationMs),
    taskDuration: Duration(milliseconds: taskDurationMs),
    failTask: failTask,
  );
}

/// Remount harness for [SplashScreen].
///
/// The screen creates and starts its [SplashCubit] once per mount, so a
/// running flow can never pick up new parameters. Opposite to the
/// state-preserving use cases, the [SplashScreen] here IS keyed on
/// every knob value: any knob change remounts and re-runs the flow with
/// the new configuration, and the Run again button bumps a generation
/// for same-configuration replays.
final class _SplashScreenUseCaseHarness extends StatefulWidget {
  const _SplashScreenUseCaseHarness({
    required this.duration,
    required this.taskDuration,
    required this.failTask,
  });

  /// Forwarded to [SplashScreen.duration].
  final Duration duration;

  /// The simulated startup task's delay.
  final Duration taskDuration;

  /// Whether the simulated task throws after its delay.
  final bool failTask;

  @override
  State<_SplashScreenUseCaseHarness> createState() =>
      _SplashScreenUseCaseHarnessState();
}

class _SplashScreenUseCaseHarnessState
    extends State<_SplashScreenUseCaseHarness> {
  /// Incremented on each Run again press to remount the splash.
  int _generation = 0;

  void _runAgain() => setState(() => _generation++);

  /// The single simulated startup task: waits, then completes or
  /// throws per the knob.
  Future<void> _task() async {
    await Future<void>.delayed(widget.taskDuration);
    if (widget.failTask) {
      throw Exception('simulated task failure');
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = ValueKey(
      '$_generation|${widget.duration.inMilliseconds}'
      '|${widget.taskDuration.inMilliseconds}|${widget.failTask}',
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _runAgain,
            icon: const Icon(Icons.replay),
            label: const Text('Run again'),
          ),
        ),
        Expanded(
          child: SplashScreen(
            key: key,
            duration: widget.duration,
            tasks: [_task],
            onComplete: () => showToast('onComplete'),
            onError: (error, stackTrace) => showToast('onError($error)'),
            child: const Center(
              child: Text(
                'black_velvet',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
