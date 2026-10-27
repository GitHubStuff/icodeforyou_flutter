// packages/caption_switch/lib/caption_switch.dart

import 'package:flutter/material.dart';

/// A labelled on/off switch. Controlled: the parent owns [value] and
/// receives every change through [onChanged].
class CaptionSwitch extends StatelessWidget {
  /// Creates a captioned switch from arbitrary widgets.
  const CaptionSwitch({
    required this.caption,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  /// Creates a captioned switch from plain strings.
  ///
  /// [textStyle] applies to [caption]; [subtitleStyle] applies to
  /// [subtitle]. Either left `null` falls back to the list-tile theme.
  CaptionSwitch.text({
    required String caption,
    required this.value,
    required this.onChanged,
    String? subtitle,
    TextStyle? textStyle,
    TextStyle? subtitleStyle,
    super.key,
  }) : caption = Text(caption, style: textStyle),
       subtitle = _optionalText(subtitle, subtitleStyle);

  static Text? _optionalText(String? data, TextStyle? style) =>
      data == null ? null : Text(data, style: style);

  /// Text shown beside the switch.
  final Widget caption;

  /// Optional secondary line under [caption].
  final Widget? subtitle;

  /// Current state.
  final bool value;

  /// Called with the new state. `null` disables the switch.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: caption,
      subtitle: subtitle,
      value: value,
      onChanged: onChanged,
    );
  }
}
