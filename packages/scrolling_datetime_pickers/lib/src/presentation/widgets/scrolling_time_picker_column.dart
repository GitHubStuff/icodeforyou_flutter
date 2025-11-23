// lib/src/presentation/widgets/scrolling_time_picker_column.dart

part of 'scrolling_time_picker.dart';

/// Individual column for the time picker
class _ScrollingTimePickerColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final bool isInfinite;
  final int? itemCount;
  final String Function(int) itemBuilder;
  final void Function(int) onSelectedItemChanged;
  final TextStyle? textStyle;

  const _ScrollingTimePickerColumn({
    required this.controller,
    required this.isInfinite,
    this.itemCount,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: DimensionConstants.itemExtent,
      magnification: DimensionConstants.magnification,
      squeeze: DimensionConstants.squeeze,
      diameterRatio: DimensionConstants.diameterRatio,
      useMagnifier: true,
      onSelectedItemChanged: onSelectedItemChanged,
      childCount: isInfinite ? null : itemCount,
      itemBuilder: (context, index) {
        final actualIndex =
            isInfinite && itemCount != null ? index % itemCount! : index;

        return Center(
          child: Text(
            itemBuilder(actualIndex),
            style: textStyle ??
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
