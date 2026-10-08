// packages/datetime_popover_pickers/lib/src/date/date_picker.dart
import 'dart:math' show max, min;

import 'package:datetime_popover_pickers/src/picker_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' show DateFormat;

/// Refined date picker with day, abbreviated-month and year wheels, composed
/// from [CupertinoPicker] columns sharing one selection overlay. Row geometry
/// derives from [size]; column widths derive from the measured width of each
/// column's widest label.
class DatePicker extends StatefulWidget {
  /// Constructor
  const DatePicker({
    required this.onDateChanged,
    required this.size,
    this.initialDate,
    this.minimumYear = defaultMinimumYear,
    this.maximumYear = defaultMaximumYear,
    this.textStyle,
    super.key,
  }) : assert(minimumYear <= maximumYear, 'minimumYear must be <= maximumYear');

  /// Start year for picker if one isn't specified
  static const int defaultMinimumYear = 1800;

  /// Max year for picker if one isn't specified
  static const int defaultMaximumYear = 2100;

  /// The initial date; its time-of-day portion is preserved in emitted values
  final DateTime? initialDate;

  /// Size preset controlling font size, row height, and column padding
  final PickerSize size;

  /// First year on the year wheel (inclusive)
  final int minimumYear;

  /// Last year on the year wheel (inclusive)
  final int maximumYear;

  /// Optional style overrides for colour, weight or family. Font size is
  /// always taken from [size] and cannot be overridden here.
  final TextStyle? textStyle;

  /// Called with the updated date whenever any wheel changes
  final void Function(DateTime) onDateChanged;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  static const int _monthsPerYear = 12;
  static const int _maxDaysPerMonth = 31;
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Widest digit samples in virtually every Latin typeface.
  static const String _widestTwoDigits = '88';
  static const String _widestFourDigits = '8888';

  late DateTime _currentDate;
  late int _day;
  late int _month;
  late int _year;

  late final FixedExtentScrollController _dayController;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _yearController;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? DateTime.now();
    _day = _currentDate.day;
    _month = _currentDate.month;
    _year = _currentDate.year.clamp(widget.minimumYear, widget.maximumYear);

    _dayController = FixedExtentScrollController(initialItem: _day - 1);
    _monthController = FixedExtentScrollController(initialItem: _month - 1);
    _yearController = FixedExtentScrollController(
      initialItem: _year - widget.minimumYear,
    );
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int get _yearCount => widget.maximumYear - widget.minimumYear + 1;

  static int _daysIn({required int year, required int month}) =>
      DateTime(year, month + 1, 0).day;

  int get _daysInSelectedMonth => _daysIn(year: _year, month: _month);

  int get _clampedDay => min(_day, _daysInSelectedMonth);

  void _emit() {
    setState(() {
      _currentDate = DateTime(
        _year,
        _month,
        _clampedDay,
        _currentDate.hour,
        _currentDate.minute,
        _currentDate.second,
      );
    });
    widget.onDateChanged(_currentDate);
  }

  void _snapDayIfInvalid() {
    final lastValid = _daysInSelectedMonth;
    if (_day <= lastValid) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _dayController.animateToItem(
        lastValid - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _onDayChanged(int index) {
    _day = index + 1;
    _emit();
  }

  void _onMonthChanged(int index) {
    _month = index + 1;
    _snapDayIfInvalid();
    _emit();
  }

  void _onYearChanged(int index) {
    _year = widget.minimumYear + index;
    _snapDayIfInvalid();
    _emit();
  }

  TextStyle _resolveTextStyle(BuildContext context) =>
      CupertinoTheme.of(context).textTheme.pickerTextStyle
          .merge(widget.textStyle)
          .merge(widget.size.textStyle);

  static double _measure(
    BuildContext context,
    String text,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  double _columnWidth(BuildContext context, TextStyle style, String widest) =>
      widget.size.columnWidthFor(_measure(context, widest, style));

  Widget _column({
    required FixedExtentScrollController controller,
    required int itemCount,
    required Widget Function(int index) item,
    required ValueChanged<int> onChanged,
    required double width,
    bool looping = true,
  }) => SizedBox(
    width: width,
    child: CupertinoPicker(
      scrollController: controller,
      itemExtent: widget.size.itemExtent,
      looping: looping,
      selectionOverlay: null,
      onSelectedItemChanged: onChanged,
      children: List<Widget>.generate(itemCount, item),
    ),
  );

  Widget _dayItem(int index, TextStyle style) {
    final day = index + 1;
    final valid = day <= _daysInSelectedMonth;
    return Center(
      child: Text(
        '$day',
        style: valid
            ? style
            : style.copyWith(color: CupertinoColors.inactiveGray),
      ),
    );
  }

  List<Widget> _columns(BuildContext context, TextStyle style) {
    final dayWidth = _columnWidth(context, style, _widestTwoDigits);
    final monthWidth = _months
        .map((month) => _columnWidth(context, style, month))
        .reduce(max);
    final yearWidth = _columnWidth(context, style, _widestFourDigits);

    return [
      _column(
        controller: _dayController,
        itemCount: _maxDaysPerMonth,
        item: (index) => _dayItem(index, style),
        onChanged: _onDayChanged,
        width: dayWidth,
      ),
      _column(
        controller: _monthController,
        itemCount: _monthsPerYear,
        item: (index) => Center(child: Text(_months[index], style: style)),
        onChanged: _onMonthChanged,
        width: monthWidth,
      ),
      _column(
        controller: _yearController,
        itemCount: _yearCount,
        item: (index) => Center(
          child: Text('${widget.minimumYear + index}', style: style),
        ),
        onChanged: _onYearChanged,
        width: yearWidth,
        looping: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveTextStyle(context);

    return SizedBox(
      height: widget.size.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: SizedBox(
                height: widget.size.itemExtent,
                width: double.infinity,
                child: const CupertinoPickerDefaultSelectionOverlay(),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _columns(context, style),
          ),
        ],
      ),
    );
  }
}

/// Formats a [DateTime] as `21 Dec 2024`.
class DateLabelFormatter {
  /// Creates a [DateLabelFormatter].
  const DateLabelFormatter();

  static final DateFormat _format = DateFormat('d MMM yyyy');

  /// Returns [date] rendered as day, abbreviated month, four-digit year.
  String format(DateTime date) => _format.format(date);
}
