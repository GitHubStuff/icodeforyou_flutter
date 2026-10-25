// programs/widgetbook_workspace/lib/packages/caption_switch/caption_switch.usecase.dart

import 'package:caption_switch/caption_switch.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Owns the switch state so the controlled [CaptionSwitch] is interactive
/// inside Widgetbook. [builder] receives the current value and a setter.
class _ControlledHost extends StatefulWidget {
  const _ControlledHost({
    required this.initialValue,
    required this.builder,
    super.key,
  });

  final bool initialValue;
  final Widget Function(bool value, ValueChanged<bool> onChanged) builder;

  @override
  State<_ControlledHost> createState() => _ControlledHostState();
}

class _ControlledHostState extends State<_ControlledHost> {
  late bool _value = widget.initialValue;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: widget.builder(_value, (next) => setState(() => _value = next)),
  );
}

TextStyle? _styleKnob(BuildContext context, String label) {
  final textTheme = Theme.of(context).textTheme;
  final options = <String, TextStyle?>{
    'Theme default': null,
    'titleMedium': textTheme.titleMedium,
    'titleLarge': textTheme.titleLarge,
    'bodySmall': textTheme.bodySmall,
    'labelSmall': textTheme.labelSmall,
  };

  final selected = context.knobs.object.dropdown<String>(
    label: label,
    options: options.keys.toList(),
    initialOption: 'Theme default',
    labelBuilder: (option) => option,
  );

  return options[selected];
}

@widgetbook.UseCase(name: 'Interactive (text)', type: CaptionSwitch)
Widget interactiveTextCaptionSwitchUseCase(BuildContext context) {
  final caption = context.knobs.string(
    label: 'Caption',
    initialValue: 'Enable notifications',
  );
  final subtitle = context.knobs.stringOrNull(
    label: 'Subtitle',
    initialValue: 'Receive alerts for new activity',
  );
  final initialValue = context.knobs.boolean(
    label: 'Initial value',
    initialValue: false,
  );
  final enabled = context.knobs.boolean(
    label: 'Enabled',
    initialValue: true,
  );
  final textStyle = _styleKnob(context, 'Caption style');
  final subtitleStyle = _styleKnob(context, 'Subtitle style');

  return _ControlledHost(
    key: ValueKey(initialValue),
    initialValue: initialValue,
    builder: (value, onChanged) => CaptionSwitch.text(
      caption: caption,
      subtitle: subtitle,
      textStyle: textStyle,
      subtitleStyle: subtitleStyle,
      value: value,
      onChanged: enabled ? onChanged : null,
    ),
  );
}

@widgetbook.UseCase(name: 'Custom caption widget', type: CaptionSwitch)
Widget customCaptionWidgetCaptionSwitchUseCase(BuildContext context) {
  final initialValue = context.knobs.boolean(
    label: 'Initial value',
    initialValue: true,
  );
  final showSubtitle = context.knobs.boolean(
    label: 'Show subtitle',
    initialValue: true,
  );

  return _ControlledHost(
    key: ValueKey(initialValue),
    initialValue: initialValue,
    builder: (value, onChanged) => CaptionSwitch(
      caption: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi),
          SizedBox(width: 8),
          Text('Wi-Fi'),
        ],
      ),
      subtitle: showSubtitle
          ? Text(value ? 'Connected to Home-5G' : 'Not connected')
          : null,
      value: value,
      onChanged: onChanged,
    ),
  );
}

@widgetbook.UseCase(name: 'Disabled', type: CaptionSwitch)
Widget disabledCaptionSwitchUseCase(BuildContext context) {
  final value = context.knobs.boolean(label: 'Value', initialValue: true);

  return Padding(
    padding: const EdgeInsets.all(16),
    child: CaptionSwitch.text(
      caption: 'Managed by your organisation',
      subtitle: 'Contact an administrator to change this setting',
      value: value,
      onChanged: null,
    ),
  );
}
