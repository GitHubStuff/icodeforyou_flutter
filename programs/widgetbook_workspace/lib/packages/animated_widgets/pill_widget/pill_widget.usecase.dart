// programs/widgetbook_workspace/lib/sincewhen_widgets/glossary/pill_widget.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:animated_widgets/animated_widgets.dart' show PillWidget;
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' show showToast;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Named color options for the background dropdown. Records pair a display
/// name with the color so the knob's labelBuilder needs no lookup table.
const List<({String name, Color color})> _kColorOptions = [
  (name: 'Teal', color: Colors.teal),
  (name: 'Deep Purple', color: Colors.deepPurple),
  (name: 'Amber', color: Colors.amber),
  (name: 'Red', color: Colors.red),
  (name: 'Light Green', color: Colors.lightGreen),
  (name: 'Blue Grey', color: Colors.blueGrey),
  (name: 'Black', color: Colors.black),
  (name: 'White', color: Colors.white),
];

/// The three named-constructor size variants of [PillWidget].
enum _PillSize {
  /// [PillWidget.small] — phones, font size 14.
  small,

  /// [PillWidget.medium] — tablets, font size 16.
  medium,

  /// [PillWidget.large] — desktop and web, font size 18.
  large,
}

@widgetbook.UseCase(name: 'Default', type: PillWidget)
Widget buildPillWidgetUseCase(BuildContext context) {
  final label = context.knobs.string(
    label: 'label',
    initialValue: 'Flutter',
    description: 'Clear the field to see the disabled placeholder state.',
  );
  final colorOption = context.knobs.object.dropdown(
    label: 'color',
    options: _kColorOptions,
    initialOption: _kColorOptions.first,
    labelBuilder: (option) => option.name,
  );
  final size = context.knobs.object.dropdown(
    label: 'size',
    options: _PillSize.values,
    initialOption: _PillSize.small,
    labelBuilder: (option) => option.name,
  );
  final initialSelected = context.knobs.boolean(
    label: 'initialSelected',
  );

  // Keying on every knob value resets the pill's internal selection state
  // whenever a knob changes, so the preview always reflects the knobs
  // rather than stale state from a previous configuration.
  final key = ValueKey(
    '$label|${colorOption.name}|${size.name}|$initialSelected',
  );

  // ignore: avoid_positional_boolean_parameters document_ignores
  void onSelected(bool selected) => showToast('onSelected($selected)');

  final PillWidget pill = switch (size) {
    _PillSize.small => PillWidget.small(
      key: key,
      label: label,
      color: colorOption.color,
      initialSelected: initialSelected,
      onSelected: onSelected,
    ),
    _PillSize.medium => PillWidget.medium(
      key: key,
      label: label,
      color: colorOption.color,
      initialSelected: initialSelected,
      onSelected: onSelected,
    ),
    _PillSize.large => PillWidget.large(
      key: key,
      label: label,
      color: colorOption.color,
      initialSelected: initialSelected,
      onSelected: onSelected,
    ),
  };

  return Center(child: pill);
}
