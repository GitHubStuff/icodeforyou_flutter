// programs/widgetbook_workspace/lib/package/datetime_popover_pickers/time_picker.usecase.dart

import 'package:datetime_popover_pickers/datetime_popover_pickers.dart'
    show PickerSize, TimePicker;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const EdgeInsets _kFramePadding = EdgeInsets.all(24);
const double _kGallerySpacing = 32;
const double _kReadoutSpacing = 16;

const String _kSizeKnob = 'size';
const String _kShowSecondsKnob = 'showSeconds';
const String _kTextColorKnob = 'textStyle.color';

/// Fixed seed so every use case stands up in a known state.
final DateTime _kSeedTime = DateTime(2024, 12, 21, 1, 47, 22);

@widgetbook.UseCase(name: 'Playground', type: TimePicker)
Widget timePickerPlaygroundUseCase(BuildContext context) {
  final size = context.knobs.object.dropdown<PickerSize>(
    label: _kSizeKnob,
    options: PickerSize.values,
    initialOption: PickerSize.regular,
    labelBuilder: (value) => value.name,
  );
  final showSeconds = context.knobs.boolean(
    label: _kShowSecondsKnob,
    initialValue: true,
  );
  final textColor = context.knobs.colorOrNull(label: _kTextColorKnob);

  return _TimePickerHost(
    size: size,
    showSeconds: showSeconds,
    textStyle: textColor == null ? null : TextStyle(color: textColor),
  );
}

@widgetbook.UseCase(name: 'Size Gallery', type: TimePicker)
Widget timePickerSizeGalleryUseCase(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      padding: _kFramePadding,
      child: Column(
        children: [
          for (final size in PickerSize.values) ...[
            Text(size.name, style: Theme.of(context).textTheme.labelLarge),
            TimePicker(
              size: size,
              showSeconds: true,
              initialTime: _kSeedTime,
              onTimeChanged: (_) {},
            ),
            const SizedBox(height: _kGallerySpacing),
          ],
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Without Seconds', type: TimePicker)
Widget timePickerWithoutSecondsUseCase(BuildContext context) {
  return const _TimePickerHost(
    size: PickerSize.regular,
    showSeconds: false,
  );
}

/// Hosts a [TimePicker] and echoes the last emitted value beneath it.
///
/// [TimePicker] reads [TimePicker.initialTime] and [TimePicker.showSeconds]
/// once in `initState` and owns its own scroll controllers, so a knob change
/// that only rebuilds would leave the wheels out of sync. The picker is
/// therefore keyed on every structural knob, forcing a fresh `State` whenever
/// one changes.
class _TimePickerHost extends StatefulWidget {
  const _TimePickerHost({
    required this.size,
    required this.showSeconds,
    this.textStyle,
  });

  final PickerSize size;
  final bool showSeconds;
  final TextStyle? textStyle;

  @override
  State<_TimePickerHost> createState() => _TimePickerHostState();
}

class _TimePickerHostState extends State<_TimePickerHost> {
  late DateTime _value = _kSeedTime;

  void _onTimeChanged(DateTime time) => setState(() => _value = time);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: _kFramePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TimePicker(
                key: ValueKey((widget.size, widget.showSeconds)),
                size: widget.size,
                showSeconds: widget.showSeconds,
                initialTime: _kSeedTime,
                textStyle: widget.textStyle,
                onTimeChanged: _onTimeChanged,
              ),
              const SizedBox(height: _kReadoutSpacing),
              Text(
                'Emitted: ${_value.toIso8601String()}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
