// packages/extensions/lib/datetime_ext/datetime_delta_text.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:extensions/extensions.dart' show DateTimeDelta, DateTimeDeltaText;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;


@widgetbook.UseCase(
  name: 'Default',
  type: DateTimeDeltaText,
)
Widget buildDateTimeDeltaTextUseCase(BuildContext context) {
  final delta = DateTimeDelta(
    isFuture: context.knobs.boolean(
      label: 'Is future',
      initialValue: true,
    ),
    years: context.knobs.int.slider(
      label: 'Years',
      initialValue: 2,
      min: 0,
      max: 10,
    ),
    months: context.knobs.int.slider(
      label: 'Months',
      initialValue: 3,
      min: 0,
      max: 11,
    ),
    days: context.knobs.int.slider(
      label: 'Days',
      initialValue: 5,
      min: 0,
      max: 30,
    ),
    hours: context.knobs.int.slider(
      label: 'Hours',
      initialValue: 4,
      min: 0,
      max: 23,
    ),
    minutes: context.knobs.int.slider(
      label: 'Minutes',
      initialValue: 30,
      min: 0,
      max: 59,
    ),
    seconds: context.knobs.int.slider(
      label: 'Seconds',
      initialValue: 0,
      min: 0,
      max: 59,
    ),
  );

  final showLeading = context.knobs.boolean(
    label: 'Leading icon',
    initialValue: false,
  );
  final showTrailing = context.knobs.boolean(
    label: 'Trailing icon',
    initialValue: false,
  );

  return Center(
    child: DateTimeDeltaText(
      delta: delta,
      format: context.knobs.stringOrNull(
        label: 'Format',
        initialValue: r'$*{[YY]} $*{(M>)} ${D} $*{hh>}:${*mm>}:$*{ss>}',
      ),
      leading: showLeading ? const Icon(Icons.schedule, size: 18) : null,
      trailing:
          showTrailing ? const Icon(Icons.chevron_right, size: 18) : null,
      style: TextStyle(
        color: context.knobs.color(
          label: 'Text color',
          initialValue: Colors.white,
        ),
        fontSize: context.knobs.double.slider(
          label: 'Font size',
          initialValue: 24,
          min: 10,
          max: 64,
        ),
      ),
    ),
  );
}
