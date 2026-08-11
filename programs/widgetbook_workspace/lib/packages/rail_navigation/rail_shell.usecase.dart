// programs/widgetbook_workspace/lib/rail_navigation/rail_shell.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:rail_navigation/rail_navigation.dart'
    show
        MainRailButton,
        RailButton,
        RailPlacement,
        RailShell,
        RailTransition,
        SettingsRailButton;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const int _kDurationMinMs = 0;
const int _kDurationMaxMs = 1500;
const int _kDurationInitialMs = 750;
const int _kExtentMin = 56;
const int _kExtentMax = 120;
const int _kExtentInitial = 80;

/// Labels and colors for the four demo screens, in index order.
const List<({String label, MaterialColor color})> _kScreens = [
  (label: 'Main', color: Colors.deepPurple),
  (label: 'Flights', color: Colors.teal),
  (label: 'Pets', color: Colors.orange),
  (label: 'Settings', color: Colors.blueGrey),
];

@widgetbook.UseCase(name: 'Default', type: RailShell)
Widget buildRailShellUseCase(BuildContext context) {
  final placement = context.knobs.object.dropdown(
    label: 'placement',
    options: RailPlacement.values,
    initialOption: RailPlacement.bottom,
    labelBuilder: (option) => option.name,
    description: 'Also sets the sharedAxis slide axis: horizontal '
        'under a bottom rail, vertical beside a side rail.',
  );
  final transition = context.knobs.object.dropdown(
    label: 'transition',
    options: RailTransition.values,
    initialOption: RailTransition.fadeThrough,
    labelBuilder: (option) => option.name,
  );
  final durationMs = context.knobs.int.slider(
    label: 'transitionDuration (ms)',
    initialValue: _kDurationInitialMs,
    min: _kDurationMinMs,
    max: _kDurationMaxMs,
    description: 'Zero makes every switch instant regardless of '
        'transition.',
  );
  final railExtent = context.knobs.int.slider(
    label: 'railExtent',
    initialValue: _kExtentInitial,
    min: _kExtentMin,
    max: _kExtentMax,
  );

  return _RailShellUseCaseHarness(
    placement: placement,
    transition: transition,
    transitionDuration: Duration(milliseconds: durationMs),
    railExtent: railExtent.toDouble(),
  );
}

/// Selection-owning harness for [RailShell].
///
/// The shell displays and never decides, so the harness plays the
/// documented parent role: it tracks the index and wires every rail
/// button's onPressed back into its own state. The shell is not keyed
/// on knob values — the counter screens prove the keep-alive contract
/// (bump a counter, switch away and back, the count survives), and a
/// remount would destroy exactly that.
final class _RailShellUseCaseHarness extends StatefulWidget {
  const _RailShellUseCaseHarness({
    required this.placement,
    required this.transition,
    required this.transitionDuration,
    required this.railExtent,
  });

  /// Forwarded to [RailShell.placement].
  final RailPlacement placement;

  /// Forwarded to [RailShell.transition].
  final RailTransition transition;

  /// Forwarded to [RailShell.transitionDuration].
  final Duration transitionDuration;

  /// Forwarded to [RailShell.railExtent].
  final double railExtent;

  @override
  State<_RailShellUseCaseHarness> createState() =>
      _RailShellUseCaseHarnessState();
}

class _RailShellUseCaseHarnessState extends State<_RailShellUseCaseHarness> {
  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return RailShell(
      currentIndex: _index,
      placement: widget.placement,
      transition: widget.transition,
      transitionDuration: widget.transitionDuration,
      railExtent: widget.railExtent,
      railChildren: [
        MainRailButton(
          onPressed: () => _select(0),
          isSelected: _index == 0,
        ),
        RailButton(
          onPressed: () => _select(1),
          icon: const Icon(Icons.flight),
          caption: const Text('Flights'),
          isSelected: _index == 1,
        ),
        RailButton(
          onPressed: () => _select(2),
          icon: const Icon(Icons.pets),
          caption: const Text('Pets'),
          isSelected: _index == 2,
        ),
        SettingsRailButton(
          onPressed: () => _select(3),
          isSelected: _index == 3,
        ),
      ],
      screens: [
        for (final screen in _kScreens)
          _CounterScreen(label: screen.label, color: screen.color),
      ],
    );
  }
}

/// A demo screen following the [RailShell] conventions: it owns its
/// whole vertical (its own [Scaffold] and app bar) and holds a counter
/// whose survival across switches proves the state-preserving stack.
final class _CounterScreen extends StatefulWidget {
  const _CounterScreen({
    required this.label,
    required this.color,
  });

  /// Screen name shown in the app bar and body.
  final String label;

  /// Accent color distinguishing this screen during transitions.
  final MaterialColor color;

  @override
  State<_CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<_CounterScreen> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: FilledButton.tonal(
          onPressed: () => setState(() => _count++),
          child: Text('Count: $_count'),
        ),
      ),
    );
  }
}
