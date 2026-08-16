// programs/widgetbook_workspace/lib/packages/custom_widgets/slide_index_stack/slide_index_stack.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:custom_widgets/custom_widgets.dart' show SlideIndexedStack;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const int _kDurationMinMs = 100;
const int _kDurationMaxMs = 2000;
const int _kDurationInitialMs = 750;

/// Named curve options for the curve dropdown.
const List<({String name, Curve curve})> _kCurveOptions = [
  (name: 'easeInOutCubic (default)', curve: Curves.easeInOutCubic),
  (name: 'linear', curve: Curves.linear),
  (name: 'easeOutBack', curve: Curves.easeOutBack),
  (name: 'fastOutSlowIn', curve: Curves.fastOutSlowIn),
  (name: 'elasticOut', curve: Curves.elasticOut),
];

/// Colors and labels for the four demo panels, in index order.
const List<({String label, MaterialColor color})> _kPanels = [
  (label: 'Alpha', color: Colors.deepPurple),
  (label: 'Bravo', color: Colors.teal),
  (label: 'Charlie', color: Colors.orange),
  (label: 'Delta', color: Colors.blueGrey),
];

@widgetbook.UseCase(name: 'Default', type: SlideIndexedStack)
Widget buildSlideIndexedStackUseCase(BuildContext context) {
  final durationMs = context.knobs.int.slider(
    label: 'duration (ms)',
    initialValue: _kDurationInitialMs,
    min: _kDurationMinMs,
    max: _kDurationMaxMs,
  );
  final curveOption = context.knobs.object.dropdown(
    label: 'curve',
    options: _kCurveOptions,
    initialOption: _kCurveOptions.first,
    labelBuilder: (option) => option.name,
  );

  return _SlideIndexedStackUseCaseHarness(
    duration: Duration(milliseconds: durationMs),
    curve: curveOption.curve,
  );
}

/// Index-driving harness for [SlideIndexedStack].
///
/// Owns the selected index and switches it with a [SegmentedButton],
/// mirroring how a rail drives the stack in black_velvet. The stack is
/// deliberately NOT keyed on the knob values: state preservation across
/// index changes is the widget's contract, and the counters inside the
/// panels exist to prove it. Remounting on a knob change would destroy
/// the behavior under test.
final class _SlideIndexedStackUseCaseHarness extends StatefulWidget {
  const _SlideIndexedStackUseCaseHarness({
    required this.duration,
    required this.curve,
  });

  /// Forwarded to [SlideIndexedStack.duration].
  final Duration duration;

  /// Forwarded to [SlideIndexedStack.curve].
  final Curve curve;

  @override
  State<_SlideIndexedStackUseCaseHarness> createState() =>
      _SlideIndexedStackUseCaseHarnessState();
}

class _SlideIndexedStackUseCaseHarnessState
    extends State<_SlideIndexedStackUseCaseHarness> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<int>(
            segments: [
              for (var i = 0; i < _kPanels.length; i++)
                ButtonSegment<int>(
                  value: i,
                  label: Text(_kPanels[i].label),
                ),
            ],
            selected: {_index},
            onSelectionChanged: (selection) =>
                setState(() => _index = selection.single),
          ),
        ),
        Expanded(
          child: SlideIndexedStack(
            index: _index,
            duration: widget.duration,
            curve: widget.curve,
            children: [
              for (final panel in _kPanels)
                _DemoPanel(label: panel.label, color: panel.color),
            ],
          ),
        ),
      ],
    );
  }
}

/// A stateful demo panel whose counter proves the [IndexedStack]
/// contract: bump a panel's counter, slide away and back, and the
/// count is still there because the child never unmounted.
final class _DemoPanel extends StatefulWidget {
  const _DemoPanel({
    required this.label,
    required this.color,
  });

  /// Panel name shown above the counter.
  final String label;

  /// Panel background color.
  final MaterialColor color;

  @override
  State<_DemoPanel> createState() => _DemoPanelState();
}

class _DemoPanelState extends State<_DemoPanel> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.color,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => setState(() => _count++),
              child: Text('Count: $_count'),
            ),
          ],
        ),
      ),
    );
  }
}
