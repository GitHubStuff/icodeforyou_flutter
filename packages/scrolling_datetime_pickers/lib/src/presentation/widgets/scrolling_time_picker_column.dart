// lib/src/presentation/widgets/scrolling_time_picker_column.dart

part of 'scrolling_time_picker.dart';

/// Individual column for the time picker
class _ScrollingTimePickerColumn extends StatelessWidget {
  const _ScrollingTimePickerColumn({
    required this.controller,
    required this.isInfinite,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
    this.itemCount,
    this.textStyle,
  });
  final FixedExtentScrollController controller;
  final bool isInfinite;
  final int? itemCount;
  final String Function(int) itemBuilder;
  final void Function(int) onSelectedItemChanged;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: DimensionConstants.itemExtent,
      magnification: DimensionConstants.magnification,
      diameterRatio: DimensionConstants.diameterRatio,
      useMagnifier: true,
      onSelectedItemChanged: onSelectedItemChanged,
      childCount: isInfinite ? null : itemCount,
      itemBuilder: (context, index) {
        return Center(
          child: Text(
            itemBuilder(index),
            style:
                textStyle ??
                const TextStyle(
                  color: StyleConstants.defaultTextColor,
                  fontSize: StyleConstants.defaultTextSize,
                  fontWeight: StyleConstants.defaultFontWeight,
                ),
          ),
        );
      },
    );
  }
}
