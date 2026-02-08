// datetime_delta_text.stories.dart

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:extensions/extensions.dart';

@widgetbook.UseCase(name: 'Basic Demo', type: DateTimeDeltaText)
Widget buildDateTimeDeltaTextDefault(BuildContext context) {
  final sampleDeltas = [
    DateTimeDelta(
      years: 2,
      months: 3,
      days: 15,
      hours: 4,
      minutes: 30,
      seconds: 45,
      isFuture: true,
    ),
    DateTimeDelta(days: 5, hours: 2, minutes: 15, isFuture: false),
    DateTimeDelta(minutes: 45, seconds: 30, isFuture: true),
    DateTimeDelta(isFuture: true),
  ];

  final deltaIndex = context.knobs.int.slider(
    label: 'Delta Sample',
    initialValue: 0,
    min: 0,
    max: sampleDeltas.length - 1,
  );

  return Center(
    child: DateTimeDeltaText(
      delta: sampleDeltas[deltaIndex],
      style: TextStyle(
        fontSize: context.knobs.double.slider(
          label: 'Font Size',
          initialValue: 16,
          min: 8,
          max: 48,
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Full Features', type: DateTimeDeltaText)
Widget buildDateTimeDeltaTextFull(BuildContext context) {
  final delta = DateTimeDelta(
    years: 1,
    months: 6,
    days: 10,
    hours: 4,
    minutes: 30,
    isFuture: true,
  );

  final showLeading = context.knobs.boolean(
    label: 'Show Leading Icon',
    initialValue: false,
  );

  final showTrailing = context.knobs.boolean(
    label: 'Show Trailing Icon',
    initialValue: false,
  );

  final fontSize = context.knobs.double.slider(
    label: 'Font Size',
    initialValue: 16,
    min: 8,
    max: 32,
  );

  return Container(
    padding: EdgeInsets.all(
      context.knobs.double.slider(
        label: 'Padding',
        initialValue: 16,
        min: 8,
        max: 32,
      ),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Default Format'),
          DateTimeDeltaText(
            delta: delta,
            leading: showLeading ? const Icon(Icons.schedule) : null,
            trailing: showTrailing ? const Icon(Icons.arrow_forward) : null,
            style: TextStyle(fontSize: fontSize),
          ),
          const SizedBox(height: 20),
          const Text('Compact Format'),
          DateTimeDeltaText(
            delta: delta,
            format: r'$*{[YY]} $*{(M>)} ${D} $*{h>}:$*{mm>}:$*{ss>}',
            style: TextStyle(fontSize: fontSize, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 20),
          const Text('Time Only'),
          DateTimeDeltaText(
            delta: delta,
            format: r'$*{hh>}:${mm}:${ss}',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
