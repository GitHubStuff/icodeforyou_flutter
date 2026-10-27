// packages/sincewhen_screens/lib/src/widgets/timestamp_row.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sincewhen_screens/src/util/sincewhen_mini_constants.dart'
    show SinceWhenMiniDimensions;

/// {@template timestamp_row}
/// A labelled, read-only value row for the since-when-mini timestamp
/// column.
///
/// Renders [label] in the theme's `labelLarge` style above [value] in
/// `bodyLarge`. Purely presentational: no taps, no state, no
/// dependencies beyond the ambient [Theme].
/// {@endtemplate}
class TimestampRow extends StatelessWidget {
  /// {@macro timestamp_row}
  const TimestampRow({
    required this.label,
    required this.value,
    super.key,
  });

  /// The field name displayed above the value.
  final String label;

  /// The formatted value displayed beneath the label.
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelLarge),
        const Gap(SinceWhenMiniDimensions.labelValueGap),
        Text(value, style: textTheme.bodyLarge),
      ],
    );
  }
}
