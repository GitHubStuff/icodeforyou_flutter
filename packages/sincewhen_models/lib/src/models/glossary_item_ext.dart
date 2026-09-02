// packages/sincewhen_models/lib/src/models/glossary_item_ext.dart
import 'package:extensions/int/int_ext.dart' show IntExt;
import 'package:flutter/widgets.dart' show Color;
import 'package:sincewhen_models/sincewhen_models.dart';

/// Extensions to help use color as a Color class and not an int, and
/// create'd'Timestamp as a DataTime
extension GlossaryItemExt on GlossaryItem {
  /// Get the ARGB as a color
  Color get color => colorArgb.toColor();

  /// Gets the milliseconds since epoch as a DateTime
  DateTime get createTimeStamp => createdTimestamp.toUtc();
}
