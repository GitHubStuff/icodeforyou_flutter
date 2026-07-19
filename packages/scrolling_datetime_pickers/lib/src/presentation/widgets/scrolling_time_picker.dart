// lib/src/presentation/widgets/scrolling_time_picker.dart

import 'dart:async';

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

/// An Apple-style infinite-scroll time picker widget.
///
/// Renders hour, minute, and optionally seconds columns inside a
/// [BlocProvider]-scoped [TimePickerCubit]. The picker adapts its size to
/// portrait and landscape orientations automatically.
class ScrollingTimePicker extends StatelessWidget {
  /// Creates a [ScrollingTimePicker].
  ///
  /// [onDateTimeChanged] is called whenever the user scrolls any column to a
  /// new value. [initialDateTime] is normalised before being passed to
  /// [TimePickerCubit] — only the time components are preserved; the date is
  /// fixed to 1 January of the current year and seconds are zeroed. When
  /// [initialDateTime] is `null` the cubit defaults to the current time.
  ///
  /// [dividerConfiguration] and [fadeConfiguration] fall back to their
  /// respective default constructors when not provided.
  const ScrollingTimePicker({
    required this.onDateTimeChanged,
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
    this.backgroundColor = StyleConstants.defaultBackgroundColor,
    this.timeStyle,
    DividerConfiguration? dividerConfiguration,
    FadeConfiguration? fadeConfiguration,
    this.showSeconds = false,
    this.enableHaptics = true,
    this.borderRadius = 0.0,
  }) : dividerConfiguration =
           dividerConfiguration ?? const DividerConfiguration(),
       fadeConfiguration = fadeConfiguration ?? const FadeConfiguration();

  /// Preferred size of the picker in portrait orientation.
  ///
  /// Defaults to [DimensionConstants.defaultPortraitWidth]
  /// [DimensionConstants.defaultPortraitHeight].
  final Size portraitSize;

  /// Preferred size of the picker in landscape orientation.
  ///
  /// Defaults to [DimensionConstants.defaultLandscapeWidth] ×
  /// [DimensionConstants.defaultLandscapeHeight].
  final Size landscapeSize;

  /// The date and time used to seed the picker's initial scroll position.
  ///
  /// Only the hour and minute components are used; the date is discarded and
  /// seconds are zeroed during normalisation. When `null` the picker opens
  /// at the current time.
  final DateTime? initialDateTime;

  /// Called with the full [DateTime] whenever the selected time changes.
  ///
  /// The date portion of the emitted value is always 1 January of the current
  /// year — consumers interested only in time should read the hour, minute,
  /// and second components.
  final void Function(DateTime) onDateTimeChanged;

  /// Background color of the picker drum container.
  ///
  /// Defaults to [StyleConstants.defaultBackgroundColor].
  final Color backgroundColor;

  /// Text style applied to each item in the time scroll columns.
  ///
  /// When `null` the picker uses its default item style.
  final TextStyle? timeStyle;

  /// Visual configuration for the selection divider lines.
  ///
  /// Defaults to [DividerConfiguration] with its default constructor values.
  final DividerConfiguration dividerConfiguration;

  /// Visual configuration for the top and bottom fade overlays.
  ///
  /// Defaults to [FadeConfiguration] with its default constructor values.
  final FadeConfiguration fadeConfiguration;

  /// Whether the seconds scroll column is visible.
  ///
  /// Defaults to `false`. When `true` a third column is rendered alongside
  /// the hour and minute columns.
  final bool showSeconds;

  /// Whether haptic feedback fires on scroll and item-selection events.
  ///
  /// Defaults to `true`.
  final bool enableHaptics;

  /// Corner radius of the picker drum container in logical pixels.
  ///
  /// Defaults to `0.0` (square corners).
  final double borderRadius;

  /// Returns a normalised [DateTime] suitable for [TimePickerCubit].
  ///
  /// When [initialDateTime] is non-null its hour and minute are preserved on
  /// 1 January of the current year with seconds zeroed. When `null` this
  /// method returns `null`, allowing the cubit to apply its own default
  /// (current time on 1 January of the current year).
  DateTime? _normalizeForTimePicker() {
    final now = DateTime.now();
    if (initialDateTime != null) {
      return DateTime(
        now.year,
        1,
        1,
        initialDateTime!.hour,
        initialDateTime!.minute,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TimePickerCubit(initialDateTime: _normalizeForTimePicker()),
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
