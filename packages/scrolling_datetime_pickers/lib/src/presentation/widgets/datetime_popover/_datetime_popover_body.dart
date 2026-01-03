// lib/src/presentation/widgets/datetime_popover/_datetime_popover_body.dart

part of 'datetime_picker_popover.dart';

class _DateTimePopoverBody extends StatelessWidget {
  const _DateTimePopoverBody({
    required this.activeTab,
    required this.option,
    required this.currentDateTime,
    required this.pickerSize,
    required this.pickerBackgroundColor,
    required this.dateStyle,
    required this.timeStyle,
    required this.dividerConfiguration,
    required this.fadeConfiguration,
    required this.enableHaptics,
    required this.dayAscending,
    required this.showSeconds,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  final _DateTimeTab activeTab;
  final DateTimeOption option;
  final DateTime currentDateTime;
  final Size pickerSize;
  final Color? pickerBackgroundColor;
  final TextStyle? dateStyle;
  final TextStyle? timeStyle;
  final DividerConfiguration? dividerConfiguration;
  final FadeConfiguration fadeConfiguration;
  final bool enableHaptics;
  final bool dayAscending;
  final bool showSeconds;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(PopoverConstants.popoverBorderRadius),
        bottomRight: Radius.circular(PopoverConstants.popoverBorderRadius),
      ),
      child: _buildPickerContent(),
    );
  }

  Widget _buildPickerContent() {
    switch (option) {
      case DateTimeOption.dateTime:
        return _buildCrossFadePickers();
      case DateTimeOption.date:
        return _buildDatePicker();
      case DateTimeOption.time:
        return _buildTimePicker();
    }
  }

  Widget _buildCrossFadePickers() {
    return AnimatedCrossFade(
      duration: PopoverConstants.crossfadeDuration,
      firstCurve: PopoverConstants.crossfadeCurve,
      secondCurve: PopoverConstants.crossfadeCurve,
      sizeCurve: PopoverConstants.crossfadeCurve,
      crossFadeState: activeTab == _DateTimeTab.date
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: _buildDatePicker(),
      secondChild: _buildTimePicker(),
    );
  }

  Widget _buildDatePicker() {
    return SizedBox(
      width: pickerSize.width,
      height: pickerSize.height,
      child: ScrollingDatePicker(
        portraitSize: pickerSize,
        landscapeSize: pickerSize,
        initialDate: currentDateTime,
        onDateChanged: onDateChanged,
        backgroundColor: pickerBackgroundColor ?? Colors.transparent,
        dateStyle: dateStyle,
        dividerConfiguration:
            dividerConfiguration ?? const DividerConfiguration(),
        fadeConfiguration: fadeConfiguration,
        dayAscending: dayAscending,
        enableHaptics: enableHaptics,
      ),
    );
  }

  Widget _buildTimePicker() {
    return SizedBox(
      width: pickerSize.width,
      height: pickerSize.height,
      child: ScrollingTimePicker(
        portraitSize: pickerSize,
        landscapeSize: pickerSize,
        initialDateTime: currentDateTime,
        onDateTimeChanged: onTimeChanged,
        backgroundColor: pickerBackgroundColor ?? Colors.transparent,
        timeStyle: timeStyle,
        dividerConfiguration:
            dividerConfiguration ?? const DividerConfiguration(),
        fadeConfiguration: fadeConfiguration,
        showSeconds: showSeconds,
        enableHaptics: enableHaptics,
      ),
    );
  }
}
