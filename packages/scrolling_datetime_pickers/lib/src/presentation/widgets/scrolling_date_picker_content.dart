// lib/src/presentation/widgets/scrolling_date_picker_content.dart

part of 'scrolling_date_picker.dart';

class _ScrollingDatePickerContent extends StatefulWidget {
  final Size portraitSize;
  final Size landscapeSize;
  final Function(DateTime) onDateChanged;
  final Color backgroundColor;
  final TextStyle? dateStyle;
  final DividerConfiguration dividerConfiguration;
  final FadeConfiguration fadeConfiguration;
  final bool dayAscending;
  final bool enableHaptics;
  final double borderRadius;

  const _ScrollingDatePickerContent({
    required this.portraitSize,
    required this.landscapeSize,
    required this.onDateChanged,
    required this.backgroundColor,
    this.dateStyle,
    required this.dividerConfiguration,
    required this.fadeConfiguration,
    required this.dayAscending,
    required this.enableHaptics,
    required this.borderRadius,
  });

  @override
  State<_ScrollingDatePickerContent> createState() =>
      _ScrollingDatePickerContentState();
}

class _ScrollingDatePickerContentState
    extends State<_ScrollingDatePickerContent> {
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final cubit = context.read<DatePickerCubit>();
    final state = cubit.state;

    // Year: 1900-2100 (201 years), no infinite scroll
    _yearController = FixedExtentScrollController(
      initialItem: state.year - 1900,
    );

    // Month: 1-12, infinite scroll
    _monthController = FixedExtentScrollController(
      initialItem:
          (state.month - 1) + (StyleConstants.infiniteScrollBuffer ~/ 2) * 12,
    );

    // Day: 1-31 max, infinite scroll
    _dayController = FixedExtentScrollController(
      initialItem:
          (state.day - 1) + (StyleConstants.infiniteScrollBuffer ~/ 2) * 31,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ScrollingDatePickerContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dayAscending != widget.dayAscending) {
      setState(() {});
    }
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

  Widget _buildYearColumn() {
    return _ScrollingDatePickerColumn(
      controller: _yearController,
      isInfinite: false,
      itemCount: 201, // 1900-2100
      itemBuilder: (index) => (1900 + index).toString(),
      onSelectedItemChanged: (index) {
        _handleHapticFeedback();
        context.read<DatePickerCubit>().updateYear(1900 + index);
      },
      textStyle: widget.dateStyle,
    );
  }

  Widget _buildMonthColumn() {
    return _ScrollingDatePickerColumn(
      controller: _monthController,
      isInfinite: true,
      itemBuilder: (index) {
        final monthIndex = (index % 12) + 1;
        final tempDate = DateTime(2024, monthIndex);
        return DateFormat('MMM').format(tempDate);
      },
      onSelectedItemChanged: (index) {
        _handleHapticFeedback();
        final monthIndex = (index % 12) + 1;
        context.read<DatePickerCubit>().updateMonth(monthIndex);
      },
      textStyle: widget.dateStyle,
    );
  }

  Widget _buildDayColumn() {
    return BlocBuilder<DatePickerCubit, DatePickerState>(
      builder: (context, state) {
        // Rebuild when days in month changes
        final currentMaxDays =
            context.read<DatePickerCubit>().daysInCurrentMonth;

        return _ScrollingDatePickerColumn(
          controller: _dayController,
          isInfinite: true,
          itemBuilder: (index) {
            final dayIndex = (index % 31) + 1;
            if (dayIndex > currentMaxDays) {
              return '';
            }
            return dayIndex.toString();
          },
          onSelectedItemChanged: (index) {
            _handleHapticFeedback();
            final dayIndex = (index % 31) + 1;
            if (dayIndex <= currentMaxDays) {
              context.read<DatePickerCubit>().updateDay(dayIndex);
            }
          },
          textStyle: widget.dateStyle,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = _getSize(context);

    // Build columns in order based on dayAscending
    final columns = widget.dayAscending
        ? [_buildDayColumn(), _buildMonthColumn(), _buildYearColumn()]
        : [_buildYearColumn(), _buildMonthColumn(), _buildDayColumn()];

    return BlocListener<DatePickerCubit, DatePickerState>(
      listener: (context, state) {
        if (!state.isScrolling) {
          widget.onDateChanged(state.date);
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
              children:
                  columns.map((column) => Expanded(child: column)).toList(),
            ),
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
