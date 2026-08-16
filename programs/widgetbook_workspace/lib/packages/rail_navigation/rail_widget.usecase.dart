// programs/widgetbook_workspace/lib/packages/rail_navigation/rail_widget.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' show showToast;
import 'package:rail_navigation/rail_navigation.dart'
    show MainRailButton, RailButton, RailPlacement, RailWidget, SettingsRailButton;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const int _kSpacingMin = 0;
const int _kSpacingMax = 24;
const int _kSpacingInitial = 8;
const int _kExtentMin = 56;
const int _kExtentMax = 120;
const int _kExtentInitial = 80;

/// Alignment options, with the documented placement-dependent default
/// first (spaceEvenly for bottom, start for sides).
const List<({String name, MainAxisAlignment? alignment})>
    _kAlignmentOptions = [
  (name: 'default (by placement)', alignment: null),
  (name: 'start', alignment: MainAxisAlignment.start),
  (name: 'center', alignment: MainAxisAlignment.center),
  (name: 'end', alignment: MainAxisAlignment.end),
  (name: 'spaceEvenly', alignment: MainAxisAlignment.spaceEvenly),
  (name: 'spaceBetween', alignment: MainAxisAlignment.spaceBetween),
];

/// Background options, with the theme's surfaceContainer default first.
const List<({String name, Color? color})> _kBackgroundOptions = [
  (name: 'default (surfaceContainer)', color: null),
  (name: 'Deep Purple', color: Colors.deepPurple),
  (name: 'Blue Grey', color: Colors.blueGrey),
];

@widgetbook.UseCase(name: 'Default', type: RailWidget)
Widget buildRailWidgetUseCase(BuildContext context) {
  final placement = context.knobs.object.dropdown(
    label: 'placement',
    options: RailPlacement.values,
    initialOption: RailPlacement.bottom,
    labelBuilder: (option) => option.name,
    description: 'Also selects the layout axis and which safe-area '
        'insets the rail consumes — compare viewports with notches.',
  );
  final alignmentOption = context.knobs.object.dropdown(
    label: 'alignment',
    options: _kAlignmentOptions,
    initialOption: _kAlignmentOptions.first,
    labelBuilder: (option) => option.name,
  );
  final spacing = context.knobs.int.slider(
    label: 'spacing',
    initialValue: _kSpacingInitial,
    min: _kSpacingMin,
    max: _kSpacingMax,
    description: 'Only visually significant when alignment packs '
        'children together (e.g. start).',
  );
  final backgroundOption = context.knobs.object.dropdown(
    label: 'backgroundColor',
    options: _kBackgroundOptions,
    initialOption: _kBackgroundOptions.first,
    labelBuilder: (option) => option.name,
  );
  final extent = context.knobs.int.slider(
    label: 'extent',
    initialValue: _kExtentInitial,
    min: _kExtentMin,
    max: _kExtentMax,
  );

  return _RailWidgetUseCaseHarness(
    placement: placement,
    alignment: alignmentOption.alignment,
    spacing: spacing.toDouble(),
    backgroundColor: backgroundOption.color,
    extent: extent.toDouble(),
  );
}

/// Radio-group harness for [RailWidget].
///
/// [RailWidget] is layout only and explicitly does not manage
/// selection, so the harness plays the documented parent role: it
/// tracks the selected index and rebuilds every child with the
/// appropriate `isSelected` and `onPressed` values. The rail is
/// aligned to the screen edge matching its placement over a plain
/// surface, mirroring real usage without pulling in RailShell.
final class _RailWidgetUseCaseHarness extends StatefulWidget {
  const _RailWidgetUseCaseHarness({
    required this.placement,
    required this.alignment,
    required this.spacing,
    required this.backgroundColor,
    required this.extent,
  });

  /// Forwarded to [RailWidget.placement].
  final RailPlacement placement;

  /// Forwarded to [RailWidget.alignment].
  final MainAxisAlignment? alignment;

  /// Forwarded to [RailWidget.spacing].
  final double spacing;

  /// Forwarded to [RailWidget.backgroundColor].
  final Color? backgroundColor;

  /// Forwarded to [RailWidget.extent].
  final double extent;

  @override
  State<_RailWidgetUseCaseHarness> createState() =>
      _RailWidgetUseCaseHarnessState();
}

class _RailWidgetUseCaseHarnessState extends State<_RailWidgetUseCaseHarness> {
  int _selectedIndex = 0;

  void _select(int index) {
    setState(() => _selectedIndex = index);
    showToast('selected index $index');
  }

  Alignment get _screenAlignment => switch (widget.placement) {
    RailPlacement.bottom => Alignment.bottomCenter,
    RailPlacement.left => Alignment.centerLeft,
    RailPlacement.right => Alignment.centerRight,
  };

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Align(
        alignment: _screenAlignment,
        child: RailWidget(
          placement: widget.placement,
          alignment: widget.alignment,
          spacing: widget.spacing,
          backgroundColor: widget.backgroundColor,
          extent: widget.extent,
          children: [
            MainRailButton(
              onPressed: () => _select(0),
              isSelected: _selectedIndex == 0,
            ),
            RailButton(
              onPressed: () => _select(1),
              icon: const Icon(Icons.flight),
              caption: const Text('Flights'),
              isSelected: _selectedIndex == 1,
            ),
            RailButton(
              onPressed: () => _select(2),
              icon: const Icon(Icons.pets),
              caption: const Text('Pets'),
              isSelected: _selectedIndex == 2,
            ),
            SettingsRailButton(
              onPressed: () => _select(3),
              isSelected: _selectedIndex == 3,
            ),
          ],
        ),
      ),
    );
  }
}
