// widgetbook_analog_clock.dart
import 'package:analog_clock_widget/analog_clock_widget.dart' show AnalogClock;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AnalogClock)
Widget buildAnalogClockCase(BuildContext context) {
  return Center(
    child: AnalogClock(
      // Size Controls
      radius: context.knobs.double.slider(
        label: 'Radius',
        initialValue: 100,
        min: 30,
        max: 200,
      ),

      // Time Zone Control
      utcMinuteOffset: context.knobs.int.slider(
        label: 'UTC Offset (minutes)',
        initialValue: 0,
        min: -720, // -12 hours
        max: 720, // +12 hours
      ),

      // Color Controls
      faceColor: context.knobs.colorOrNull(
        label: 'Face Color',
        initialValue: Colors.white,
      ),

      borderColor: context.knobs.colorOrNull(
        label: 'Border Color',
        initialValue: Colors.black,
      ),

      hourHandColor: context.knobs.colorOrNull(
        label: 'Hour Hand Color',
        initialValue: Colors.black,
      ),

      minuteHandColor: context.knobs.colorOrNull(
        label: 'Minute Hand Color',
        initialValue: null, // Will default to hour hand color
      ),

      secondHandColor: context.knobs.colorOrNull(
        label: 'Second Hand Color',
        initialValue: Colors.red,
      ),

      // Feature Toggles
      showNumbers: context.knobs.boolean(
        label: 'Show Numbers',
        initialValue: true,
      ),

      showSecondHand: context.knobs.boolean(
        label: 'Show Second Hand',
        initialValue: true,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Dark Theme', type: AnalogClock)
Widget buildAnalogClockDarkCase(BuildContext context) {
  return Container(
    color: Colors.grey[900],
    child: Center(
      child: AnalogClock(
        radius: context.knobs.double.slider(
          label: 'Radius',
          initialValue: 120,
          min: 30,
          max: 200,
        ),
        faceColor: context.knobs.colorOrNull(
          label: 'Face Color',
          initialValue: Colors.grey[800],
        ),
        borderColor: context.knobs.colorOrNull(
          label: 'Border Color',
          initialValue: Colors.white70,
        ),
        hourHandColor: context.knobs.colorOrNull(
          label: 'Hour Hand Color',
          initialValue: Colors.white,
        ),
        minuteHandColor: context.knobs.colorOrNull(
          label: 'Minute Hand Color',
          initialValue: Colors.white70,
        ),
        secondHandColor: context.knobs.colorOrNull(
          label: 'Second Hand Color',
          initialValue: Colors.redAccent,
        ),
        showNumbers: context.knobs.boolean(
          label: 'Show Numbers',
          initialValue: true,
        ),
        showSecondHand: context.knobs.boolean(
          label: 'Show Second Hand',
          initialValue: true,
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Minimal', type: AnalogClock)
Widget buildAnalogClockMinimalCase(BuildContext context) {
  return Center(
    child: AnalogClock(
      radius: context.knobs.double.slider(
        label: 'Radius',
        initialValue: 80,
        min: 30,
        max: 200,
      ),
      faceColor: context.knobs.colorOrNull(
        label: 'Face Color',
        initialValue: Colors.transparent,
      ),
      borderColor: context.knobs.colorOrNull(
        label: 'Border Color',
        initialValue: Colors.grey[300],
      ),
      hourHandColor: context.knobs.colorOrNull(
        label: 'Hour Hand Color',
        initialValue: Colors.grey[700],
      ),
      minuteHandColor: context.knobs.colorOrNull(
        label: 'Minute Hand Color',
        initialValue: Colors.grey[600],
      ),
      secondHandColor: context.knobs.colorOrNull(
        label: 'Second Hand Color',
        initialValue: null, // Hide second hand
      ),
      showNumbers: context.knobs.boolean(
        label: 'Show Numbers',
        initialValue: false,
      ),
      showSecondHand: context.knobs.boolean(
        label: 'Show Second Hand',
        initialValue: false,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Multiple Sizes', type: AnalogClock)
Widget buildAnalogClockMultipleSizesCase(BuildContext context) {
  final showNumbers = context.knobs.boolean(
    label: 'Show Numbers',
    initialValue: true,
  );

  final showSecondHand = context.knobs.boolean(
    label: 'Show Second Hand',
    initialValue: true,
  );

  final faceColor = context.knobs.colorOrNull(
    label: 'Face Color',
    initialValue: Colors.white,
  );

  final borderColor = context.knobs.colorOrNull(
    label: 'Border Color',
    initialValue: Colors.black,
  );

  return Center(
    child: Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        // Small
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnalogClock(
              radius: 40,
              faceColor: faceColor,
              borderColor: borderColor,
              showNumbers: showNumbers,
              showSecondHand: showSecondHand,
            ),
            const SizedBox(height: 8),
            const Text('Small (40px)', style: TextStyle(fontSize: 12)),
          ],
        ),

        // Medium
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnalogClock(
              radius: 80,
              faceColor: faceColor,
              borderColor: borderColor,
              showNumbers: showNumbers,
              showSecondHand: showSecondHand,
            ),
            const SizedBox(height: 8),
            const Text('Medium (80px)', style: TextStyle(fontSize: 12)),
          ],
        ),

        // Large
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnalogClock(
              radius: 120,
              faceColor: faceColor,
              borderColor: borderColor,
              showNumbers: showNumbers,
              showSecondHand: showSecondHand,
            ),
            const SizedBox(height: 8),
            const Text('Large (120px)', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    ),
  );
}
