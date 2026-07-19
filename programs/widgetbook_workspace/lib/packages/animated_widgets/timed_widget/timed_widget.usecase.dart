// widgetbook_workspace/lib/animated_widgets/timed_widget.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

/// [TimedWidget] showing a child for a knob-controlled [Duration], then
/// firing `onFinish`.
///
/// `onFinish` is surfaced visually by [_TimedWidgetDemo], which flips to a
/// "finished" panel when the callback fires. The demo is keyed on the knob
/// values so changing `duration` recreates it — restarting the timer and
/// resetting the finished state.
@widgetbook.UseCase(name: 'Default', type: TimedWidget)
Widget buildTimedWidgetUseCase(BuildContext context) {
  final duration = Duration(
    milliseconds: context.knobs.int.slider(
      label: 'duration (ms)',
      min: 250,
      max: 1250,
      divisions: 100,
      initialValue: 1250,
    ),
  );
  final label = context.knobs.string(
    label: 'child label',
    initialValue: 'Timed content',
  );

  return Center(
    child: _TimedWidgetDemo(
      key: ValueKey<int>(Object.hash(duration, label)),
      duration: duration,
      label: label,
    ),
  );
}

/// Hosts a [TimedWidget] and records whether `onFinish` has fired so the
/// callback can be shown in the UI.
class _TimedWidgetDemo extends StatefulWidget {
  const _TimedWidgetDemo({
    required this.duration,
    required this.label,
    super.key,
  });

  final Duration duration;
  final String label;

  @override
  State<_TimedWidgetDemo> createState() => _TimedWidgetDemoState();
}

class _TimedWidgetDemoState extends State<_TimedWidgetDemo> {
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    return TimedWidget(
      duration: widget.duration,
      onFinish: _onFinish,
      child: _Panel(
        finished: _finished,
        label: widget.label,
        duration: widget.duration,
      ),
    );
  }

  void _onFinish() {
    if (mounted) {
      setState(() => _finished = true);
    }
  }
}

/// Visual surface for the demo: a "waiting" panel with a progress bar that
/// fills over [duration], swapped for a "finished" panel once `onFinish`
/// fires. Themed via [ColorScheme] for light/dark.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.finished,
    required this.label,
    required this.duration,
  });

  final bool finished;
  final String label;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background =
        finished ? scheme.primaryContainer : scheme.secondaryContainer;
    final foreground =
        finished ? scheme.onPrimaryContainer : scheme.onSecondaryContainer;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: 220,
        height: 168,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                finished ? Icons.check_circle : Icons.hourglass_bottom,
                size: 40,
                color: foreground,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                finished
                    ? 'onFinish fired'
                    : 'showing for ${duration.inMilliseconds} ms',
                textAlign: TextAlign.center,
                style: TextStyle(color: foreground, fontSize: 12),
              ),
              if (!finished) ...<Widget>[
                const SizedBox(height: 16),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: duration,
                  builder: (context, value, child) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value,
                      color: foreground,
                      backgroundColor: foreground.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
