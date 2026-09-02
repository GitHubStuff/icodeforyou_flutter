// programs/widgetbook_workspace/lib/packages/stacking_widgets/stacking_widgets.usecase.dart

import 'package:flutter/material.dart';
import 'package:stacking_widgets/stacking_widgets.dart'
    show PiledWidget, StackingWidgets;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: StackingWidgets,
)
Widget buildStackingWidgetsUseCase(BuildContext context) {
  return Center(
    child: StackingWidgets(
      size: const Size(200, 200),
      base: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.blue.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Base',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      piledWidgets: const [
        PiledWidget(
          offset: Offset(-30, -30),
          child: CircleAvatar(
            backgroundColor: Colors.red,
            child: Icon(Icons.star, color: Colors.white),
          ),
        ),
        PiledWidget(
          offset: Offset(40, 50),
          child: CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.check, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
