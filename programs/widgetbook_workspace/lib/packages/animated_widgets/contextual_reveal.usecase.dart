// lib/packages/animated_widgets/contextual_reveal.usecase.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const Map<String, ContextualPosition> _positions = {
  'modal': ContextualPosition.modal,
  'popover': ContextualPosition.popover,
  'bottomSheet': ContextualPosition.bottomSheet,
  'push': ContextualPosition.push,
};

Widget _withTheme(BuildContext context, Widget child) {
  final brightness = Theme.of(context).brightness;
  return Theme(
    data: Theme.of(context).copyWith(
      extensions: [
        if (brightness == Brightness.light)
          ContextualRevealTheme.light()
        else
          ContextualRevealTheme.dark(),
      ],
    ),
    child: child,
  );
}

@widgetbook.UseCase(name: 'Default', type: ContextualReveal)
Widget contextualRevealDefault(BuildContext context) {
  final positionName = context.knobs.object.dropdown<String>(
    label: 'Double-tap position',
    options: _positions.keys.toList(),
    initialOption: 'modal',
  );

  return _withTheme(
    context,
    Center(
      child: ContextualReveal(
        body: Container(
          width: 120,
          height: 120,
          color: Colors.deepPurple,
          alignment: Alignment.center,
          child: const Text(
            'Tap / Hold\nDouble-tap',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        tapChild: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Tap content'),
        ),
        longChild: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Long-press content'),
        ),
        doubleChild: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Double-tap content'),
        ),
        doublePosition: _positions[positionName]!,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Simple', type: ContextualReveal)
Widget contextualRevealSimple(BuildContext context) {
  return _withTheme(
    context,
    Center(
      child: ContextualReveal.simple(
        body: Container(
          width: 120,
          height: 120,
          color: Colors.teal,
          alignment: Alignment.center,
          child: const Text(
            'Tap / Hold\nDouble-tap',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        sharedChild: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Shared child content'),
        ),
      ),
    ),
  );
}
