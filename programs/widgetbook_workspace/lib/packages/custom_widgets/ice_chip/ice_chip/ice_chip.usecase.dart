// programs/widgetbook_workspace/lib/packages/custom_widgets/ice_chip/ice_chip/ice_chip.usecase.dart
import 'package:custom_widgets/custom_widgets.dart' show IceChip;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Named color option for the background-color dropdown knob.
typedef _ColorOption = ({String name, Color color});

/// The background fills offered by the color dropdown knob.
const List<_ColorOption> _backgroundColors = <_ColorOption>[
  (name: 'Ice Blue', color: Color(0xFFB3E5FC)),
  (name: 'Mint', color: Color(0xFFB2DFDB)),
  (name: 'Berry', color: Color(0xFFF8BBD0)),
  (name: 'Vanilla', color: Color(0xFFFFF9C4)),
  (name: 'Charcoal', color: Color(0xFF37474F)),
  (name: 'Purple', color: Colors.deepPurple),
];

/// Named widget option for the default constructor's child dropdown knob.
typedef _ChildOption = ({String name, Widget child});

/// The label widgets offered to the default-constructor use case.
const List<_ChildOption> _children = <_ChildOption>[
  (name: 'Snowflake icon', child: Icon(Icons.ac_unit)),
  (name: 'Ice cream icon', child: Icon(Icons.icecream)),
  (
    name: 'Icon + text row',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.ac_unit),
        SizedBox(width: 4),
        Text('CHILL'),
      ],
    ),
  ),
];

/// Shared knob: whether the theme-aware border is drawn.
///
/// Toggling this exercises both branches of the chip's border logic —
/// visible (black/white depending on brightness) and transparent — while
/// keeping the chip's size constant.
bool _showBorderKnob(BuildContext context) {
  return context.knobs.boolean(
    label: 'Show border',
    initialValue: true,
  );
}

/// Shared knob: the chip's background fill, chosen from [_backgroundColors].
Color _backgroundColorKnob(BuildContext context) {
  return context.knobs.object
      .dropdown<_ColorOption>(
        label: 'Background color',
        options: _backgroundColors,
        initialOption: _backgroundColors.first,
        labelBuilder: (_ColorOption option) => option.name,
      )
      .color;
}

/// Use case for the default constructor: an arbitrary [Widget] child.
@widgetbook.UseCase(name: 'Default (widget child)', type: IceChip)
Widget buildIceChipDefaultUseCase(BuildContext context) {
  final child = context.knobs.object.dropdown<_ChildOption>(
    label: 'Child',
    options: _children,
    initialOption: _children.first,
    labelBuilder: (_ChildOption option) => option.name,
  );

  return Center(
    child: IceChip(
      child.child,
      backgroundColor: _backgroundColorKnob(context),
      showBorder: _showBorderKnob(context),
      onPress: () => debugPrint('IceChip (default) pressed'),
    ),
  );
}

/// Use case for the [IceChip.text] constructor: a plain [String] label,
/// rendered upper-cased in the theme-aware accent color.
@widgetbook.UseCase(name: 'Text', type: IceChip)
Widget buildIceChipTextUseCase(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Vanilla',
  );

  return Center(
    child: IceChip.text(
      label,
      backgroundColor: _backgroundColorKnob(context),
      showBorder: _showBorderKnob(context),
      onPress: () => debugPrint('IceChip.text pressed'),
    ),
  );
}
