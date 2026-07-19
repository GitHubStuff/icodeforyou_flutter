// lib/src/presentation/widgets/datetime_popover/_datetime_popover_content.dart

part of 'datetime_picker_popover.dart';

class _DateTimePopoverContent extends StatefulWidget {
  const _DateTimePopoverContent({
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
  State<_DateTimePopoverContent> createState() =>
      _DateTimePopoverContentState();
}

class _DateTimePopoverContentState extends State<_DateTimePopoverContent> {
  late DateTime _currentDateTime;
  late _DateTimeTab _activeTab;

  @override
  void initState() {
    super.initState();
    _currentDateTime = widget.initialDateTime;
    _activeTab = widget.option == DateTimeOption.time
        ? _DateTimeTab.time
        : _DateTimeTab.date;
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _currentDateTime = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
        _currentDateTime.hour,
        _currentDateTime.minute,
        _currentDateTime.second,
      );
    });
  }

  void _onTimeChanged(DateTime newTime) {
    setState(() {
      _currentDateTime = DateTime(
        _currentDateTime.year,
        _currentDateTime.month,
        _currentDateTime.day,
        newTime.hour,
        newTime.minute,
        newTime.second,
      );
    });
  }

  void _onTabChanged(_DateTimeTab tab) {
    setState(() => _activeTab = tab);
  }

  void _onConfirm() {
    Navigator.of(context).pop(_currentDateTime);
  }

  FadeConfiguration _effectiveFadeConfiguration() {
    if (widget.fadeConfiguration != null) return widget.fadeConfiguration!;
    final bgColor =
        widget.pickerBackgroundColor ?? widget.popoverBackgroundColor;
    return FadeConfiguration.forBackground(bgColor);
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    final pickerSize = isPortrait
        ? (widget.portraitPickerSize ?? const Size(280, 200))
        : (widget.landscapePickerSize ?? const Size(320, 180));

    final showTabBar = widget.option == DateTimeOption.dateTime;

    return Stack(
      children: [
        Positioned(
          left: _calculateLeft(context, pickerSize.width),
          top: _calculateTop(context, pickerSize.height, showTabBar),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: pickerSize.width,
              decoration: BoxDecoration(
                color: widget.popoverBackgroundColor,
                borderRadius: BorderRadius.circular(
                  PopoverConstants.popoverBorderRadius,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DateTimePopoverHeader(
                    currentDateTime: _currentDateTime,
                    dateFormat: widget.dateFormat,
                    timeFormat: widget.timeFormat,
                    showSeconds: widget.showSeconds,
                    headerDateTextStyle: widget.headerDateTextStyle,
                    headerTimeTextStyle: widget.headerTimeTextStyle,
                    confirmWidget: widget.confirmWidget,
                    confirmButtonColor: widget.confirmButtonColor,
                    confirmButtonText: widget.confirmButtonText,
                    confirmButtonTextStyle: widget.confirmButtonTextStyle,
                    onConfirm: _onConfirm,
                  ),
                  if (showTabBar)
                    _DateTimePopoverTabBar(
                      activeTab: _activeTab,
                      dateButtonColor: widget.dateButtonColor,
                      timeButtonColor: widget.timeButtonColor,
                      dateButtonTextStyle: widget.dateButtonTextStyle,
                      timeButtonTextStyle: widget.timeButtonTextStyle,
                      onTabChanged: _onTabChanged,
                    ),
                  _DateTimePopoverBody(
                    activeTab: _activeTab,
                    option: widget.option,
                    currentDateTime: _currentDateTime,
                    pickerSize: pickerSize,
                    pickerBackgroundColor: widget.pickerBackgroundColor,
                    dateStyle: widget.dateStyle,
                    timeStyle: widget.timeStyle,
                    dividerConfiguration: widget.dividerConfiguration,
                    fadeConfiguration: _effectiveFadeConfiguration(),
                    enableHaptics: widget.enableHaptics,
                    dayAscending: widget.dayAscending,
                    showSeconds: widget.showSeconds,
                    onDateChanged: _onDateChanged,
                    onTimeChanged: _onTimeChanged,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateLeft(BuildContext context, double popoverWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    final anchorCenterX =
        widget.anchorPosition.dx + (widget.anchorSize.width / 2);
    var left = anchorCenterX - (popoverWidth / 2);

    if (left < PopoverConstants.popoverScreenPadding) {
      left = PopoverConstants.popoverScreenPadding;
    } else if (left + popoverWidth >
        screenWidth - PopoverConstants.popoverScreenPadding) {
      left = screenWidth - popoverWidth - PopoverConstants.popoverScreenPadding;
    }

    return left;
  }

  double _calculateTop(
    BuildContext context,
    double pickerHeight,
    bool showTabBar,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final anchorBottom = widget.anchorPosition.dy + widget.anchorSize.height;
    final anchorTop = widget.anchorPosition.dy;

    final tabBarHeight = showTabBar ? PopoverConstants.tabBarHeight : 0.0;
    const headerHeight =
        PopoverConstants.headerPadding * 2 +
        PopoverConstants.headerFontSize * 2 +
        8.0;
    final popoverHeight = headerHeight + tabBarHeight + pickerHeight;

    var top = anchorBottom + PopoverConstants.popoverScreenPadding;

    final spaceBelow =
        screenHeight - anchorBottom - PopoverConstants.popoverScreenPadding;
    final spaceAbove = anchorTop - PopoverConstants.popoverScreenPadding;

    if (spaceBelow < popoverHeight && spaceAbove > spaceBelow) {
      top = anchorTop - popoverHeight - PopoverConstants.popoverScreenPadding;
    }

    if (top < PopoverConstants.popoverScreenPadding) {
      top = PopoverConstants.popoverScreenPadding;
    } else if (top + popoverHeight >
        screenHeight - PopoverConstants.popoverScreenPadding) {
      top =
          screenHeight - popoverHeight - PopoverConstants.popoverScreenPadding;
    }

    return top;
  }
}
