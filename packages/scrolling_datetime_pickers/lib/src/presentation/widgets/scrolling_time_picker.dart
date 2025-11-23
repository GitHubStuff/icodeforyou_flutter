// lib/src/presentation/widgets/scrolling_time_picker.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/dimensions_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/style_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/mixins/infinite_scroll_mixin.dart';
import 'package:scrolling_datetime_pickers/src/core/mixins/picker_transform_mixin.dart';
import 'package:scrolling_datetime_pickers/src/core/models/divider_configuration.dart';
import 'package:scrolling_datetime_pickers/src/core/models/fade_configuration.dart';
import 'package:scrolling_datetime_pickers/src/presentation/cubits/time_picker/time_picker_cubit.dart';

part 'scrolling_time_picker_column.dart';
part 'scrolling_time_picker_content.dart';

/// Apple-style scrolling time picker widget
class ScrollingTimePicker extends StatelessWidget {
  /// Size for portrait orientation
  final Size portraitSize;

  /// Size for landscape orientation
  final Size landscapeSize;

  /// Initial date time value
  final DateTime? initialDateTime;

  /// Callback when time changes
  final Function(DateTime) onDateTimeChanged;

  /// Background color of the picker
  final Color backgroundColor;

  /// Text style for picker items
  final TextStyle? timeStyle;

  /// Configuration for dividers
  final DividerConfiguration dividerConfiguration;

  /// Configuration for fade effects
  final FadeConfiguration fadeConfiguration;

  /// Whether to show seconds column
  final bool showSeconds;

  /// Whether to enable haptic feedback
  final bool enableHaptics;

  /// Border radius for the picker container
  final double borderRadius;

  const ScrollingTimePicker({
    super.key,
    this.portraitSize = const Size(
      DimensionConstants.defaultPortraitWidth,
      DimensionConstants.defaultPortraitHeight,
    ),
    this.landscapeSize = const Size(
      DimensionConstants.defaultLandscapeWidth,
      DimensionConstants.defaultLandscapeHeight,
    ),
    this.initialDateTime,
    required this.onDateTimeChanged,
    this.backgroundColor = StyleConstants.defaultBackgroundColor,
    this.timeStyle,
    DividerConfiguration? dividerConfiguration,
    FadeConfiguration? fadeConfiguration,
    this.showSeconds = false,
    this.enableHaptics = true,
    this.borderRadius = 0.0,
  })  : dividerConfiguration =
            dividerConfiguration ?? const DividerConfiguration(),
        fadeConfiguration = fadeConfiguration ?? const FadeConfiguration();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimePickerCubit(
        initialDateTime: initialDateTime,
      ),
      child: _ScrollingTimePickerContent(
        portraitSize: portraitSize,
        landscapeSize: landscapeSize,
        onDateTimeChanged: onDateTimeChanged,
        backgroundColor: backgroundColor,
        timeStyle: timeStyle,
        dividerConfiguration: dividerConfiguration,
        fadeConfiguration: fadeConfiguration,
        showSeconds: showSeconds,
        enableHaptics: enableHaptics,
        borderRadius: borderRadius,
      ),
    );
  }
}
