// packages/sincewhen_widgets/lib/src/glossary_edits/widgets/glossary_item_create_dialog.dart

import 'package:custom_widgets/custom_widgets.dart'
    show ExpandingTextField, IceChip;
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sincewhen_models/sincewhen_models.dart' show GlossaryItem;

const int _minTagLength = 3;
const int _maxTagLength = 12;
const int _minDescrLength = 5;
const double _dialogMaxWidth = 480;
const double _dialogBorderRadius = 12;
const double _tagFieldWidth = 160;
const double _buttonFontSize = 16;

/// A [TextInputFormatter] that transforms incoming characters to upper case.
class _UpperCaseTextFormatter extends TextInputFormatter {
  const _UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// {@template glossary_item_create_dialog}
/// A non-barrier-dismissible modal dialog configured for drafting and
/// instantiating a new [GlossaryItem].
///
/// Fully responsive across compact mobile screens and wide desktop canvases.
/// Converts tag text to upper-case on the fly, strips whitespace, and
/// validates length constraints before enabling the creation action.
/// {@endtemplate}
class GlossaryItemCreateDialog extends StatefulWidget {
  /// {@macro glossary_item_create_dialog}
  const GlossaryItemCreateDialog({
    required this.createdTimestamp,
    required this.colorArgb,
    this.hapticIntensity = HapticIntensity.light,
    super.key,
  });

  /// The timestamp applied directly to the constructed [GlossaryItem].
  final int createdTimestamp;

  /// The 32-bit ARGB color value passed to the [GlossaryItem] and rendered
  /// by the embedded [IceChip] preview.
  final int colorArgb;

  /// The intensity of haptic feedback fired on user interactions.
  final HapticIntensity hapticIntensity;

  /// Displays the [GlossaryItemCreateDialog] modally.
  ///
  /// [barrierDismissible] is hardcoded to `false`. Returns the configured
  /// [GlossaryItem] when approved, or `null` if aborted.
  static Future<GlossaryItem?> show(
    BuildContext context, {
    required int createdTimestamp,
    required int colorArgb,
    HapticIntensity hapticIntensity = HapticIntensity.light,
  }) {
    return showDialog<GlossaryItem?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GlossaryItemCreateDialog(
        createdTimestamp: createdTimestamp,
        colorArgb: colorArgb,
        hapticIntensity: hapticIntensity,
      ),
    );
  }

  @override
  State<GlossaryItemCreateDialog> createState() =>
      _GlossaryItemCreateDialogState();
}

class _GlossaryItemCreateDialogState extends State<GlossaryItemCreateDialog> {
  late final TextEditingController _tagController;
  late final TextEditingController _descrController;
  late final FocusNode _descrFocusNode;
  bool _showChipBorder = true;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController();
    _descrController = TextEditingController();
    _descrFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _tagController.dispose();
    _descrController.dispose();
    _descrFocusNode.dispose();
    super.dispose();
  }

  /// Toggles the border visibility of the [IceChip] with haptic feedback.
  void _toggleChipBorder() {
    widget.hapticIntensity.trigger();
    setState(() {
      _showChipBorder = !_showChipBorder;
    });
  }

  /// Verifies that both the tag and description meet length boundaries.
  bool _isInputValid(String tag, String descr) {
    final trimmedTag = tag.trim();
    final trimmedDescr = descr.trim();
    return trimmedTag.length >= _minTagLength &&
        trimmedTag.length <= _maxTagLength &&
        trimmedDescr.length >= _minDescrLength;
  }

  /// Constructs the domain model with default `id: 0` and pops the route.
  void _onAddPressed() {
    final item = GlossaryItem(
      id: 0,
      createdTimestamp: widget.createdTimestamp,
      tag: _tagController.text.trim(),
      colorArgb: widget.colorArgb,
      descr: _descrController.text.trim(),
    );
    Navigator.of(context).pop(item);
  }

  /// Dismisses the dialog with a `null` payload.
  void _onCancelPressed() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = Color(widget.colorArgb);

    final buttonTextStyle = theme.textTheme.labelLarge?.copyWith(
      fontSize: _buttonFontSize,
      fontWeight: FontWeight.bold,
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_dialogBorderRadius),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _dialogMaxWidth,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title: Centered and clear
              Text(
                'Glossary Item Details Editor',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(20),

              // Line 1: Tag Input with flexible constraints
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _tagFieldWidth,
                  ),
                  child: TextField(
                    controller: _tagController,
                    autofocus: true,
                    maxLength: _maxTagLength,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _descrFocusNode.requestFocus(),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      const _UpperCaseTextFormatter(),
                    ],
                    decoration: InputDecoration(
                      labelText: 'TAG',
                      hintText: '$_minTagLength-$_maxTagLength CHARS',
                      fillColor: theme.colorScheme.surface,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const Gap(12),

              // Line 2: Preview label and interactive IceChip
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Preview:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.hintColor,
                    ),
                  ),
                  const Gap(10),
                  Flexible(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _tagController,
                      builder: (context, value, _) {
                        final text = value.text.trim();
                        if (text.isEmpty) {
                          return IceChip(
                            const SizedBox(width: 8, height: 8),
                            backgroundColor: chipColor,
                            showBorder: _showChipBorder,
                            onPress: _toggleChipBorder,
                          );
                        }
                        return IceChip.text(
                          text,
                          backgroundColor: chipColor,
                          showBorder: _showChipBorder,
                          onPress: _toggleChipBorder,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const Gap(16),

              // Line 3: Caption + Multiline Expanding Description Field
              Text(
                'Tag Description',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(6),
              ExpandingTextField(
                controller: _descrController,
                focusNode: _descrFocusNode,
                hintText: 'Enter description (min $_minDescrLength chars)...',
                onChanged: (_) {},
              ),
              const Gap(24),

              // Line 4: Action buttons with conditional haptics
              ListenableBuilder(
                listenable: Listenable.merge([
                  _tagController,
                  _descrController,
                ]),
                builder: (context, _) {
                  final canSubmit = _isInputValid(
                    _tagController.text,
                    _descrController.text,
                  );

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          textStyle: buttonTextStyle,
                          side: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onPressed: widget.hapticIntensity.wrap(
                          _onCancelPressed,
                        ),
                        child: const Text('Cancel'),
                      ),
                      const Gap(12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          textStyle: buttonTextStyle,
                          backgroundColor: canSubmit
                              ? Theme.of(context).colorScheme.error
                              : theme.disabledColor,
                          side: BorderSide(
                            color: canSubmit
                                ? theme.colorScheme.secondary
                                : theme.disabledColor,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        onPressed: canSubmit
                            ? widget.hapticIntensity.wrap(_onAddPressed)
                            : null,
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
