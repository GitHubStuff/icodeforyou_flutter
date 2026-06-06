// programs/widgetbook_workspace/lib/packages/analog_clock_widget/themed_presets.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:analog_clock_widget/analog_clock_widget.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Themed presets', type: AnalogClock)
Widget themedPresetsAnalogClockUseCase(BuildContext context) {
  final radius = context.knobs.double.slider(
    label: 'radius',
    initialValue: 90,
    min: 30,
    max: 150,
  );

  // Optional overrides: color knobs use null to mean "keep preset value";
  // bool/enum overrides are gated by their own toggle since they can't be
  // null. With nothing overridden, each preset shows pristine — flip the
  // gates / pick non-null colours to retune the whole row.
  final faceColor = context.knobs.colorOrNull(
    label: 'face color (override)',
    initialValue: null,
  );
  final borderColor = context.knobs.colorOrNull(
    label: 'border color (override)',
    initialValue: null,
  );
  final hourHandColor = context.knobs.colorOrNull(
    label: 'hour hand color (override)',
    initialValue: null,
  );
  final minuteHandColor = context.knobs.colorOrNull(
    label: 'minute hand color (override)',
    initialValue: null,
  );
  final secondHandColor = context.knobs.colorOrNull(
    label: 'second hand color (override)',
    initialValue: null,
  );

  final overrideShowNumbers = context.knobs.boolean(
    label: 'override show numbers',
    initialValue: false,
  );
  final showNumbersValue = context.knobs.boolean(
    label: '  → show numbers',
    initialValue: true,
  );

  final overrideShowSecondHand = context.knobs.boolean(
    label: 'override show second hand',
    initialValue: false,
  );
  final showSecondHandValue = context.knobs.boolean(
    label: '  → show second hand',
    initialValue: true,
  );

  final overrideFaceStyle = context.knobs.boolean(
    label: 'override face style',
    initialValue: false,
  );
  final faceStyleValue = context.knobs.object.dropdown<ClockFaceStyle>(
    label: '  → face style',
    options: ClockFaceStyle.values,
    initialOption: ClockFaceStyle.classic,
    labelBuilder: (s) => s.name,
  );

  final overrideHandStyle = context.knobs.boolean(
    label: 'override hand style',
    initialValue: false,
  );
  final handStyleValue = context.knobs.object.dropdown<HandStyle>(
    label: '  → hand style',
    options: HandStyle.values,
    initialOption: HandStyle.traditional,
    labelBuilder: (s) => s.name,
  );

  ClockStyle apply(ClockStyle base) {
    return base.copyWith(
      faceColor: faceColor ?? base.faceColor,
      borderColor: borderColor ?? base.borderColor,
      hourHandColor: hourHandColor ?? base.hourHandColor,
      minuteHandColor: minuteHandColor ?? base.minuteHandColor,
      secondHandColor: secondHandColor ?? base.secondHandColor,
      showNumbers: overrideShowNumbers ? showNumbersValue : base.showNumbers,
      showSecondHand:
          overrideShowSecondHand ? showSecondHandValue : base.showSecondHand,
      faceStyle: overrideFaceStyle ? faceStyleValue : base.faceStyle,
      handStyle: overrideHandStyle ? handStyleValue : base.handStyle,
    );
  }

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        for (final preset in _presets)
          _PresetTile(
            preset: preset,
            radius: radius,
            effectiveStyle: apply(preset.style),
          ),
      ],
    ),
  );
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.preset,
    required this.radius,
    required this.effectiveStyle,
  });

  final _Preset preset;
  final double radius;
  final ClockStyle effectiveStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: preset.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnalogClock(radius: radius, style: effectiveStyle),
          const Gap(12),
          Text(
            preset.name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: preset.labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Preset extends Equatable {
  const _Preset({
    required this.name,
    required this.background,
    required this.labelColor,
    required this.style,
  });

  final String name;
  final Color background;
  final Color labelColor;
  final ClockStyle style;

  @override
  List<Object?> get props => [name, background, labelColor, style];
}

final _presets = <_Preset>[
  _Preset(
    name: 'Midnight',
    background: const Color(0xFF0B1020),
    labelColor: Colors.white,
    style: const ClockStyle(
      faceColor: Color(0xFF111935),
      borderColor: Color(0xFF8FA3FF),
      hourHandColor: Colors.white,
      minuteHandColor: Colors.white,
      secondHandColor: Color(0xFFFF6B6B),
      faceStyle: ClockFaceStyle.modern,
      handStyle: HandStyle.modern,
    ),
  ),
  _Preset(
    name: 'Paper',
    background: const Color(0xFFF6F1E7),
    labelColor: Colors.black87,
    style: const ClockStyle(
      faceColor: Color(0xFFFBF8F1),
      borderColor: Color(0xFF8B7355),
      hourHandColor: Color(0xFF2B2B2B),
      minuteHandColor: Color(0xFF2B2B2B),
      secondHandColor: Color(0xFFC0392B),
      faceStyle: ClockFaceStyle.classic,
      handStyle: HandStyle.traditional,
    ),
  ),
  _Preset(
    name: 'Minimal',
    background: Colors.white,
    labelColor: Colors.black87,
    style: const ClockStyle(
      faceColor: Colors.white,
      borderColor: Colors.black,
      hourHandColor: Colors.black,
      minuteHandColor: Colors.black,
      secondHandColor: Colors.black54,
      showNumbers: false,
      faceStyle: ClockFaceStyle.minimal,
      handStyle: HandStyle.sleek,
    ),
  ),
  _Preset(
    name: 'Neon',
    background: const Color(0xFF0A0A0A),
    labelColor: const Color(0xFF00FFD1),
    style: const ClockStyle(
      faceColor: Colors.black,
      borderColor: Color(0xFF00FFD1),
      hourHandColor: Color(0xFF00FFD1),
      minuteHandColor: Color(0xFF00FFD1),
      secondHandColor: Color(0xFFFF00AA),
      faceStyle: ClockFaceStyle.modern,
      handStyle: HandStyle.sleek,
    ),
  ),
  _Preset(
    name: 'Rose',
    background: const Color(0xFFFDE7EF),
    labelColor: const Color(0xFF8E2155),
    style: const ClockStyle(
      faceColor: Color(0xFFFFF5F8),
      borderColor: Color(0xFFB73E73),
      hourHandColor: Color(0xFF8E2155),
      minuteHandColor: Color(0xFF8E2155),
      secondHandColor: Color(0xFFD4AF37),
      faceStyle: ClockFaceStyle.classic,
      handStyle: HandStyle.modern,
    ),
  ),
  _Preset(
    name: 'Forest',
    background: const Color(0xFF1B3B2F),
    labelColor: const Color(0xFFE8F5E9),
    style: const ClockStyle(
      faceColor: Color(0xFF2D5A47),
      borderColor: Color(0xFFC8B273),
      hourHandColor: Color(0xFFE8F5E9),
      minuteHandColor: Color(0xFFE8F5E9),
      secondHandColor: Color(0xFFC8B273),
      faceStyle: ClockFaceStyle.classic,
      handStyle: HandStyle.traditional,
    ),
  ),
];
