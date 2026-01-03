// lib/src/presentation/widgets/datetime_popover/_datetime_popover_route.dart

part of 'datetime_picker_popover.dart';

class _DateTimePopoverRoute extends PopupRoute<DateTime?> {
  _DateTimePopoverRoute({
    required this.anchorPosition,
    required this.anchorSize,
    required this.initialDateTime,
    required this.option,
    required this.dateFormat,
    required this.timeFormat,
    required this.showSeconds,
    required this.popoverBackgroundColor,
    required this.dateButtonColor,
    required this.timeButtonColor,
    required this.pickerBackgroundColor,
    required this.dateButtonTextStyle,
    required this.timeButtonTextStyle,
    required this.headerDateTextStyle,
    required this.headerTimeTextStyle,
    required this.dateStyle,
    required this.timeStyle,
    required this.confirmWidget,
    required this.confirmButtonColor,
    required this.confirmButtonText,
    required this.confirmButtonTextStyle,
    required this.portraitPickerSize,
    required this.landscapePickerSize,
    required this.dividerConfiguration,
    required this.fadeConfiguration,
    required this.enableHaptics,
    required this.dayAscending,
  });

  final Offset anchorPosition;
  final Size anchorSize;
  final DateTime initialDateTime;
  final DateTimeOption option;
  final String dateFormat;
  final String timeFormat;
  final bool showSeconds;
  final Color popoverBackgroundColor;
  final Color dateButtonColor;
  final Color timeButtonColor;
  final Color? pickerBackgroundColor;
  final TextStyle? dateButtonTextStyle;
  final TextStyle? timeButtonTextStyle;
  final TextStyle? headerDateTextStyle;
  final TextStyle? headerTimeTextStyle;
  final TextStyle? dateStyle;
  final TextStyle? timeStyle;
  final Widget? confirmWidget;
  final Color confirmButtonColor;
  final String confirmButtonText;
  final TextStyle? confirmButtonTextStyle;
  final Size? portraitPickerSize;
  final Size? landscapePickerSize;
  final DividerConfiguration? dividerConfiguration;
  final FadeConfiguration? fadeConfiguration;
  final bool enableHaptics;
  final bool dayAscending;

  @override
  Color? get barrierColor => PopoverConstants.barrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss date time picker';

  @override
  Duration get transitionDuration => PopoverConstants.popoverFadeDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _DateTimePopoverContent(
      anchorPosition: anchorPosition,
      anchorSize: anchorSize,
      initialDateTime: initialDateTime,
      option: option,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
      showSeconds: showSeconds,
      popoverBackgroundColor: popoverBackgroundColor,
      dateButtonColor: dateButtonColor,
      timeButtonColor: timeButtonColor,
      pickerBackgroundColor: pickerBackgroundColor,
      dateButtonTextStyle: dateButtonTextStyle,
      timeButtonTextStyle: timeButtonTextStyle,
      headerDateTextStyle: headerDateTextStyle,
      headerTimeTextStyle: headerTimeTextStyle,
      dateStyle: dateStyle,
      timeStyle: timeStyle,
      confirmWidget: confirmWidget,
      confirmButtonColor: confirmButtonColor,
      confirmButtonText: confirmButtonText,
      confirmButtonTextStyle: confirmButtonTextStyle,
      portraitPickerSize: portraitPickerSize,
      landscapePickerSize: landscapePickerSize,
      dividerConfiguration: dividerConfiguration,
      fadeConfiguration: fadeConfiguration,
      enableHaptics: enableHaptics,
      dayAscending: dayAscending,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: PopoverConstants.popoverFadeCurve,
      ),
      child: child,
    );
  }
}
