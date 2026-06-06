// programs/widgetbook_workspace/lib/packages/analog_clock_widget/injected_providers.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:analog_clock_widget/analog_clock_widget.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

@widgetbook.UseCase(name: 'Injected providers (frozen time)', type: AnalogClock)
Widget injectedProvidersAnalogClockUseCase(BuildContext context) {
  final radius = context.knobs.double.slider(
    label: 'radius',
    initialValue: 100,
    min: 30,
    max: 180,
  );

  final hour = context.knobs.int.slider(
    label: 'frozen hour',
    initialValue: 10,
    min: 0,
    max: 23,
  );

  final minute = context.knobs.int.slider(
    label: 'frozen minute',
    initialValue: 10,
    min: 0,
    max: 59,
  );

  final second = context.knobs.int.slider(
    label: 'frozen second',
    initialValue: 30,
    min: 0,
    max: 59,
  );

  final style = clockStyleKnobs(context);
  final frozen = _FrozenTime(hour: hour, minute: minute, second: second);

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Frozen at ${frozen.label}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const Gap(16),
        AnalogClock(
          radius: radius,
          timeProvider: _FrozenTimeProvider(frozen),
          themeProvider: (ctx) => Theme.of(ctx).colorScheme,
          style: style,
        ),
      ],
    ),
  );
}

class _FrozenTime extends Equatable {
  const _FrozenTime({
    required this.hour,
    required this.minute,
    required this.second,
  });

  final int hour;
  final int minute;
  final int second;

  String get label =>
      '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}:'
      '${second.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [hour, minute, second];
}

class _FrozenTimeProvider implements TimeProvider {
  _FrozenTimeProvider(this.frozen);

  final _FrozenTime frozen;

  @override
  DateTime get now => DateTime(
    2000,
    1,
    1,
    frozen.hour,
    frozen.minute,
    frozen.second,
  );
}
