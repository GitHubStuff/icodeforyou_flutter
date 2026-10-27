// programs/widgetbook_workspace/lib/packages/dual_selection/single_selection.usecase.dart

import 'package:dual_selection/dual_selection.dart' show SingleSelection;
import 'package:dual_selection/src/defaults.dart' show Defaults;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Interactive', type: SingleSelection)
Widget buildSingleSelectionInteractiveUseCase(BuildContext context) {
  final knobs = context.knobs;

  return Center(
    child: SingleSelection(
      first: const _Header(label: 'Header'),
      firstChild: const _Body(label: 'Body', color: Colors.blue),
      borderColor: knobs.color(
        label: 'borderColor',
        initialValue: Colors.black,
      ),
      cornerRadius: knobs.double.slider(
        label: 'cornerRadius',
        initialValue: Defaults.kCornerRadius,
        min: 0,
        max: 40,
      ),
      borderWidth: knobs.double.slider(
        label: 'borderWidth',
        initialValue: Defaults.kBorderWidth,
        min: 0,
        max: 12,
      ),
      headerHeight: knobs.double.slider(
        label: 'headerHeight',
        initialValue: Defaults.kHeaderHeight,
        min: 24,
        max: 120,
      ),
      bodyHeight: knobs.double.slider(
        label: 'bodyHeight',
        initialValue: Defaults.kBodyHeight,
        min: 60,
        max: 500,
      ),
      width: knobs.double.slider(
        label: 'width',
        initialValue: Defaults.kWidth,
        min: 120,
        max: 400,
      ),
    ),
  );
}

@UseCase(name: 'Defaults', type: SingleSelection)
Widget buildSingleSelectionDefaultsUseCase(BuildContext context) {
  return const Center(
    child: SingleSelection(
      first: _Header(label: 'Header'),
      firstChild: _Body(label: 'Body', color: Colors.blue),
      borderColor: Colors.black,
    ),
  );
}

@UseCase(name: 'Square Corners, No Border', type: SingleSelection)
Widget buildSingleSelectionSquareNoBorderUseCase(BuildContext context) {
  return const Center(
    child: SingleSelection(
      first: _Header(label: 'Header'),
      firstChild: _Body(label: 'Body', color: Colors.blue),
      borderColor: Colors.transparent,
      cornerRadius: 0,
      borderWidth: 0,
    ),
  );
}

@UseCase(name: 'Bounded Scrollable Body', type: SingleSelection)
Widget buildSingleSelectionScrollableBodyUseCase(BuildContext context) {
  return Center(
    child: SingleSelection(
      first: const _Header(label: 'Scroll me'),
      firstChild: ListView.builder(
        itemCount: 40,
        itemBuilder: (context, index) => ListTile(title: Text('Row $index')),
      ),
      borderColor: Colors.black,
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade300,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
