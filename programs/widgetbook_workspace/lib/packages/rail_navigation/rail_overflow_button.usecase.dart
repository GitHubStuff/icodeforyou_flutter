// programs/widgetbook_workspace/lib/rail_navigation/rail_overflow_button.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' show showToast;
import 'package:rail_navigation/rail_navigation.dart'
    show RailOverflowButton, RailPlacement, RailPopoverTile;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// The overflow destinations. Ten entries so the popover exceeds its
/// six-visible-tile maximum: the list scrolls, the scrollbar appears,
/// and initialScrollIndex has something to do.
const List<String> _kDestinations = [
  'Archive',
  'Bookmarks',
  'Downloads',
  'Favorites',
  'History',
  'Labels',
  'Notes',
  'Reminders',
  'Tags',
  'Trash',
];

@widgetbook.UseCase(name: 'Default', type: RailOverflowButton)
Widget buildRailOverflowButtonUseCase(BuildContext context) {
  final placement = context.knobs.object.dropdown(
    label: 'anchor edge',
    options: RailPlacement.values,
    initialOption: RailPlacement.bottom,
    labelBuilder: (option) => option.name,
    description: 'Positions the button near that screen edge. The '
        'popover derives its opening direction from anchor geometry — '
        'no placement parameter exists — so moving the anchor is how '
        'the three opening directions are exercised.',
  );
  final initialScrollIndex = context.knobs.int.slider(
    label: 'initialScrollIndex',
    initialValue: 0,
    min: 0,
    max: _kDestinations.length - 1,
    description: 'The tile at this index is also marked selected, so '
        'opening shows its highlight on screen from the first frame — '
        'the documented pairing.',
  );
  final scrollHaptic = context.knobs.object.dropdown(
    label: 'scrollHaptic',
    options: HapticIntensity.values,
    initialOption: HapticIntensity.light,
    labelBuilder: (option) => option.name,
    description: 'Ticks once per tile-height of popover scrolling; '
        'device-only.',
  );
  final haptic = context.knobs.object.dropdown(
    label: 'hapticIntensity',
    options: HapticIntensity.values,
    initialOption: HapticIntensity.light,
    labelBuilder: (option) => option.name,
  );

  final screenAlignment = switch (placement) {
    RailPlacement.bottom => Alignment.bottomCenter,
    RailPlacement.left => Alignment.centerLeft,
    RailPlacement.right => Alignment.centerRight,
  };

  return Align(
    alignment: screenAlignment,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: RailOverflowButton<String>(
        initialScrollIndex: initialScrollIndex,
        hapticIntensity: haptic,
        scrollHaptic: scrollHaptic,
        onSelected: (value) => showToast("onSelected('$value')"),
        onCanceled: () => showToast('onCanceled'),
        popoverChildren: [
          for (var i = 0; i < _kDestinations.length; i++)
            RailPopoverTile<String>(
              value: _kDestinations[i],
              label: Text(_kDestinations[i]),
              icon: const Icon(Icons.folder_outlined),
              isSelected: i == initialScrollIndex,
            ),
        ],
      ),
    ),
  );
}
