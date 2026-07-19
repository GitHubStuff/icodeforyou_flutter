// packages/sincewhen_widgets/lib/src/glossary/pill_widget.dart

import 'package:flutter/material.dart';

const double _kSmallFontSize = 14;
const double _kMediumFontSize = 16;
const double _kLargeFontSize = 18;
const double _kBorderWidth = 2;
const double _kLuminanceThreshold = 0.5;
const String _kPlaceholder = 'tag';

/// A tappable tag pill.
///
/// Renders [label] on a [color] background with no checkmark. The label
/// color is luminance-picked from [liteThemeColor] (bright backgrounds)
/// and [darkThemeColor] (dark backgrounds). Tapping toggles selection and
/// reports the new state via [onSelected]. When selected, the pill draws
/// a border — black in light theme, white in dark. The unselected state
/// carries a transparent border of the same width, so selection never
/// changes the pill's size.
///
/// When [label] is empty, renders as a disabled light-grey placeholder
/// and [onSelected] is never called.
///
/// Sizing: [PillWidget.small] (14, phones — exactly fills the chip's
/// 32dp visual floor), [PillWidget.medium] (16, tablets), and
/// [PillWidget.large] (18, desktop/web) pick platform-appealing font
/// sizes; the default constructor accepts any [fontSize].
class PillWidget extends StatefulWidget {
  const PillWidget({
    required this.label,
    required this.color,
    required this.onSelected,
    this.fontSize = _kSmallFontSize,
    this.initialSelected = false,
    this.darkThemeColor = Colors.white,
    this.liteThemeColor = Colors.black,
    super.key,
  });

  /// Pill sized for phones (font size 14 — pixel-tight against the
  /// chip's 32dp visual floor).
  const PillWidget.small({
    required this.label,
    required this.color,
    required this.onSelected,
    this.initialSelected = false,
    this.darkThemeColor = Colors.white,
    this.liteThemeColor = Colors.black,
    super.key,
  }) : fontSize = _kSmallFontSize;

  /// Pill sized for tablets (font size 16).
  const PillWidget.medium({
    required this.label,
    required this.color,
    required this.onSelected,
    this.initialSelected = false,
    this.darkThemeColor = Colors.white,
    this.liteThemeColor = Colors.black,
    super.key,
  }) : fontSize = _kMediumFontSize;

  /// Pill sized for desktop and web (font size 18).
  const PillWidget.large({
    required this.label,
    required this.color,
    required this.onSelected,
    this.initialSelected = false,
    this.darkThemeColor = Colors.white,
    this.liteThemeColor = Colors.black,
    super.key,
  }) : fontSize = _kLargeFontSize;

  /// Text shown in the pill. Empty renders the disabled placeholder.
  final String label;

  /// Background color of the pill.
  final Color color;

  /// Fixed font size for the pill's label.
  final double fontSize;

  /// Selection state on first build.
  final bool initialSelected;

  /// Label color used when [color] is dark (low luminance).
  final Color darkThemeColor;

  /// Label color used when [color] is bright (high luminance).
  final Color liteThemeColor;

  /// Called with the new state each time the pill is tapped:
  /// `true` when it becomes selected, `false` when deselected.
  final ValueChanged<bool> onSelected;

  @override
  State<PillWidget> createState() => _PillWidgetState();
}

class _PillWidgetState extends State<PillWidget> {
  late bool _selected = widget.initialSelected;

  void _handleTap(bool selected) {
    setState(() => _selected = selected);
    widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = widget.label.isEmpty;

    final Color background = isEmpty
        ? theme.colorScheme.surfaceContainerHighest
        : widget.color;
    final Color labelColor = isEmpty
        ? theme.colorScheme.onSurfaceVariant
        : (widget.color.computeLuminance() > _kLuminanceThreshold
              ? widget.liteThemeColor
              : widget.darkThemeColor);
    final Color borderColor = (!isEmpty && _selected)
        ? (theme.brightness == Brightness.light ? Colors.black : Colors.white)
        : Colors.transparent;

    return FilterChip(
      label: Text(
        isEmpty ? _kPlaceholder : widget.label,
        style: TextStyle(fontSize: widget.fontSize, color: labelColor),
      ),
      showCheckmark: false,
      backgroundColor: background,
      selectedColor: background,
      disabledColor: background,
      shape: const StadiumBorder(),
      side: BorderSide(color: borderColor, width: _kBorderWidth),
      selected: _selected,
      onSelected: isEmpty ? null : _handleTap,
    );
  }
}
