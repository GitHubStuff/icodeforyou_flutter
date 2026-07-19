// packages/custom_widgets/lib/src/input_field/input_field.dart
// ignore_for_file: always_use_package_imports

import 'package:extensions/enum/src/window_size_category.dart' show WindowSizeCategory;
import 'package:flutter/material.dart';

import '_suffix_slot.dart';

/// A single space kept in the helper slot so the field always reserves one
/// line below the input. A field showing an [InputField.errorText] is then the
/// same height as one that is not, so stacked fields (e.g. email above
/// password) never desync vertically when only one is in error.
const String _kReservedHelperLine = ' ';

/// A reusable, self-sizing outlined text input.
///
/// [InputField] exists to make a small set of decisions that a bare
/// [TextField] does not:
///
/// * its width is driven by a [WindowSizeCategory] rather than the parent;
/// * a trailing [suffixWidget] is sized and centred in a fixed slot so it can
///   never clip the border and aligns with sibling fields;
/// * the border is outlined by default, with its colour driven by the ambient
///   theme;
/// * an [errorText] flips the field into its error state, with a permanently
///   reserved message line so a field in error keeps the same height as a
///   sibling that is not;
/// * autocorrect and suggestions default to `false`.
///
/// It owns layout only. State with a lifecycle — [controller] and [focusNode]
/// — is owned by the caller and never disposed here, which is why this is a
/// [StatelessWidget]. Validation rules are likewise the caller's: this widget
/// only *renders* [errorText], it never decides it. Border colours belong to
/// the theme: set them once via [ThemeData.inputDecorationTheme], or wrap a
/// single field in a [Theme] to vary one in isolation. The [suffixWidget] owns
/// its own gestures and callbacks.
///
/// Pass-through [TextField] options (keyboard type, formatters, callbacks,
/// etc.) are intentionally omitted; they can be added in later revisions if a
/// real need appears, rather than relaying the entire [TextField] API.
class InputField extends StatelessWidget {
  /// Creates an input field.
  ///
  /// [controller] and [focusNode] are owned by the caller; this widget never
  /// disposes them.
  const InputField({
    required this.controller,
    required this.focusNode,
    this.textInputType,
    this.suffixWidget,
    this.label,
    this.errorText,
    this.maxLines = 1,
    this.enableAutoCorrect = false,
    this.enableSuggestions = false,
    this.windowSizeCategory = WindowSizeCategory.extraLarge,
    super.key,
  });

  /// Holds the field's text. Created and disposed by the caller.
  final TextEditingController controller;

  /// Sets the keyboard type
  final TextInputType? textInputType;

  /// Drives focus. Created and disposed by the caller, so the caller fully
  /// controls focus behaviour (request, unfocus, traversal). For example, a
  /// suffix "clear" button can call `focusNode.requestFocus()` to return focus
  /// to this field after clearing [controller].
  final FocusNode focusNode;

  /// An optional trailing widget. It owns its own gestures and callbacks;
  /// [InputField] only sizes, centres, and insets it (via [SuffixSlot]) so it
  /// never overlaps the border and aligns with the suffix of sibling fields.
  final Widget? suffixWidget;

  /// Floating label text. When `null`, no label is shown.
  final String? label;

  /// The error message shown below the field, or `null` when the input is
  /// valid.
  ///
  /// [InputField] is presentation-only: the caller owns the rules and supplies
  /// the resulting message here, exactly as it owns [controller] and
  /// [focusNode]. Any non-null value (including the empty string) puts the
  /// field into its error state and recolours the border, label, and message;
  /// pass `null` to clear it. The message line below the field is always
  /// reserved, so toggling this never changes the field's height.
  final String? errorText;

  /// Maximum visible lines the field expands to.
  final int maxLines;

  /// Whether the platform autocorrect is enabled. Defaults to `false`.
  final bool enableAutoCorrect;

  /// Whether the platform input suggestions are enabled. Defaults to `false`.
  final bool enableSuggestions;

  /// The max width (based on device class) the field occupies.
  final WindowSizeCategory windowSizeCategory;

  @override
  Widget build(BuildContext context) {
    final suffix = suffixWidget;

    return SizedBox(
      width: windowSizeCategory.upperBound,
      child: TextField(
        controller: controller,
        keyboardType: textInputType,
        focusNode: focusNode,
        maxLines: maxLines,
        autocorrect: enableAutoCorrect,
        enableSuggestions: enableSuggestions,
        decoration: InputDecoration(
          labelText: label,
          helperText: _kReservedHelperLine,
          errorText: errorText,
          border: const OutlineInputBorder(),
          suffixIcon: suffix == null ? null : SuffixSlot(child: suffix),
          suffixIconConstraints: SuffixSlot.constraints,
        ),
      ),
    );
  }
}
