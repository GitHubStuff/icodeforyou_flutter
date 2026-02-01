// lib/src/presentation/widgets/scrolling_date_picker_column.dart

part of 'scrolling_date_picker.dart';

/// Individual column for the date picker
class _ScrollingDatePickerColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final bool isInfinite;
  final int? itemCount;
  final String Function(int) itemBuilder;
  final ValueChanged<int> onSelectedItemChanged;
  final TextStyle? textStyle;
  /// Whether the picker should loop. Defaults to [isInfinite] if not specified.
  final bool? looping;

  const _ScrollingDatePickerColumn({
    required this.controller,
    required this.isInfinite,
    this.itemCount,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
    this.textStyle,
    this.looping,
  }) : assert(!isInfinite || itemCount == null,
            'Cannot specify itemCount for infinite scroll');

  @override
  Widget build(BuildContext context) {
    // Use explicit looping if provided, otherwise default to isInfinite
    final shouldLoop = looping ?? isInfinite;
    
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: DimensionConstants.itemExtent,
      onSelectedItemChanged: onSelectedItemChanged,
      looping: shouldLoop,
      children: isInfinite
          ? List.generate(
              StyleConstants.infiniteScrollBuffer,
              (index) => _buildItem(itemBuilder(index)),
            )
          : List.generate(
              itemCount ?? 0,
              (index) => _buildItem(itemBuilder(index)),
            ),
    );
  }

  Widget _buildItem(String text) {
    return Center(
      child: Text(
        text,
        style: textStyle ??
            TextStyle(
              color: StyleConstants.defaultTextColor,
              fontSize: StyleConstants.defaultTextSize,
              fontWeight: StyleConstants.defaultFontWeight,
            ),
      ),
    );
  }
}
