// lib/src/presentation/widgets/scrolling_time_picker_content.dart

part of 'scrolling_time_picker.dart';

class _ScrollingTimePickerContent extends StatefulWidget {
  final Size portraitSize;
  final Size landscapeSize;
  final Function(DateTime) onDateTimeChanged;
  final Color backgroundColor;
  final TextStyle? timeStyle;
  final DividerConfiguration dividerConfiguration;
  final FadeConfiguration fadeConfiguration;
  final bool showSeconds;
  final bool enableHaptics;
  final double borderRadius;

  const _ScrollingTimePickerContent({
    required this.portraitSize,
    required this.landscapeSize,
    required this.onDateTimeChanged,
    required this.backgroundColor,
    this.timeStyle,
    required this.dividerConfiguration,
    required this.fadeConfiguration,
    required this.showSeconds,
    required this.enableHaptics,
    required this.borderRadius,
  });

  @override
  State<_ScrollingTimePickerContent> createState() =>
      _ScrollingTimePickerContentState();
}

class _ScrollingTimePickerContentState
    extends State<_ScrollingTimePickerContent>
    with InfiniteScrollMixin, PickerTransformMixin {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;
  late FixedExtentScrollController _amPmController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final cubit = context.read<TimePickerCubit>();
    final state = cubit.state;

    _hourController = FixedExtentScrollController(
      initialItem: getHourScrollPosition(state.hour12),
    );

    _minuteController = FixedExtentScrollController(
      initialItem: getMinuteScrollPosition(state.minute),
    );

    _secondController = FixedExtentScrollController(
      initialItem: getSecondScrollPosition(state.second),
    );

    _amPmController = FixedExtentScrollController(
      initialItem: state.isAm ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _amPmController.dispose();
    super.dispose();
  }

  Size _getSize(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? widget.portraitSize
        : widget.landscapeSize;
  }

  void _handleHapticFeedback() {
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = _getSize(context);
    final totalColumns = widget.showSeconds ? 4 : 3;

    return BlocListener<TimePickerCubit, TimePickerState>(
      listener: (context, state) {
        if (!state.isScrolling) {
          widget.onDateTimeChanged(state.dateTime);
        }
      },
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Hour column
                Expanded(
                  child: buildTransformedColumn(
                    columnIndex: 0,
                    totalColumns: totalColumns,
                    child: _ScrollingTimePickerColumn(
                      controller: _hourController,
                      isInfinite: true,
                      itemBuilder: (index) => formatHour(
                        getHourValue(index),
                      ),
                      onSelectedItemChanged: (index) {
                        _handleHapticFeedback();
                        final hour = getHourValue(index);
                        final isAm = context.read<TimePickerCubit>().state.isAm;
                        context.read<TimePickerCubit>().updateHour(hour, isAm);
                      },
                      textStyle: widget.timeStyle,
                    ),
                  ),
                ),
                // Minute column
                Expanded(
                  child: buildTransformedColumn(
                    columnIndex: 1,
                    totalColumns: totalColumns,
                    child: _ScrollingTimePickerColumn(
                      controller: _minuteController,
                      isInfinite: true,
                      itemBuilder: (index) => formatMinute(
                        getMinuteValue(index),
                      ),
                      onSelectedItemChanged: (index) {
                        _handleHapticFeedback();
                        final minute = getMinuteValue(index);
                        context.read<TimePickerCubit>().updateMinute(minute);
                      },
                      textStyle: widget.timeStyle,
                    ),
                  ),
                ),
                // Seconds column (optional)
                if (widget.showSeconds)
                  Expanded(
                    child: buildTransformedColumn(
                      columnIndex: 2,
                      totalColumns: totalColumns,
                      child: _ScrollingTimePickerColumn(
                        controller: _secondController,
                        isInfinite: true,
                        itemBuilder: (index) => formatSecond(
                          getSecondValue(index),
                        ),
                        onSelectedItemChanged: (index) {
                          _handleHapticFeedback();
                          final second = getSecondValue(index);
                          context.read<TimePickerCubit>().updateSecond(second);
                        },
                        textStyle: widget.timeStyle,
                      ),
                    ),
                  ),
                // AM/PM column
                Expanded(
                  child: buildTransformedColumn(
                    columnIndex: totalColumns - 1,
                    totalColumns: totalColumns,
                    child: _ScrollingTimePickerColumn(
                      controller: _amPmController,
                      isInfinite: false,
                      itemCount: 2,
                      itemBuilder: (index) => index == 0 ? 'AM' : 'PM',
                      onSelectedItemChanged: (index) {
                        _handleHapticFeedback();
                        context.read<TimePickerCubit>().updateAmPm(index == 0);
                      },
                      textStyle: widget.timeStyle,
                    ),
                  ),
                ),
              ],
            ),
            // Dividers
            _buildDividers(size),
          ],
        ),
      ),
    );
  }

  Widget _buildDividers(Size size) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: widget.dividerConfiguration.thickness,
              margin: EdgeInsets.only(
                left: widget.dividerConfiguration.indent,
                right: widget.dividerConfiguration.endIndent,
              ),
              decoration: BoxDecoration(
                color: widget.dividerConfiguration.effectiveColor,
                boxShadow: widget.dividerConfiguration.hasEffect
                    ? [
                        BoxShadow(
                          color: widget.dividerConfiguration.effectiveColor,
                          blurRadius: widget.dividerConfiguration.blurRadius,
                          spreadRadius:
                              widget.dividerConfiguration.spreadRadius,
                          blurStyle: widget.dividerConfiguration.blurStyle ??
                              BlurStyle.normal,
                        ),
                      ]
                    : null,
              ),
            ),
            SizedBox(height: DimensionConstants.itemExtent),
            Container(
              height: widget.dividerConfiguration.thickness,
              margin: EdgeInsets.only(
                left: widget.dividerConfiguration.indent,
                right: widget.dividerConfiguration.endIndent,
              ),
              decoration: BoxDecoration(
                color: widget.dividerConfiguration.effectiveColor,
                boxShadow: widget.dividerConfiguration.hasEffect
                    ? [
                        BoxShadow(
                          color: widget.dividerConfiguration.effectiveColor,
                          blurRadius: widget.dividerConfiguration.blurRadius,
                          spreadRadius:
                              widget.dividerConfiguration.spreadRadius,
                          blurStyle: widget.dividerConfiguration.blurStyle ??
                              BlurStyle.normal,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
