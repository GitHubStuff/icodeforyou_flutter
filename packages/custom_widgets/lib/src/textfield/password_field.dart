// packages/custom_widgets/lib/src/password_field/password_field.dart
// ignore_for_file: always_use_package_imports, comment_references

import 'package:extensions/enum/src/window_size_category.dart' show WindowSizeCategory;
import 'package:extensions/extensions.dart'
    show HapticIntensity;
import 'package:flutter/material.dart';

import '_suffix_slot.dart';

/// Cross-fade duration when swapping the reveal/hide icon.
const Duration _kSwitchDuration = Duration(milliseconds: 300);

/// A single space kept in the helper slot so the field always reserves one
/// line below the input. A field showing a [PasswordField.errorText] is then
/// the same height as one that is not, so stacked fields (e.g. email above
/// password) never desync vertically when only one is in error.
const String _kReservedHelperLine = ' ';

/// Accessibility label announced while the text is hidden.
const String _kShowLabel = 'Show password';

/// Accessibility label announced while the text is revealed.
const String _kHideLabel = 'Hide password';

/// A password text field that masks its input and offers a tap-to-reveal
/// toggle in the trailing slot.
///
/// Designed as a sibling to `InputField`: it shares the same caller-owned
/// [controller]/[focusNode] contract, the same [WindowSizeClass] sizing, the
/// same clip-proof trailing slot (via [SuffixSlot], so the toggle aligns with
/// `InputField`'s suffix when the two are stacked), the same caller-owned
/// [errorText] with a permanently reserved message line, and the same
/// theme-driven border colours — so the two read as a matched pair (e.g.
/// username + password) and stay the same height whether or not either is in
/// error.
///
/// Unlike `InputField`, this widget *owns* an interactive affordance — the
/// reveal toggle — so it remains a [StatefulWidget] (it holds the obscure
/// state) and it owns the [haptic] for that toggle. Validation rules are still
/// the caller's: this widget only *renders* [errorText]. Border colours belong
/// to the theme (set via [ThemeData.inputDecorationTheme], or a wrapping
/// [Theme] for one field). [showTextIcon] and [hideTextIcon] are display-only;
/// their interactivity is neutralized so the entire trailing slot toggles
/// visibility.
class PasswordField extends StatefulWidget {
  /// Creates a password field.
  ///
  /// [controller] and [focusNode] are owned by the caller; this widget never
  /// disposes them.
  const PasswordField({
    required this.controller,
    required this.focusNode,
    required this.showTextIcon,
    required this.hideTextIcon,
    this.label,
    this.errorText,
    this.haptic = HapticIntensity.selection,
    this.windowSizeCategory = WindowSizeCategory.compact,
    super.key,
  });

  /// Holds the field's text. Created and disposed by the caller.
  final TextEditingController controller;

  /// Drives focus. Created and disposed by the caller. Owning it externally
  /// keeps the contract identical to `InputField` and lets a preceding field
  /// (e.g. a username) move focus here programmatically.
  final FocusNode focusNode;

  /// Shown while the text is hidden; tapping it reveals the text.
  final Widget showTextIcon;

  /// Shown while the text is revealed; tapping it hides the text.
  final Widget hideTextIcon;

  /// Floating label text. When `null`, no label is shown.
  final String? label;

  /// The error message shown below the field, or `null` when the input is
  /// valid.
  ///
  /// Presentation-only, exactly as in `InputField`: the caller owns the rules
  /// and supplies the resulting message here. Any non-null value (including
  /// the empty string) puts the field into its error state and recolours the
  /// border, label, and message; pass `null` to clear it. The message line is
  /// always reserved, so toggling this never changes the field's height.
  final String? errorText;

  /// Haptic fired on each visibility toggle. The toggle is this widget's own
  /// action, so the haptic belongs here rather than with the caller.
  final HapticIntensity haptic;

  /// The max width (based on device class) the field occupies.
  final WindowSizeCategory windowSizeCategory;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  /// Whether the text is currently masked. Owned internally — this is the
  /// reason the widget cannot collapse to a [StatelessWidget].
  bool _obscure = true;

  /// Flips visibility, keeps focus on the field, and parks the caret at the
  /// end so toggling never blurs the field or scrambles the selection.
  void _toggleObscure() {
    setState(() => _obscure = !_obscure);
    widget.focusNode.requestFocus();
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );
  }

  /// Builds the trailing reveal/hide affordance.
  ///
  /// The gesture region fills a [kMinInteractiveDimension] square so the whole
  /// slot is the tap target; [SuffixSlot] then centres that square, leaving
  /// the glyph at the same inset as `InputField`'s centred suffix. The supplied
  /// icons are rendered display-only via [IgnorePointer].
  Widget _buildToggle() {
    return Semantics(
      button: true,
      label: _obscure ? _kShowLabel : _kHideLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.haptic.wrap(_toggleObscure),
        child: SizedBox.square(
          dimension: kMinInteractiveDimension,
          child: Center(
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.windowSizeCategory.upperBound,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: _obscure,
        maxLines: _obscure ? 1 : null,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: _kReservedHelperLine,
          errorText: widget.errorText,
          border: const OutlineInputBorder(),
          suffixIcon: SuffixSlot(child: _buildToggle()),
          suffixIconConstraints: SuffixSlot.constraints,
        ),
      ),
    );
  }
}
