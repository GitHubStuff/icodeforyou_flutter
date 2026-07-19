// programs/widgetbook_workspace/lib/packages/analog_clock_widget/timezones.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:analog_clock_widget/analog_clock_widget.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

@widgetbook.UseCase(name: 'World clocks (timezones)', type: AnalogClock)
Widget timezonesAnalogClockUseCase(BuildContext context) {
  final radius = context.knobs.double.slider(
    label: 'radius',
    initialValue: 60,
    min: 30,
    max: 120,
  );

  // utcMinuteOffset is the axis (one per city) — every ClockStyle property
  // is shared across all city clocks and surfaced via knobs.
  final style = clockStyleKnobs(context);

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        for (final tz in _cities)
          _CityClock(city: tz, radius: radius, style: style),
      ],
    ),
  );
}

class _CityClock extends StatelessWidget {
  const _CityClock({
    required this.city,
    required this.radius,
    required this.style,
  });

  final _City city;
  final double radius;
  final ClockStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnalogClock(
          radius: radius,
          utcMinuteOffset: city.utcMinuteOffset,
          style: style,
        ),
        const Gap(8),
        Text(city.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          city.utcLabel,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}

class _City extends Equatable {
  const _City(this.name, this.utcMinuteOffset);

  final String name;
  final int utcMinuteOffset;

  String get utcLabel {
    final hours = utcMinuteOffset ~/ 60;
    final mins = utcMinuteOffset.abs() % 60;
    final sign = utcMinuteOffset >= 0 ? '+' : '−';
    final hh = hours.abs().toString().padLeft(2, '0');
    final mm = mins.toString().padLeft(2, '0');
    return 'UTC$sign$hh:$mm';
  }

  @override
  List<Object?> get props => [name, utcMinuteOffset];
}

const _cities = <_City>[
  _City('Honolulu', -600),
  _City('Los Angeles', -480),
  _City('New York', -300),
  _City('London', 0),
  _City('Paris', 60),
  _City('Mumbai', 330),
  _City('Tokyo', 540),
  _City('Sydney', 660),
];
