// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

const Duration _kPulseHoldDuration = Duration(milliseconds: 150);
const Duration _kPulseGrowDuration = Duration(milliseconds: 150);
const Duration _kPulseShrinkDuration = Duration(milliseconds: 150);

const double _kPulseStartScale = 1;
const double _kPulseRestScale = 1;
const double _kPulsePeakScale = 1.15;

const Curve _kGrowCurve = Curves.easeOut;
const Curve _kShinkCurve = Curves.easeIn;

final class PulseConfig {
  const PulseConfig({
    this.growCurve = _kGrowCurve,
    this.growDuration = _kPulseGrowDuration,
    this.holdDuration = _kPulseHoldDuration,
    this.pulseStartScale = _kPulseStartScale,
    this.pulsePeakScale = _kPulsePeakScale,
    this.pulseRestScale = _kPulseRestScale,
    this.shrinkCurve = _kShinkCurve,
    this.shrinkDuration = _kPulseShrinkDuration,
  });
  final Duration holdDuration;
  final Duration growDuration;
  final Duration shrinkDuration;
  final double pulseRestScale;
  final double pulsePeakScale;
  final double pulseStartScale;
  final Curve growCurve;
  final Curve shrinkCurve;
}
