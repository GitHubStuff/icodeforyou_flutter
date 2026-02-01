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
  
  // Track current days in month for position calculations
  late int _currentDaysInMonth;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  /// Calculate days in a given month/year (duplicated from cubit for local use)
  static int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      final isLeap =
          (year % 400 == 0) || (year % 100 != 0 && year % 4 == 0);
      return isLeap ? 29 : 28;
    }
    const daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysPerMonth[month - 1];
  }

  void _initializeControllers() {
    final cubit = context.read<DatePickerCubit>();
    final state = cubit.state;

    // Year: 1900-2100 (201 years), no infinite scroll
    _yearController = FixedExtentScrollController(
      initialItem: state.year - 1900,
    );

    // Month: 1-12, infinite scroll
    // Offset must be divisible by 12 to preserve month mapping
    final monthOffset =
        (StyleConstants.infiniteScrollBuffer ~/ 2 ~/ 12) * 12;
    _monthController = FixedExtentScrollController(
      initialItem: (state.month - 1) + monthOffset,
    );

    // Day: finite with looping, simple 0-indexed position
    _currentDaysInMonth = _getDaysInMonth(state.year, state.month);
    _dayController = FixedExtentScrollController(
      initialItem: state.day - 1,
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

  /// Clamp day controller position to valid range BEFORE cubit update.
  /// This ensures the controller is at a valid position when the picker rebuilds.
  void _clampDayControllerBeforeUpdate(int newMaxDays) {
    if (!_dayController.hasClients) return;

    final currentPosition = _dayController.selectedItem;
    
    // Calculate the actual day (1-based) currently shown
    // With looping, we need modulo of current item count
    // Handle negative positions too
    int currentDayIndex = currentPosition % _currentDaysInMonth;
    if (currentDayIndex < 0) currentDayIndex += _currentDaysInMonth;
    final currentDay = currentDayIndex + 1; // 1-based day
    
    // Clamp day if it exceeds new month's days
    final targetDay = currentDay > newMaxDays ? newMaxDays : currentDay;
    
    // Set position to the target day (0-indexed)
    final targetPosition = targetDay - 1;
    
    // Jump to the correct position
    _dayController.jumpToItem(targetPosition);
    
    // Update our tracked days count
    _currentDaysInMonth = newMaxDays;
  }

  Widget _buildYearColumn() {
    return _ScrollingDatePickerColumn(
      controller: _yearController,
      isInfinite: false,
      itemCount: 201, // 1900-2100
      itemBuilder: (index) => (1900 + index).toString(),
      onSelectedItemChanged: (index) {
        _handleHapticFeedback();
        final cubit = context.read<DatePickerCubit>();
        final newYear = 1900 + index;

        // Calculate new max days BEFORE updating cubit
        final newMaxDays = _getDaysInMonth(newYear, cubit.state.month);
        _clampDayControllerBeforeUpdate(newMaxDays);

        cubit.updateYear(newYear);
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
        final cubit = context.read<DatePickerCubit>();

        // Calculate new max days BEFORE updating cubit
        final newMaxDays = _getDaysInMonth(cubit.state.year, monthIndex);
        _clampDayControllerBeforeUpdate(newMaxDays);

        cubit.updateMonth(monthIndex);
      },
      textStyle: widget.dateStyle,
    );
  }

  Widget _buildDayColumn() {
    return BlocBuilder<DatePickerCubit, DatePickerState>(
      // Only rebuild when month or year changes (which affects day count)
      buildWhen: (previous, current) =>
          previous.month != current.month || previous.year != current.year,
      builder: (context, state) {
        final currentMaxDays =
            context.read<DatePickerCubit>().daysInCurrentMonth;

        // Finite item count but with looping enabled
        // This gives us exactly the right days (1-28 for Feb, 1-31 for Jan)
        // but still allows scrolling from last day back to first
        return _ScrollingDatePickerColumn(
          controller: _dayController,
          isInfinite: false,
          itemCount: currentMaxDays,
          looping: true, // Enable looping so 31→1 works
          itemBuilder: (index) => (index + 1).toString(),
          onSelectedItemChanged: (index) {
            _handleHapticFeedback();
            // With looping, index can exceed itemCount, so use modulo
            final dayIndex = index % currentMaxDays;
            // dayIndex is 0-based, day is 1-based
            context.read<DatePickerCubit>().updateDay(dayIndex + 1);
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
