// programs/widgetbook_workspace/lib/packages/custom_widgets/password_field/password_field.usecase.dart

// ignore_for_file: public_member_api_docs

import 'package:custom_widgets/custom_widgets.dart' show PasswordField;
import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const double _kMaxFieldWidth = 360;
const EdgeInsets _kFramePadding = EdgeInsets.all(24);

const String _kLabelKnob = 'passwordLabel';
const String _kLabelInitial = 'Password';
const String _kHapticKnob = 'haptic';

const String _kLongValue =
    'correct-horse-battery-staple-K1ssMy@\$\$-and-then-some-more-to-wrap';

@widgetbook.UseCase(name: 'Playground', type: PasswordField)
Widget passwordFieldPlaygroundUseCase(BuildContext context) {
  return _PasswordFieldHost(
    passwordLabel: context.knobs.stringOrNull(
      label: _kLabelKnob,
      initialValue: _kLabelInitial,
    ),
    haptic: context.knobs.object.dropdown<HapticIntensity>(
      label: _kHapticKnob,
      options: HapticIntensity.values,
      initialOption: HapticIntensity.selection,
      labelBuilder: (value) => value.name,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Long Value (wraps when revealed)',
  type: PasswordField,
)
Widget passwordFieldLongValueUseCase(BuildContext context) {
  return const _PasswordFieldHost(
    passwordLabel: _kLabelInitial,
    initialText: _kLongValue,
  );
}

/// Owns the [TextEditingController] for the hosted [PasswordField].
///
/// [PasswordField] never disposes the controller it is given, so the use case
/// — playing the role of the caller — creates it here and disposes it. Seeding
/// is via [initialText] so each use case can stand the field up in a known
/// state without leaking a controller on knob-driven rebuilds.
class _PasswordFieldHost extends StatefulWidget {
  const _PasswordFieldHost({
    this.passwordLabel,
    this.haptic = HapticIntensity.selection,
    this.initialText = '',
  });

  final String? passwordLabel;
  final HapticIntensity haptic;
  final String initialText;

  @override
  State<_PasswordFieldHost> createState() => _PasswordFieldHostState();
}

//+
class _PasswordFieldHostState extends State<_PasswordFieldHost> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  late final passwordFocusNode = FocusNode(debugLabel: 'password');

  @override
  void dispose() {
    _controller.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: _kFramePadding,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxFieldWidth),
            child: PasswordField(
              controller: _controller,
              label: widget.passwordLabel,
              haptic: widget.haptic,
              showTextIcon: const Icon(Icons.visibility_outlined),
              hideTextIcon: const Icon(Icons.visibility_off_outlined),
              focusNode: passwordFocusNode,
            ),
          ),
        ),
      ),
    );
  }
}
