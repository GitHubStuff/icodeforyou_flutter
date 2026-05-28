// programs/widgetbook_workspace/lib/packages/custom_widgets/anchored/anchored.usecase.dart
import 'package:custom_widgets/custom_widgets.dart' show Anchored;
import 'package:extensions/placement/placement.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: Anchored)
Widget anchoredDefault(BuildContext context) {
  final placement = context.knobs.object.dropdown<Placement>(
    label: 'atPlacement',
    options: Placement.values,
    initialOption: Placement.top,
    labelBuilder: (p) => p.name,
  );

  final offsetX = context.knobs.double.slider(
    label: 'offset.dx',
    initialValue: 0,
    min: -50,
    max: 50,
    divisions: 100,
  );

  final offsetY = context.knobs.double.slider(
    label: 'offset.dy',
    initialValue: 0,
    min: -50,
    max: 50,
    divisions: 100,
  );

  return Center(
    child: Anchored(
      atPlacement: placement,
      offset: Offset(offsetX, offsetY),
      toAnchor: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueGrey.shade400),
        ),
        alignment: Alignment.center,
        child: const Text('Anchor'),
      ),
      place: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          '9+',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}
