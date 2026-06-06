// lib/packages/custom_widgets/lib/src/uniform_cluster/uniform_cluster.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:custom_widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:platform_utils/platform_utils.dart' show DipScale;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: UniformCluster)
Widget uniformClusterUseCase(BuildContext context) {
  final axis = context.knobs.object.dropdown<Axis>(
    label: 'axis',
    options: Axis.values,
    initialOption: Axis.horizontal,
    labelBuilder: (a) => a.name,
  );

  final childCount = context.knobs.int.slider(
    label: 'child count',
    initialValue: 3,
    min: 2,
    max: 5,
  );

  final labels = ['OK', 'Cancel', 'Save changes', 'Maybe later', 'Help'];

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: UniformCluster(
          axis: axis,
          spacing: DipScale.sm,
          children: [
            for (var i = 0; i < childCount; i++)
              FilledButton(
                onPressed: () {},
                child: Text(labels[i % labels.length]),
              ),
          ],
        ),
      ),
    ),
  );
}
