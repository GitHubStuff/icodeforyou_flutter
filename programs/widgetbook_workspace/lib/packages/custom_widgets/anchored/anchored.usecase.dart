// lib/packages/custom_widgets/lib/src/anchored/anchored.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:custom_widgets/custom_widgets.dart';
import 'package:extensions/enum/src/placement.dart' show Placement;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: Anchored)
Widget anchoredUseCase(BuildContext context) {
  final placement = context.knobs.object.dropdown<Placement>(
    label: 'atPlacement',
    options: Placement.values,
    initialOption: Placement.top,
    labelBuilder: (p) => p.name,
  );

  final dx = context.knobs.double.slider(
    label: 'offset.dx',
    initialValue: 0,
    min: -40,
    max: 40,
  );

  final dy = context.knobs.double.slider(
    label: 'offset.dy',
    initialValue: 0,
    min: -40,
    max: 40,
  );

  return Center(
    child: Anchored(
      atPlacement: placement,
      offset: Offset(dx, dy),
      toAnchor: Container(
        width: 200,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text(
          'anchor',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'badge',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    ),
  );
}
