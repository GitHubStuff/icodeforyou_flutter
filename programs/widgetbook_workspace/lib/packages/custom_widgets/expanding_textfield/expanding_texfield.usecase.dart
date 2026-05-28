// programs/widgetbook_workspace/lib/packages/custom_widgets/expanding_textfield/expanding_texfield.usecase.dart
import 'package:custom_widgets/custom_widgets.dart' show ExpandingTextField;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ExpandingTextField)
Widget expandingTextFieldDefault(BuildContext context) {
  final hintText = context.knobs.stringOrNull(
    label: 'hintText',
    initialValue: 'Type here…',
  );

  final minLines = context.knobs.double
      .slider(
        label: 'minLines',
        initialValue: 4,
        min: 1,
        max: 20,
        divisions: 19,
      )
      .round();

  final maxLines = context.knobs.double
      .slider(
        label: 'maxLines',
        initialValue: 10,
        min: 1,
        max: 40,
        divisions: 39,
      )
      .round();

  final keyboardTypes = <String, TextInputType>{
    'multiline': TextInputType.multiline,
    'text': TextInputType.text,
    'number': TextInputType.number,
    'emailAddress': TextInputType.emailAddress,
    'url': TextInputType.url,
    'phone': TextInputType.phone,
    'datetime': TextInputType.datetime,
    'name': TextInputType.name,
  };

  final keyboardTypeKey = context.knobs.object.dropdown<String>(
    label: 'keyboardType',
    options: keyboardTypes.keys.toList(),
    initialOption: 'multiline',
  );

  final borderColor = context.knobs.colorOrNull(
    label: 'borderColor',
    initialValue: null,
  );

  final useCustomTextStyle = context.knobs.boolean(
    label: 'override textStyle',
    initialValue: false,
  );

  final fontSize = context.knobs.double.slider(
    label: 'textStyle.fontSize',
    initialValue: 18,
    min: 8,
    max: 48,
    divisions: 40,
  );

  // Guard against invalid configurations the knobs can produce. The widget's
  // assert requires maxLines >= minLines.
  if (maxLines < minLines) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'maxLines ($maxLines) must be >= minLines ($minLines)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  return _ExpandingTextFieldHost(
    builder: (controller) => Padding(
      padding: const EdgeInsets.all(24),
      child: ExpandingTextField(
        controller: controller,
        onChanged: (_) {},
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardTypes[keyboardTypeKey]!,
        hintText: hintText,
        borderColor: borderColor,
        textStyle: useCustomTextStyle ? TextStyle(fontSize: fontSize) : null,
      ),
    ),
  );
}

/// Owns the [TextEditingController] lifecycle for the usecase. Widgetbook
/// usecase builders are stateless functions, so the controller must live in
/// a wrapper to be disposed correctly.
class _ExpandingTextFieldHost extends StatefulWidget {
  const _ExpandingTextFieldHost({required this.builder});

  final Widget Function(TextEditingController controller) builder;

  @override
  State<_ExpandingTextFieldHost> createState() =>
      _ExpandingTextFieldHostState();
}

class _ExpandingTextFieldHostState extends State<_ExpandingTextFieldHost> {
  late final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller);
}
