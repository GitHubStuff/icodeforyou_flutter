// programs/widgetbook_workspace/lib/textfield/password_field.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:custom_widgets/custom_widgets.dart' show PasswordField;
import 'package:extensions/extensions.dart'
    show HapticIntensity, WindowSizeCategory;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: PasswordField)
Widget buildPasswordFieldUseCase(BuildContext context) {
  final label = context.knobs.stringOrNull(
    label: 'label',
    initialValue: 'Password',
    description: 'Null shows no floating label.',
  );
  final errorText = context.knobs.stringOrNull(
    label: 'errorText',
    initialValue: null,
    description:
        'Any non-null value (even empty) flips the error state. '
        'The field height never changes — the message line is reserved.',
  );
  final haptic = context.knobs.object.dropdown(
    label: 'haptic',
    options: HapticIntensity.values,
    initialOption: HapticIntensity.selection,
    labelBuilder: (option) => option.name,
    description:
        'Fires on each visibility toggle; feel it on a device, '
        'not in the desktop workbench.',
  );
  final windowSizeCategory = context.knobs.object.dropdown(
    label: 'windowSizeCategory',
    options: WindowSizeCategory.values,
    initialOption: WindowSizeCategory.compact,
    labelBuilder: (option) => option.name,
  );

  return _PasswordFieldUseCaseHarness(
    label: label,
    errorText: errorText,
    haptic: haptic,
    windowSizeCategory: windowSizeCategory,
  );
}

/// Owner harness for [PasswordField].
///
/// [PasswordField]'s contract is that [TextEditingController] and
/// [FocusNode] are created and disposed by the caller — so the harness is
/// that caller. Nothing is keyed on knob values: typed text and the
/// internal reveal state must survive knob changes. The reveal/hide icons
/// are fixed [Icons.visibility]/[Icons.visibility_off]; the icons are
/// display-only by contract, so a knob for them would vary nothing the
/// widget owns.
final class _PasswordFieldUseCaseHarness extends StatefulWidget {
  const _PasswordFieldUseCaseHarness({
    required this.label,
    required this.errorText,
    required this.haptic,
    required this.windowSizeCategory,
  });

  /// Forwarded to [PasswordField.label].
  final String? label;

  /// Forwarded to [PasswordField.errorText].
  final String? errorText;

  /// Forwarded to [PasswordField.haptic].
  final HapticIntensity haptic;

  /// Forwarded to [PasswordField.windowSizeCategory].
  final WindowSizeCategory windowSizeCategory;

  @override
  State<_PasswordFieldUseCaseHarness> createState() =>
      _PasswordFieldUseCaseHarnessState();
}

class _PasswordFieldUseCaseHarnessState
    extends State<_PasswordFieldUseCaseHarness> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: PasswordField(
          controller: _controller,
          focusNode: _focusNode,
          label: widget.label,
          errorText: widget.errorText,
          haptic: widget.haptic,
          windowSizeCategory: widget.windowSizeCategory,
          showTextIcon: const Icon(Icons.visibility),
          hideTextIcon: const Icon(Icons.visibility_off),
        ),
      ),
    );
  }
}
