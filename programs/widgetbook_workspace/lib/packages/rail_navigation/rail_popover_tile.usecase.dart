// programs/widgetbook_workspace/lib/packages/rail_navigation/rail_popover_tile.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' show showToast;
import 'package:rail_navigation/rail_navigation.dart' show RailPopoverTile;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Tint options, with the theme's secondaryContainer default first.
const List<({String name, Color? color})> _kTintOptions = [
  (name: 'default (secondaryContainer)', color: null),
  (name: 'Teal', color: Colors.teal),
  (name: 'Amber', color: Colors.amber),
];

@widgetbook.UseCase(name: 'Default', type: RailPopoverTile)
Widget buildRailPopoverTileUseCase(BuildContext context) {
  final showIcon = context.knobs.boolean(
    label: 'icon',
    initialValue: true,
  );
  final selectedTile = context.knobs.int.slider(
    label: 'isSelected (tile index)',
    initialValue: 0,
    min: 0,
    max: 2,
    description: 'Which of the three demo tiles is highlighted.',
  );
  final tintOption = context.knobs.object.dropdown(
    label: 'tint',
    options: _kTintOptions,
    initialOption: _kTintOptions.first,
    labelBuilder: (option) => option.name,
  );
  final haptic = context.knobs.object.dropdown(
    label: 'hapticIntensity',
    options: HapticIntensity.values,
    initialOption: HapticIntensity.light,
    labelBuilder: (option) => option.name,
  );

  return _RailPopoverTileUseCaseHarness(
    showIcon: showIcon,
    selectedTile: selectedTile,
    tint: tintOption.color,
    haptic: haptic,
  );
}

/// Nested-Navigator harness for [RailPopoverTile].
///
/// A tile's tap behavior is `Navigator.pop(context, value)` — mounted
/// bare in the workbench it would pop Widgetbook's own route. The
/// harness runs its own [Navigator]: a launcher route pushes a
/// tile route, tapping a tile pops back with its value, and the
/// awaited result is toasted — the exact `showRailPopover` contract,
/// observable instead of destructive. The system back affordance on
/// the tile route exercises the null (cancel) path.
final class _RailPopoverTileUseCaseHarness extends StatelessWidget {
  const _RailPopoverTileUseCaseHarness({
    required this.showIcon,
    required this.selectedTile,
    required this.tint,
    required this.haptic,
  });

  /// Whether the demo tiles carry a leading icon.
  final bool showIcon;

  /// Index of the demo tile rendered with `isSelected: true`.
  final int selectedTile;

  /// Forwarded to [RailPopoverTile.tint].
  final Color? tint;

  /// Forwarded to [RailPopoverTile.hapticIntensity].
  final HapticIntensity haptic;

  Future<void> _pushTiles(BuildContext launcherContext) async {
    final result = await Navigator.of(launcherContext).push<String>(
      MaterialPageRoute<String>(
        builder: (routeContext) => Scaffold(
          appBar: AppBar(title: const Text('Tap a tile')),
          body: Column(
            children: [
              RailPopoverTile<String>(
                value: 'alpha',
                label: const Text('Alpha'),
                icon: showIcon ? const Icon(Icons.looks_one) : null,
                isSelected: selectedTile == 0,
                tint: tint,
                hapticIntensity: haptic,
              ),
              RailPopoverTile<String>(
                value: 'bravo',
                label: const Text('Bravo'),
                icon: showIcon ? const Icon(Icons.looks_two) : null,
                isSelected: selectedTile == 1,
                tint: tint,
                hapticIntensity: haptic,
              ),
              RailPopoverTile<String>(
                value: 'charlie',
                label: const Text('Charlie'),
                icon: showIcon ? const Icon(Icons.looks_3) : null,
                isSelected: selectedTile == 2,
                tint: tint,
                hapticIntensity: haptic,
              ),
            ],
          ),
        ),
      ),
    );
    showToast(result == null ? 'canceled (null)' : "popped with '$result'");
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (routeContext) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => _pushTiles(routeContext),
              child: const Text('Push tile route'),
            ),
          ),
        ),
      ),
    );
  }
}
