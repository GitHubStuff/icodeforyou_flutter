// packages/sincewhen_screens/lib/src/widgets/event_timestamp_picker_sheet.dart

import 'package:datetime_pickers/datetime_pickers.dart'
    show FatPicker, PickerSize;
import 'package:flutter/material.dart';

/// {@template event_timestamp_picker_sheet}
/// Modal surface hosting a [FatPicker] with Cancel / Done affordances.
///
/// The picker is uncontrolled and emits on every wheel settle, so this
/// widget owns the pending selection and only hands it back when the
/// user confirms. Present it with [show]; the returned future completes
/// with the confirmed [DateTime], or `null` on Cancel / barrier dismiss.
/// {@endtemplate}
class EventTimestampPickerSheet extends StatefulWidget {
  /// {@macro event_timestamp_picker_sheet}
  const EventTimestampPickerSheet({
    required this.initialDateTime,
    super.key,
  });

  /// Label of the dismiss affordance.
  static const String cancelLabel = 'Cancel';

  /// Label of the confirm affordance.
  static const String doneLabel = 'Done';

  /// Wheel size preset. `extraSmall` is the package's own recommendation
  /// for menu-bar surfaces and keeps the full [FatPicker] under 240 px.
  static const PickerSize pickerSize = PickerSize.extraSmall;

  /// Vertical inset around the picker.
  static const double verticalPadding = 16;

  /// The instant the wheels open on.
  final DateTime initialDateTime;

  /// Presents the sheet and resolves with the confirmed instant, or
  /// `null` when dismissed without confirming.
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDateTime,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      builder: (_) => EventTimestampPickerSheet(
        initialDateTime: initialDateTime,
      ),
    );
  }

  @override
  State<EventTimestampPickerSheet> createState() =>
      _EventTimestampPickerSheetState();
}

class _EventTimestampPickerSheetState extends State<EventTimestampPickerSheet> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDateTime;
  }

  void _cancel() => Navigator.of(context).pop();

  void _confirm() => Navigator.of(context).pop(_selected);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _cancel,
                child: const Text(EventTimestampPickerSheet.cancelLabel),
              ),
              TextButton(
                onPressed: _confirm,
                child: const Text(EventTimestampPickerSheet.doneLabel),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: EventTimestampPickerSheet.verticalPadding,
            ),
            child: FatPicker(
              size: EventTimestampPickerSheet.pickerSize,
              showSeconds: false,
              initialDateTime: widget.initialDateTime,
              textStyle: TextStyle(color: theme.colorScheme.onSurface),
              // The picker emits on every wheel settle; hold the value
              // until Done hands it back. No rebuild needed.
              onDateTimeChanged: (dateTime) => _selected = dateTime,
            ),
          ),
        ],
      ),
    );
  }
}
