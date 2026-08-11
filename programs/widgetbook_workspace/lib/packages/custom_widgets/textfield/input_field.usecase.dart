// programs/widgetbook_workspace/lib/textfield/input_field.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:custom_widgets/custom_widgets.dart' show InputField;
import 'package:extensions/extensions.dart' show WindowSizeCategory;
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' show showToast;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const int _kMaxLinesMin = 1;
const int _kMaxLinesMax = 5;

/// Named keyboard-type options, including the null default.
const List<({String name, TextInputType? type})> _kTextInputTypeOptions = [
  (name: 'default (null)', type: null),
  (name: 'emailAddress', type: TextInputType.emailAddress),
  (name: 'number', type: TextInputType.number),
  (name: 'phone', type: TextInputType.phone),
  (name: 'multiline', type: TextInputType.multiline),
];

@widgetbook.UseCase(name: 'Default', type: InputField)
Widget buildInputFieldUseCase(BuildContext context) {
  final label = context.knobs.stringOrNull(
    label: 'label',
    initialValue: 'Email',
    description: 'Null shows no floating label.',
  );
  final errorText = context.knobs.stringOrNull(
    label: 'errorText',
    initialValue: null,
    description:
        'Any non-null value (even empty) flips the error state. '
        'The field height never changes — the message line is reserved.',
  );
  final showSuffix = context.knobs.boolean(
    label: 'suffixWidget (clear button)',
    initialValue: true,
    description:
        'Mounts the documented example: a clear button that '
        'empties the controller and returns focus to the field.',
  );
  final maxLines = context.knobs.int.slider(
    label: 'maxLines',
    initialValue: _kMaxLinesMin,
    min: _kMaxLinesMin,
    max: _kMaxLinesMax,
  );
  final textInputTypeOption = context.knobs.object.dropdown(
    label: 'textInputType',
    options: _kTextInputTypeOptions,
    initialOption: _kTextInputTypeOptions.first,
    labelBuilder: (option) => option.name,
  );
  final windowSizeCategory = context.knobs.object.dropdown(
    label: 'windowSizeCategory',
    options: WindowSizeCategory.values,
    initialOption: WindowSizeCategory.extraLarge,
    labelBuilder: (option) => option.name,
  );
  final enableAutoCorrect = context.knobs.boolean(
    label: 'enableAutoCorrect',
    description:
        'Platform keyboard behaviour; no visible effect in the '
        'workbench on desktop.',
  );
  final enableSuggestions = context.knobs.boolean(
    label: 'enableSuggestions',
    description:
        'Platform keyboard behaviour; no visible effect in the '
        'workbench on desktop.',
  );

  return _InputFieldUseCaseHarness(
    label: label,
    errorText: errorText,
    showSuffix: showSuffix,
    maxLines: maxLines,
    textInputType: textInputTypeOption.type,
    windowSizeCategory: windowSizeCategory,
    enableAutoCorrect: enableAutoCorrect,
    enableSuggestions: enableSuggestions,
  );
}

/// Owner harness for [InputField].
///
/// [InputField]'s contract is that [TextEditingController] and [FocusNode]
/// are created and disposed by the caller — so the harness is that caller.
/// Nothing is keyed on knob values: typed text must survive knob changes,
/// because the controller's lifetime is independent of the widget's
/// configuration. That independence is the contract under test.
final class _InputFieldUseCaseHarness extends StatefulWidget {
  const _InputFieldUseCaseHarness({
    required this.label,
    required this.errorText,
    required this.showSuffix,
    required this.maxLines,
    required this.textInputType,
    required this.windowSizeCategory,
    required this.enableAutoCorrect,
    required this.enableSuggestions,
  });

  /// Forwarded to [InputField.label].
  final String? label;

  /// Forwarded to [InputField.errorText].
  final String? errorText;

  /// Whether the clear-button suffix is mounted.
  final bool showSuffix;

  /// Forwarded to [InputField.maxLines].
  final int maxLines;

  /// Forwarded to [InputField.textInputType].
  final TextInputType? textInputType;

  /// Forwarded to [InputField.windowSizeCategory].
  final WindowSizeCategory windowSizeCategory;

  /// Forwarded to [InputField.enableAutoCorrect].
  final bool enableAutoCorrect;

  /// Forwarded to [InputField.enableSuggestions].
  final bool enableSuggestions;

  @override
  State<_InputFieldUseCaseHarness> createState() =>
      _InputFieldUseCaseHarnessState();
}

class _InputFieldUseCaseHarnessState extends State<_InputFieldUseCaseHarness> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// The documented suffix example: clear the controller and hand focus
  /// back to the field through the caller-owned [FocusNode].
  void _clear() {
    _controller.clear();
    _focusNode.requestFocus();
    showToast('cleared');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: InputField(
          controller: _controller,
          focusNode: _focusNode,
          label: widget.label,
          errorText: widget.errorText,
          maxLines: widget.maxLines,
          textInputType: widget.textInputType,
          windowSizeCategory: widget.windowSizeCategory,
          enableAutoCorrect: widget.enableAutoCorrect,
          enableSuggestions: widget.enableSuggestions,
          suffixWidget: widget.showSuffix
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clear,
                )
              : null,
        ),
      ),
    );
  }
}
