// packages/datetime_pickers/lib/src/fat_picker/fat_label_formatter.dart
import 'package:intl/intl.dart' show DateFormat;

/// Formats a [DateTime] as `21 Dec 2024 1:47:22 AM`, or without seconds
/// when they are hidden.
class FatLabelFormatter {
  /// Creates a [FatLabelFormatter].
  const FatLabelFormatter({required this.showSeconds});

  /// Whether seconds are included in the formatted output.
  final bool showSeconds;

  static final DateFormat _withSeconds = DateFormat('d MMM yyyy h:mm:ss a');
  static final DateFormat _withoutSeconds = DateFormat('d MMM yyyy h:mm a');

  /// Returns [dateTime] rendered as date and 12-hour time with AM/PM.
  String format(DateTime dateTime) =>
      (showSeconds ? _withSeconds : _withoutSeconds).format(dateTime);
}
