// packages/sincewhen_screens/lib/src/widgets/since_when_mini_text_column.dart

import 'package:custom_widgets/custom_widgets.dart' show ExpandingTextField;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sincewhen_screens/src/util/sincewhen_mini_constants.dart'
    show SinceWhenMiniDimensions;

/// {@template since_when_mini_text_column}
/// The text-entry (right) column of the since-when-mini screen:
/// content, tldr, and metadata as [ExpandingTextField]s, in that
/// order.
///
/// Text truth lives in the supplied controllers; every keystroke is
/// reported through the matching callback so the owner can mirror it
/// into state. The content field carries [contentFocusNode] so the
/// screen can grant it focus in create and edit alike.
///
/// Owns its own vertical scrolling: the fields at maximum growth can
/// exceed the available height once keyboard insets apply, and that
/// overflow is this column's concern, not its parent's.
///
/// No bloc dependencies: pump with three controllers, a focus node,
/// and stub callbacks to test in isolation.
/// {@endtemplate}
class SinceWhenMiniTextColumn extends StatelessWidget {
  /// {@macro since_when_mini_text_column}
  const SinceWhenMiniTextColumn({
    required this.contentController,
    required this.tldrController,
    required this.metaDataController,
    required this.contentFocusNode,
    required this.onContentChanged,
    required this.onTldrChanged,
    required this.onMetaDataChanged,
    super.key,
  });

  /// Hint shown in the empty content field.
  static const String contentHint = 'Content (required)';

  /// Hint shown in the empty tldr field.
  static const String tldrHint = 'tl;dr';

  /// Hint shown in the empty metadata field.
  static const String metaDataHint = 'Metadata';

  /// Controller owning the content text.
  final TextEditingController contentController;

  /// Controller owning the tldr text.
  final TextEditingController tldrController;

  /// Controller owning the metadata text.
  final TextEditingController metaDataController;

  /// Focus node attached to the content field.
  final FocusNode contentFocusNode;

  /// Called on every content keystroke.
  final ValueChanged<String> onContentChanged;

  /// Called on every tldr keystroke.
  final ValueChanged<String> onTldrChanged;

  /// Called on every metadata keystroke.
  final ValueChanged<String> onMetaDataChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExpandingTextField(
            controller: contentController,
            focusNode: contentFocusNode,
            onChanged: onContentChanged,
            hintText: contentHint,
            minLines: SinceWhenMiniDimensions.contentMinLines,
            maxLines: SinceWhenMiniDimensions.contentMaxLines,
          ),
          const Gap(SinceWhenMiniDimensions.textFieldGap),
          ExpandingTextField(
            controller: tldrController,
            onChanged: onTldrChanged,
            hintText: tldrHint,
            minLines: SinceWhenMiniDimensions.optionalFieldMinLines,
            maxLines: SinceWhenMiniDimensions.optionalFieldMaxLines,
          ),
          const Gap(SinceWhenMiniDimensions.textFieldGap),
          ExpandingTextField(
            controller: metaDataController,
            onChanged: onMetaDataChanged,
            hintText: metaDataHint,
            minLines: SinceWhenMiniDimensions.optionalFieldMinLines,
            maxLines: SinceWhenMiniDimensions.optionalFieldMaxLines,
          ),
        ],
      ),
    );
  }
}
