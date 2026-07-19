// packages/sincewhen_widgets/lib/src/glossary/glossay_entry_form.dart

import 'package:animated_widgets/animated_widgets.dart' show PillWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sincewhen_framework/sincewhen_framework.dart';

/// Form for creating or editing a glossary entry.
///
/// Displays the entry's color in a 150×150 swatch with its `0xAARRGGBB`
/// value below it (read-only, sized to fit the swatch width), plus
/// editable tag-name and description fields to the right. Below the
/// description, a [PillWidget] previews the tag name in the swatch color.
/// The tag name is forced to uppercase as typed. The accept button is
/// enabled only when the tag name is 3–6 non-space characters and the
/// description is at least 4 characters.
///
/// The tag-name field receives focus automatically when the form first
/// appears, both inline and inside the dialog.
///
/// Works inline as a plain widget, or as a dialog via [showAsDialog],
/// which resolves to the accept payload or `null` on cancel.
///
/// Exactly one of [color] / [glossaryEntry] supplies the swatch color: pass
/// [color] when creating, or [glossaryEntry] when editing an existing record
/// (its color, tag name, and description prefill the form).
///
/// ## Text sizing
///
/// Text follows theme roles rather than hardcoded sizes, with two
/// deliberate fixed exceptions:
///
/// * Input text uses `textTheme.bodyLarge`.
/// * Field labels use `inputDecorationTheme.labelStyle`
///   (defaulting to `bodyLarge` when unset).
/// * Button labels use the Material default, `textTheme.labelLarge`,
///   overridable via `filledButtonTheme` / `outlinedButtonTheme`.
/// * The pill has a fixed font size, [pillFontSize] (default 12).
/// * The hex readout has a fixed font size chosen to fit `0xAARRGGBB`
///   within the swatch width regardless of theme text scaling.
///
/// Size globally by setting those roles in [ThemeData], or size one
/// instance by wrapping it in a [Theme] with a modified copy.
class GlossaryEntryForm extends StatefulWidget {
  /// Creates a glossary entry form.
  ///
  /// Exactly one of [color] or [glossaryEntry] must be non-null — [color]
  /// when creating a new entry, [glossaryEntry] when editing an existing
  /// one. Passing both or neither throws an assertion error in debug
  /// builds.
  const GlossaryEntryForm({
    required this.accept,
    required this.onCancel,
    required this.onAccept,
    this.color,
    this.glossaryEntry,
    this.pillFontSize = _kPillFontSize,
    super.key,
  }) : assert(
         (color == null) != (glossaryEntry == null),
         'Provide exactly one of color (create) or entry (edit).',
       );

  /// Key for the tag name in the accept payload.
  static const String keyTagName = 'tagName';

  /// Key for the description in the accept payload.
  static const String keyDescription = 'description';

  /// Key for the ARGB color int in the accept payload.
  static const String keyColor = 'color';

  /// Swatch color when creating a new entry.
  /// Mutually exclusive with [glossaryEntry].
  final Color? color;

  /// Existing record when editing. Supplies color, tag name, and
  /// description. Mutually exclusive with [color].
  final GlossaryEntry? glossaryEntry;

  /// Label for the accept button.
  final String accept;

  /// Fixed font size for the tag pill's label.
  final double pillFontSize;

  /// Called when the user cancels. Carries no payload.
  final VoidCallback onCancel;

  /// Called with the accept payload: [keyTagName] (String),
  /// [keyDescription] (String), [keyColor] (int ARGB) — everything the
  /// glossary table needs except `id` and `createdTimeStamp`.
  final ValueChanged<Map<String, Object>> onAccept;

  /// Shows the form in a dialog. Resolves to the accept payload, or
  /// `null` if cancelled.
  static Future<Map<String, Object>?> showAsDialog(
    BuildContext context, {
    required String accept,
    Color? color,
    GlossaryEntry? entry,
  }) {
    return showDialog<Map<String, Object>>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(_kPadding),
          child: GlossaryEntryForm(
            accept: accept,
            color: color,
            glossaryEntry: entry,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onAccept: (payload) => Navigator.of(dialogContext).pop(payload),
          ),
        ),
      ),
    );
  }

  @override
  State<GlossaryEntryForm> createState() => _GlossaryEntryFormState();
}

/// Side length of the square color swatch.
const double _kSwatchSize = 150;

/// Corner radius of the color swatch.
const double _kSwatchRadius = 8;

/// Border width of the color swatch.
const double _kBorderWidth = 2;

/// Outer padding and the gap between the form body and its buttons.
const double _kPadding = 16;

/// Vertical gap between stacked form elements.
const double _kGap = 12;

/// Minimum tag-name length for the accept button to enable.
const int _kTagNameMin = 3;

/// Maximum tag-name length; also enforced while typing.
const int _kTagNameMax = 6;

/// Minimum description length for the accept button to enable.
const int _kDescriptionMin = 4;

/// Default fixed font size for the tag pill's label.
const double _kPillFontSize = 12;

/// Fits "0xAARRGGBB" (10 characters) inside [_kSwatchSize] including the
/// hex field's border and content padding.
const double _kHexFontSize = 18;

/// Upper-cases all input while preserving the caret position.
class _UpperCaseTextFormatter extends TextInputFormatter {
  const _UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _GlossaryEntryFormState extends State<GlossaryEntryForm> {
  /// Backs the tag-name field. Prefilled (upper-cased) when editing.
  late final TextEditingController _tagNameController;

  /// Backs the description field. Prefilled when editing.
  late final TextEditingController _descriptionController;

  /// Backs the read-only hex readout beneath the swatch.
  late final TextEditingController _hexController;

  /// Carries the pill's selection state across the widget-identity resets
  /// triggered by tag-name edits (see the [ValueKey] on the pill).
  bool _pillSelected = false;

  /// The swatch color, from [GlossaryEntryForm.color] (create) or the
  /// record's stored ARGB int (edit).
  Color get _color => widget.color ?? Color(widget.glossaryEntry!.color);

  @override
  void initState() {
    super.initState();
    _tagNameController = TextEditingController(
      text: widget.glossaryEntry?.tagName.toUpperCase() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.glossaryEntry?.description ?? '',
    );
    _hexController = TextEditingController(text: _hex);
    _tagNameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _tagNameController.dispose();
    _descriptionController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  /// Rebuilds so [_isValid], and the pill preview, track the fields.
  void _onFieldChanged() => setState(() {});

  /// Whether the accept button should be enabled: tag name within
  /// [_kTagNameMin]–[_kTagNameMax] characters and description at least
  /// [_kDescriptionMin] characters.
  bool get _isValid {
    final tagLength = _tagNameController.text.length;
    return tagLength >= _kTagNameMin &&
        tagLength <= _kTagNameMax &&
        _descriptionController.text.length >= _kDescriptionMin;
  }

  /// The swatch color as `0xAARRGGBB`.
  String get _hex =>
      '0x${_color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

  /// Assembles the accept payload and hands it to
  /// [GlossaryEntryForm.onAccept].
  void _handleAccept() {
    widget.onAccept(<String, Object>{
      GlossaryEntryForm.keyTagName: _tagNameController.text,
      GlossaryEntryForm.keyDescription: _descriptionController.text,
      GlossaryEntryForm.keyColor: _color.toARGB32(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outline;
    final inputStyle = theme.textTheme.bodyLarge;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: _kSwatchSize,
                  height: _kSwatchSize,
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.circular(_kSwatchRadius),
                    border: Border.all(
                      color: borderColor,
                      width: _kBorderWidth,
                    ),
                  ),
                ),
                const SizedBox(height: _kGap),
                SizedBox(
                  width: _kSwatchSize,
                  child: TextField(
                    controller: _hexController,
                    readOnly: true,
                    style: const TextStyle(fontSize: _kHexFontSize),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: _kPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _tagNameController,
                    autofocus: true,
                    style: inputStyle,
                    maxLength: _kTagNameMax,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      LengthLimitingTextInputFormatter(_kTagNameMax),
                      const _UpperCaseTextFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Tag Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: _kGap),
                  TextField(
                    controller: _descriptionController,
                    style: inputStyle,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: _kGap),
                  PillWidget(
                    // New widget identity when the label changes, so the
                    // pill resets its selection alongside its text.
                    key: ValueKey<String>(_tagNameController.text),
                    label: _tagNameController.text,
                    color: _color,
                    fontSize: widget.pillFontSize,
                    initialSelected: _pillSelected,
                    onSelected: (selected) => _pillSelected = selected,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: _kPadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _isValid ? _handleAccept : null,
              child: Text(widget.accept),
            ),
          ],
        ),
      ],
    );
  }
}
