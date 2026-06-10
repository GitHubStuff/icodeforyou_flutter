// packages/custom_widgets/lib/src/password_field/password_field.dart

import 'package:extensions/haptics/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';

const Duration _kSwitchDuration = Duration(milliseconds: 300);
const String _kShowLabel = 'Show password';
const String _kHideLabel = 'Hide password';

/// A password text field that masks its input and offers a tap-to-reveal
/// toggle in the trailing slot.
///
/// The field owns the obscure state, the trailing affordance, and the tap.
/// [showTextIcon] and [hideTextIcon] are display-only — any interactivity
/// they carry is neutralized, so the whole trailing area toggles visibility.
class PasswordField extends StatefulWidget {
  /// Creates a password field.
  ///
  /// [controller] is owned by the caller; this widget never disposes it.
  const PasswordField({
    required this.controller,
    required this.showTextIcon,
    required this.hideTextIcon,
    this.passwordLabel,
    this.haptic = HapticIntensity.selection,
    super.key,
  });

  /// Holds the field's text. Created and disposed by the caller.
  final TextEditingController controller;

  /// Shown while the text is hidden; tapping it reveals the text.
  final Widget showTextIcon;

  /// Shown while the text is revealed; tapping it hides the text.
  final Widget hideTextIcon;

  /// Floating label text. When `null`, no label is shown.
  final String? passwordLabel;

  /// Haptic fired on each visibility toggle.
  final HapticIntensity haptic;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  final FocusNode _focusNode = FocusNode();
  bool _obscure = true;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleObscure() {
    setState(() => _obscure = !_obscure);
    _focusNode.requestFocus();
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );
  }

  Widget _buildToggle() {
    return Semantics(
      button: true,
      label: _obscure ? _kShowLabel : _kHideLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.haptic.wrap(_toggleObscure),
        child: IgnorePointer(
          child: AnimatedSwitcher(
            duration: _kSwitchDuration,
            child: KeyedSubtree(
              key: ValueKey<bool>(_obscure),
              child: _obscure ? widget.showTextIcon : widget.hideTextIcon,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscure,
      maxLines: _obscure ? 1 : null,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: widget.passwordLabel,
        border: const OutlineInputBorder(),
        suffixIcon: _buildToggle(),
      ),
    );
  }
}
