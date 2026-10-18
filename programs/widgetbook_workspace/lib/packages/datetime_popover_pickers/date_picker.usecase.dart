// programs/widgetbook_workspace/lib/package/datetime_popover_pickers/date_picker.usecase.dart

import 'package:datetime_popover_pickers/datetime_popover_pickers.dart'
    show DatePicker, PickerSize;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const EdgeInsets _kFramePadding = EdgeInsets.all(24);
const double _kGallerySpacing = 32;
const double _kReadoutSpacing = 16;

const String _kSizeKnob = 'size';
const String _kMinimumYearKnob = 'minimumYear';
const String _kMaximumYearKnob = 'maximumYear';
const String _kTextColorKnob = 'textStyle.color';

const int _kYearSliderMin = 1800;
const int _kYearSliderMax = 2100;

/// Fixed seed so every use case stands up in a known state.
final DateTime _kSeedDate = DateTime(2024, 12, 21, 1, 47, 22);

@widgetbook.UseCase(name: 'Playground', type: DatePicker)
Widget datePickerPlaygroundUseCase(BuildContext context) {
  final size = context.knobs.object.dropdown<PickerSize>(
    label: _kSizeKnob,
    options: PickerSize.values,
    initialOption: PickerSize.regular,
    labelBuilder: (value) => value.name,
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

  return _DatePickerHost(
    size: size,
    // The picker asserts minimumYear <= maximumYear; keep the knobs legal.
    minimumYear: minimumYear <= maximumYear ? minimumYear : maximumYear,
    maximumYear: maximumYear,
    textStyle: textColor == null ? null : TextStyle(color: textColor),
  );
}

@widgetbook.UseCase(name: 'Size Gallery', type: DatePicker)
Widget datePickerSizeGalleryUseCase(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      padding: _kFramePadding,
      child: Column(
        children: [
          for (final size in PickerSize.values) ...[
            Text(size.name, style: Theme.of(context).textTheme.labelLarge),
            DatePicker(
              size: size,
              initialDate: _kSeedDate,
              onDateChanged: (_) {},
            ),
            const SizedBox(height: _kGallerySpacing),
          ],
        ],
      ),
    ),
  );
}

/// Hosts a [DatePicker] and echoes the last emitted value beneath it.
///
/// [DatePicker] reads [DatePicker.initialDate] and its year range once in
/// `initState` and owns its own scroll controllers, so a knob change that only
/// rebuilds would leave the wheels out of sync. The picker is therefore keyed
/// on every structural knob, forcing a fresh `State` whenever one changes.
class _DatePickerHost extends StatefulWidget {
  const _DatePickerHost({
    required this.size,
    required this.minimumYear,
    required this.maximumYear,
    this.textStyle,
  });

  final PickerSize size;
  final int minimumYear;
  final int maximumYear;
  final TextStyle? textStyle;

  @override
  State<_DatePickerHost> createState() => _DatePickerHostState();
}

class _DatePickerHostState extends State<_DatePickerHost> {
  late DateTime _value = _kSeedDate;

  void _onDateChanged(DateTime date) => setState(() => _value = date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: _kFramePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DatePicker(
                key: ValueKey(
                  (widget.size, widget.minimumYear, widget.maximumYear),
                ),
                size: widget.size,
                initialDate: _kSeedDate,
                minimumYear: widget.minimumYear,
                maximumYear: widget.maximumYear,
                textStyle: widget.textStyle,
                onDateChanged: _onDateChanged,
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
