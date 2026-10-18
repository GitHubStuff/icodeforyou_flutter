// programs/widgetbook_workspace/lib/package/datetime_popover_pickers/fat_picker.usecase.dart

import 'package:datetime_popover_pickers/datetime_popover_pickers.dart'
    show DatePicker, FatPicker, PickerSize;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const EdgeInsets _kFramePadding = EdgeInsets.all(24);
const double _kGallerySpacing = 32;
const double _kReadoutSpacing = 16;

const String _kSizeKnob = 'size';
const String _kShowSecondsKnob = 'showSeconds';
const String _kMinimumYearKnob = 'minimumYear';
const String _kMaximumYearKnob = 'maximumYear';
const String _kTextColorKnob = 'textStyle.color';

const int _kYearSliderMin = 1800;
const int _kYearSliderMax = 2100;

/// Fixed seed so every use case stands up in a known state.
final DateTime _kSeedDateTime = DateTime(2024, 12, 21, 1, 47, 22);

@widgetbook.UseCase(name: 'Playground', type: FatPicker)
Widget fatPickerPlaygroundUseCase(BuildContext context) {
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
  final minimumYear = context.knobs.int.slider(
    label: _kMinimumYearKnob,
    initialValue: DatePicker.defaultMinimumYear,
    min: _kYearSliderMin,
    max: _kYearSliderMax,
  );
  final maximumYear = context.knobs.int.slider(
    label: _kMaximumYearKnob,
    initialValue: DatePicker.defaultMaximumYear,
    min: _kYearSliderMin,
    max: _kYearSliderMax,
  );
  final textColor = context.knobs.colorOrNull(label: _kTextColorKnob);

  return _FatPickerHost(
    size: size,
    showSeconds: showSeconds,
    // The inner DatePicker asserts minimumYear <= maximumYear; keep it legal.
    minimumYear: minimumYear <= maximumYear ? minimumYear : maximumYear,
    maximumYear: maximumYear,
    textStyle: textColor == null ? null : TextStyle(color: textColor),
  );
}

@widgetbook.UseCase(name: 'Size Gallery', type: FatPicker)
Widget fatPickerSizeGalleryUseCase(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      padding: _kFramePadding,
      child: Column(
        children: [
          for (final size in PickerSize.values) ...[
            Text(size.name, style: Theme.of(context).textTheme.labelLarge),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: FatPicker(
                size: size,
                showSeconds: true,
                initialDateTime: _kSeedDateTime,
                onDateTimeChanged: (_) {},
              ),
            ),
            const SizedBox(height: _kGallerySpacing),
          ],
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Without Seconds', type: FatPicker)
Widget fatPickerWithoutSecondsUseCase(BuildContext context) {
  return const _FatPickerHost(
    size: PickerSize.regular,
    showSeconds: false,
    minimumYear: DatePicker.defaultMinimumYear,
    maximumYear: DatePicker.defaultMaximumYear,
  );
}

/// Hosts a [FatPicker] and echoes the last merged value beneath it.
///
/// [FatPicker] and the [DatePicker] / [TimePicker] it composes all read their
/// initial values, year range and [FatPicker.showSeconds] once in `initState`
/// and own their own scroll controllers, so a knob change that only rebuilds
/// would leave the wheels out of sync. The picker is therefore keyed on every
/// structural knob, forcing a fresh `State` whenever one changes.
class _FatPickerHost extends StatefulWidget {
  const _FatPickerHost({
    required this.size,
    required this.showSeconds,
    required this.minimumYear,
    required this.maximumYear,
    this.textStyle,
  });

  final PickerSize size;
  final bool showSeconds;
  final int minimumYear;
  final int maximumYear;
  final TextStyle? textStyle;

  @override
  State<_FatPickerHost> createState() => _FatPickerHostState();
}

class _FatPickerHostState extends State<_FatPickerHost> {
  late DateTime _value = _kSeedDateTime;

  void _onDateTimeChanged(DateTime dateTime) =>
      setState(() => _value = dateTime);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: _kFramePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FatPicker(
                  key: ValueKey((
                    widget.size,
                    widget.showSeconds,
                    widget.minimumYear,
                    widget.maximumYear,
                  )),
                  size: widget.size,
                  showSeconds: widget.showSeconds,
                  initialDateTime: _kSeedDateTime,
                  minimumYear: widget.minimumYear,
                  maximumYear: widget.maximumYear,
                  textStyle: widget.textStyle,
                  onDateTimeChanged: _onDateTimeChanged,
                ),
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
