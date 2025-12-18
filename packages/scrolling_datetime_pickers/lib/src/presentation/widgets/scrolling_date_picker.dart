// lib/src/presentation/widgets/scrolling_date_picker.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/dimensions_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/style_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/models/divider_configuration.dart';
import 'package:scrolling_datetime_pickers/src/core/models/fade_configuration.dart';
import 'package:scrolling_datetime_pickers/src/presentation/cubits/date_picker/date_picker_cubit.dart';

part 'scrolling_date_picker_content.dart';
part 'scrolling_date_picker_column.dart';

/// Apple-style scrolling date picker widget
class ScrollingDatePicker extends StatelessWidget {
  /// Size for portrait orientation
  final Size portraitSize;

  /// Size for landscape orientation
  final Size landscapeSize;

  /// Initial date value
  final DateTime? initialDate;

  /// Callback when date changes
  final Function(DateTime) onDateChanged;

  /// Background color of the picker
  final Color backgroundColor;

  /// Text style for picker items
  final TextStyle? dateStyle;

  /// Configuration for dividers
  final DividerConfiguration dividerConfiguration;

  /// Configuration for fade effects
  final FadeConfiguration fadeConfiguration;

  /// Whether to show day-month-year (true) or year-month-day (false)
  final bool dayAscending;

  /// Whether to enable haptic feedback
  final bool enableHaptics;

  /// Border radius for the picker container
  final double borderRadius;

  const ScrollingDatePicker({
    super.key,
    this.portraitSize = const Size(
      DimensionConstants.defaultPortraitWidth,
      DimensionConstants.defaultPortraitHeight,
    ),
    this.landscapeSize = const Size(
      DimensionConstants.defaultLandscapeWidth,
      DimensionConstants.defaultLandscapeHeight,
    ),
    this.initialDate,
    required this.onDateChanged,
    this.backgroundColor = StyleConstants.defaultBackgroundColor,
    this.dateStyle,
    DividerConfiguration? dividerConfiguration,
    FadeConfiguration? fadeConfiguration,
    this.dayAscending = true,
    this.enableHaptics = true,
    this.borderRadius = 0.0,
  })  : dividerConfiguration =
            dividerConfiguration ?? const DividerConfiguration(),
        fadeConfiguration = fadeConfiguration ?? const FadeConfiguration();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DatePickerCubit(
        initialDate: initialDate,
      ),
      child: _ScrollingDatePickerContent(
        portraitSize: portraitSize,
        landscapeSize: landscapeSize,
        onDateChanged: onDateChanged,
        backgroundColor: backgroundColor,
        dateStyle: dateStyle,
        dividerConfiguration: dividerConfiguration,
        fadeConfiguration: fadeConfiguration,
        dayAscending: dayAscending,
        enableHaptics: enableHaptics,
        borderRadius: borderRadius,
      ),
    );
  }
}
