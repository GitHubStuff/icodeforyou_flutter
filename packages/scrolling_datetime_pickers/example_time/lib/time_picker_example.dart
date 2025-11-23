// example/lib/time_picker_example.dart

import 'package:flutter/material.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';
import 'time_picker_controls.dart';

class TimePickerExample extends StatefulWidget {
  const TimePickerExample({super.key});

  @override
  State<TimePickerExample> createState() => _TimePickerExampleState();
}

class _TimePickerExampleState extends State<TimePickerExample> {
  DateTime _selectedTime = DateTime.now();
  bool _showSeconds = false;
  bool _enableHaptics = true;
  Color _backgroundColor = const Color(0xFF000033);
  double _dividerThickness = 1.5;
  Color _dividerColor = const Color(0xFFE0E0E0);
  double _dividerTransparency = 1.0;
  bool _useGlowEffect = false;
  bool _useBlurEffect = false;
  double _textSize = 24.0;
  Color _textColor = Colors.white;
  bool _fadeEnabled = true;
  double _fadeDistance = 40.0;
  double _portraitWidth = 175.0;
  double _portraitHeight = 200.0;
  double _borderRadius = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrolling Time Picker Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Display selected time
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  'Selected Time',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(_selectedTime, _showSeconds),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),

          // Time Picker
          Expanded(
            child: Center(
              child: ScrollingTimePicker(
                portraitSize: Size(_portraitWidth, _portraitHeight),
                initialDateTime: _selectedTime,
                onDateTimeChanged: (DateTime dateTime) {
                  setState(() {
                    _selectedTime = dateTime;
                  });
                },
                backgroundColor: _backgroundColor,
                showSeconds: _showSeconds,
                enableHaptics: _enableHaptics,
                timeStyle: TextStyle(
                  color: _textColor,
                  fontSize: _textSize,
                  fontWeight: FontWeight.bold,
                ),
                dividerConfiguration: _getDividerConfiguration(),
                fadeConfiguration: _getFadeConfiguration(),
                borderRadius: _borderRadius,
              ),
            ),
          ),

          // Controls
          TimePickerControls(
            showSeconds: _showSeconds,
            enableHaptics: _enableHaptics,
            backgroundColor: _backgroundColor,
            dividerThickness: _dividerThickness,
            dividerColor: _dividerColor,
            dividerTransparency: _dividerTransparency,
            useGlowEffect: _useGlowEffect,
            useBlurEffect: _useBlurEffect,
            textSize: _textSize,
            textColor: _textColor,
            fadeEnabled: _fadeEnabled,
            fadeDistance: _fadeDistance,
            portraitWidth: _portraitWidth,
            portraitHeight: _portraitHeight,
            borderRadius: _borderRadius,
            onShowSecondsChanged: (value) =>
                setState(() => _showSeconds = value),
            onEnableHapticsChanged: (value) =>
                setState(() => _enableHaptics = value),
            onBackgroundColorChanged: (value) =>
                setState(() => _backgroundColor = value),
            onDividerThicknessChanged: (value) =>
                setState(() => _dividerThickness = value),
            onDividerColorChanged: (value) =>
                setState(() => _dividerColor = value),
            onDividerTransparencyChanged: (value) =>
                setState(() => _dividerTransparency = value),
            onGlowEffectChanged: (value) => setState(() {
              _useGlowEffect = value;
              if (value) _useBlurEffect = false;
            }),
            onBlurEffectChanged: (value) => setState(() {
              _useBlurEffect = value;
              if (value) _useGlowEffect = false;
            }),
            onTextSizeChanged: (value) => setState(() => _textSize = value),
            onTextColorChanged: (value) => setState(() => _textColor = value),
            onFadeEnabledChanged: (value) =>
                setState(() => _fadeEnabled = value),
            onFadeDistanceChanged: (value) =>
                setState(() => _fadeDistance = value),
            onPortraitWidthChanged: (value) =>
                setState(() => _portraitWidth = value),
            onPortraitHeightChanged: (value) =>
                setState(() => _portraitHeight = value),
            onBorderRadiusChanged: (value) =>
                setState(() => _borderRadius = value),
          ),
        ],
      ),
    );
  }

  DividerConfiguration _getDividerConfiguration() {
    if (_useGlowEffect) {
      return DividerConfiguration.withGlow(
        color: _dividerColor,
        thickness: _dividerThickness,
        transparency: _dividerTransparency,
      );
    } else if (_useBlurEffect) {
      return DividerConfiguration.withBlur(
        color: _dividerColor,
        thickness: _dividerThickness,
        transparency: _dividerTransparency,
      );
    } else {
      return DividerConfiguration(
        color: _dividerColor,
        thickness: _dividerThickness,
        transparency: _dividerTransparency,
      );
    }
  }

  FadeConfiguration _getFadeConfiguration() {
    if (!_fadeEnabled) {
      return FadeConfiguration.noFade();
    }
    return FadeConfiguration.withDistance(
      distance: _fadeDistance,
      curve: Curves.linear,
    );
  }

  String _formatTime(DateTime time, bool showSeconds) {
    final hour =
        time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';

    if (showSeconds) {
      return '$hour:$minute:$second $period';
    }
    return '$hour:$minute $period';
  }
}
