// lib/src/presentation/widgets/datetime_popover/_datetime_popover_header.dart

part of 'datetime_picker_popover.dart';

class _DateTimePopoverHeader extends StatelessWidget {
  const _DateTimePopoverHeader({
    required this.currentDateTime,
    required this.dateFormat,
    required this.timeFormat,
    required this.showSeconds,
    required this.headerDateTextStyle,
    required this.headerTimeTextStyle,
    required this.confirmWidget,
    required this.confirmButtonColor,
    required this.confirmButtonText,
    required this.confirmButtonTextStyle,
    required this.onConfirm,
  });

  final DateTime currentDateTime;
  final String dateFormat;
  final String timeFormat;
  final bool showSeconds;
  final TextStyle? headerDateTextStyle;
  final TextStyle? headerTimeTextStyle;
  final Widget? confirmWidget;
  final Color confirmButtonColor;
  final String confirmButtonText;
  final TextStyle? confirmButtonTextStyle;
  final VoidCallback onConfirm;

  String _formatDate() {
    try {
      return DateFormat(dateFormat).format(currentDateTime);
    } catch (_) {
      return DateFormat(PopoverConstants.defaultDateFormat)
          .format(currentDateTime);
    }
  }

  String _formatTime() {
    try {
      final effectiveFormat = showSeconds
          ? timeFormat
          : timeFormat.replaceAll(':ss', '').replaceAll('ss', '');
      return DateFormat(effectiveFormat).format(currentDateTime);
    } catch (_) {
      final fallbackFormat = showSeconds
          ? PopoverConstants.defaultTimeFormat
          : PopoverConstants.defaultTimeFormatNoSeconds;
      return DateFormat(fallbackFormat).format(currentDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDateStyle = headerDateTextStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: PopoverConstants.headerFontSize,
          fontWeight: FontWeight.w500,
        );

    final effectiveTimeStyle = headerTimeTextStyle ??
        TextStyle(
          color: effectiveDateStyle.color,
          fontSize: PopoverConstants.headerFontSize,
        );

    return Padding(
      padding: const EdgeInsets.all(PopoverConstants.headerPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_formatDate(), style: effectiveDateStyle),
                const SizedBox(height: 4.0),
                Text(_formatTime(), style: effectiveTimeStyle),
              ],
            ),
          ),
          GestureDetector(
            onTap: onConfirm,
            behavior: HitTestBehavior.opaque,
            child: confirmWidget ?? _buildDefaultConfirmButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultConfirmButton() {
    final effectiveTextStyle = confirmButtonTextStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PopoverConstants.confirmButtonHorizontalPadding,
        vertical: PopoverConstants.confirmButtonVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: confirmButtonColor,
        borderRadius: BorderRadius.circular(
          PopoverConstants.confirmButtonBorderRadius,
        ),
      ),
      child: Text(confirmButtonText, style: effectiveTextStyle),
    );
  }
}
