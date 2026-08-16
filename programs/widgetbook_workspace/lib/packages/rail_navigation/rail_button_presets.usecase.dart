// programs/widgetbook_workspace/lib/packages/rail_navigation/rail_button_presets.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' show showToast;
import 'package:rail_navigation/rail_navigation.dart'
    show MainRailButton, MoreRailButton, SettingsRailButton;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Tint options, with the theme's secondaryContainer default first.
const List<({String name, Color? color})> _kTintOptions = [
  (name: 'default (secondaryContainer)', color: null),
  (name: 'Teal', color: Colors.teal),
  (name: 'Amber', color: Colors.amber),
];

/// The knob values shared by all three presets. The presets have
/// byte-identical parameter lists (only the icon and default caption
/// differ), so one reader serves all three builders; [defaultCaption]
/// seeds the caption knob with each preset's documented default.
({
  String? captionText,
  bool isSelected,
  Color? tint,
  HapticIntensity haptic,
}) _readPresetKnobs(BuildContext context, String defaultCaption) {
  final captionText = context.knobs.stringOrNull(
    label: 'caption',
    initialValue: defaultCaption,
    description: 'Null renders the documented icon-only variant.',
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
  return (
    captionText: captionText,
    isSelected: isSelected,
    tint: tintOption.color,
    haptic: haptic,
  );
}

@widgetbook.UseCase(name: 'Default', type: MainRailButton)
Widget buildMainRailButtonUseCase(BuildContext context) {
  final knobs = _readPresetKnobs(context, 'Main');
  return Center(
    child: MainRailButton(
      onPressed: () => showToast('onPressed'),
      caption: knobs.captionText == null ? null : Text(knobs.captionText!),
      isSelected: knobs.isSelected,
      tint: knobs.tint,
      hapticIntensity: knobs.haptic,
    ),
  );
}

@widgetbook.UseCase(name: 'Default', type: MoreRailButton)
Widget buildMoreRailButtonUseCase(BuildContext context) {
  final knobs = _readPresetKnobs(context, 'More');
  return Center(
    child: MoreRailButton(
      onPressed: () => showToast('onPressed'),
      caption: knobs.captionText == null ? null : Text(knobs.captionText!),
      isSelected: knobs.isSelected,
      tint: knobs.tint,
      hapticIntensity: knobs.haptic,
    ),
  );
}

@widgetbook.UseCase(name: 'Default', type: SettingsRailButton)
Widget buildSettingsRailButtonUseCase(BuildContext context) {
  final knobs = _readPresetKnobs(context, 'Settings');
  return Center(
    child: SettingsRailButton(
      onPressed: () => showToast('onPressed'),
      caption: knobs.captionText == null ? null : Text(knobs.captionText!),
      isSelected: knobs.isSelected,
      tint: knobs.tint,
      hapticIntensity: knobs.haptic,
    ),
  );
}
