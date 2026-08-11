// programs/widgetbook_workspace/lib/rail_navigation/rail_button.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' show showToast;
import 'package:rail_navigation/rail_navigation.dart' show RailButton;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const int _kSizeMin = 40;
const int _kSizeMax = 96;
const int _kSizeInitial = 48;

/// The content combinations [RailButton] permits. The constructor
/// asserts at least one of icon/caption, so the knob is a dropdown of
/// the three legal shapes — the invalid empty state is unrepresentable.
enum _ButtonContent { iconAndCaption, iconOnly, captionOnly }

/// Tint options, with the theme's secondaryContainer default first.
const List<({String name, Color? color})> _kTintOptions = [
  (name: 'default (secondaryContainer)', color: null),
  (name: 'Teal', color: Colors.teal),
  (name: 'Amber', color: Colors.amber),
];

@widgetbook.UseCase(name: 'Default', type: RailButton)
Widget buildRailButtonUseCase(BuildContext context) {
  final content = context.knobs.object.dropdown(
    label: 'content',
    options: _ButtonContent.values,
    initialOption: _ButtonContent.iconAndCaption,
    labelBuilder: (option) => option.name,
  );
  final captionText = context.knobs.string(
    label: 'caption text',
    initialValue: 'Flights',
    description: 'Ignored while content is iconOnly.',
  );
  final sizeSide = context.knobs.int.slider(
    label: 'size (square)',
    initialValue: _kSizeInitial,
    min: _kSizeMin,
    max: _kSizeMax,
    description: 'Content that would not fit is scaled down, never '
        'overflowed — drag small with both icon and caption to see it.',
  );
  final isSelected = context.knobs.boolean(label: 'isSelected');
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

  final showIcon = content != _ButtonContent.captionOnly;
  final showCaption = content != _ButtonContent.iconOnly;

  return Center(
    child: RailButton(
      onPressed: () => showToast('onPressed'),
      icon: showIcon ? const Icon(Icons.flight) : null,
      caption: showCaption ? Text(captionText) : null,
      size: Size.square(sizeSide.toDouble()),
      isSelected: isSelected,
      tint: tintOption.color,
      hapticIntensity: haptic,
    ),
  );
}
