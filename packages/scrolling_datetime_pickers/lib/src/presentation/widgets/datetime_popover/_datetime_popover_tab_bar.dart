// lib/src/presentation/widgets/datetime_popover/_datetime_popover_tab_bar.dart

part of 'datetime_picker_popover.dart';

class _DateTimePopoverTabBar extends StatelessWidget {
  const _DateTimePopoverTabBar({
    required this.activeTab,
    required this.dateButtonColor,
    required this.timeButtonColor,
    required this.dateButtonTextStyle,
    required this.timeButtonTextStyle,
    required this.onTabChanged,
  });

  final _DateTimeTab activeTab;
  final Color dateButtonColor;
  final Color timeButtonColor;
  final TextStyle? dateButtonTextStyle;
  final TextStyle? timeButtonTextStyle;
  final ValueChanged<_DateTimeTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PopoverConstants.tabBarHeight,
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'DATE',
              isSelected: activeTab == _DateTimeTab.date,
              selectedColor: dateButtonColor,
              textStyle: dateButtonTextStyle,
              onTap: () => onTabChanged(_DateTimeTab.date),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'TIME',
              isSelected: activeTab == _DateTimeTab.time,
              selectedColor: timeButtonColor,
              textStyle: timeButtonTextStyle,
              onTap: () => onTabChanged(_DateTimeTab.time),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.textStyle,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final TextStyle? textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final baseColor = textStyle?.color ?? Colors.white;

    final effectiveStyle = TextStyle(
      fontSize: textStyle?.fontSize ?? PopoverConstants.tabButtonFontSize,
      fontWeight: isSelected
          ? PopoverConstants.tabButtonSelectedFontWeight
          : PopoverConstants.tabButtonUnselectedFontWeight,
      color: isSelected ? selectedColor : baseColor,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? selectedColor : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(label, style: effectiveStyle),
      ),
    );
  }
}
