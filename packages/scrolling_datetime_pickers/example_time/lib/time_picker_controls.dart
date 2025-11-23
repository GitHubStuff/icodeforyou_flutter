// example/lib/time_picker_controls.dart

import 'package:flutter/material.dart';

part 'time_picker_controls_builders.dart';

class TimePickerControls extends StatefulWidget {
  final bool showSeconds;
  final bool enableHaptics;
  final Color backgroundColor;
  final double dividerThickness;
  final Color dividerColor;
  final double dividerTransparency;
  final bool useGlowEffect;
  final bool useBlurEffect;
  final double textSize;
  final Color textColor;
  final bool fadeEnabled;
  final double fadeDistance;
  final double portraitWidth;
  final double portraitHeight;
  final double borderRadius;

  final Function(bool) onShowSecondsChanged;
  final Function(bool) onEnableHapticsChanged;
  final Function(Color) onBackgroundColorChanged;
  final Function(double) onDividerThicknessChanged;
  final Function(Color) onDividerColorChanged;
  final Function(double) onDividerTransparencyChanged;
  final Function(bool) onGlowEffectChanged;
  final Function(bool) onBlurEffectChanged;
  final Function(double) onTextSizeChanged;
  final Function(Color) onTextColorChanged;
  final Function(bool) onFadeEnabledChanged;
  final Function(double) onFadeDistanceChanged;
  final Function(double) onPortraitWidthChanged;
  final Function(double) onPortraitHeightChanged;
  final Function(double) onBorderRadiusChanged;

  const TimePickerControls({
    super.key,
    required this.showSeconds,
    required this.enableHaptics,
    required this.backgroundColor,
    required this.dividerThickness,
    required this.dividerColor,
    required this.dividerTransparency,
    required this.useGlowEffect,
    required this.useBlurEffect,
    required this.textSize,
    required this.textColor,
    required this.fadeEnabled,
    required this.fadeDistance,
    required this.portraitWidth,
    required this.portraitHeight,
    required this.borderRadius,
    required this.onShowSecondsChanged,
    required this.onEnableHapticsChanged,
    required this.onBackgroundColorChanged,
    required this.onDividerThicknessChanged,
    required this.onDividerColorChanged,
    required this.onDividerTransparencyChanged,
    required this.onGlowEffectChanged,
    required this.onBlurEffectChanged,
    required this.onTextSizeChanged,
    required this.onTextColorChanged,
    required this.onFadeEnabledChanged,
    required this.onFadeDistanceChanged,
    required this.onPortraitWidthChanged,
    required this.onPortraitHeightChanged,
    required this.onBorderRadiusChanged,
  });

  @override
  State<TimePickerControls> createState() => _TimePickerControlsState();
}

class _TimePickerControlsState extends State<TimePickerControls> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: ListView(
        children: [
          _buildSwitchTile(
              'Show Seconds', widget.showSeconds, widget.onShowSecondsChanged),
          _buildSwitchTile('Enable Haptics', widget.enableHaptics,
              widget.onEnableHapticsChanged),
          _buildColorTile('Background Color', widget.backgroundColor,
              widget.onBackgroundColorChanged),
          _buildColorTile(
              'Text Color', widget.textColor, widget.onTextColorChanged),
          _buildColorTile('Divider Color', widget.dividerColor,
              widget.onDividerColorChanged),
          _buildSliderTile(
            'Text Size: ${widget.textSize.toInt()}',
            widget.textSize,
            16.0,
            32.0,
            16,
            widget.onTextSizeChanged,
          ),
          _buildSliderTile(
            'Divider Thickness: ${widget.dividerThickness.toStringAsFixed(1)}',
            widget.dividerThickness,
            0.5,
            4.0,
            7,
            widget.onDividerThicknessChanged,
          ),
          _buildSliderTile(
            'Divider Opacity: ${(widget.dividerTransparency * 100).toInt()}%',
            widget.dividerTransparency,
            0.0,
            1.0,
            10,
            widget.onDividerTransparencyChanged,
          ),
          _buildEffectRow(),
          _buildSwitchTile(
              'Fade Effect', widget.fadeEnabled, widget.onFadeEnabledChanged),
          if (widget.fadeEnabled)
            _buildSliderTile(
              'Fade Distance: ${widget.fadeDistance.toInt()}',
              widget.fadeDistance,
              20.0,
              80.0,
              12,
              widget.onFadeDistanceChanged,
            ),
          _buildSizeControls(),
          _buildSliderTile(
            'Border Radius: ${widget.borderRadius.toInt()}',
            widget.borderRadius,
            0.0,
            30.0,
            30,
            widget.onBorderRadiusChanged,
          ),
        ],
      ),
    );
  }
}
