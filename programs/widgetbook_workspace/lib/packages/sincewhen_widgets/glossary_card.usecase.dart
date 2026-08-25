import 'package:flutter/material.dart';
import 'package:sincewhen_models/sincewhen_models.dart' show GlossaryItem;
import 'package:sincewhen_widgets/sincewhen_widgets.dart' show GlossaryCard;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// {@template glossary_card_usecase}
/// Widgetbook use-case demonstrating [GlossaryCard] with configurable
/// knobs for [tag], [colorArgb], and [descr].
/// {@endtemplate}
@widgetbook.UseCase(
  name: 'Default',
  type: GlossaryCard,
)
Widget defaultGlossaryCard(BuildContext context) {
  final tag = context.knobs.string(
    label: 'Tag',
    initialValue: 'Urgent',
    description: 'The tag name displayed in the top right.',
  );

  final descr = context.knobs.string(
    label: 'Description',
    initialValue: 'Items that require immediate attention or quick resolution.',
    description: 'The detailed explanation of what the tag represents.',
  );

  final color = context.knobs.color(
    label: 'Color',
    initialValue: const Color(0xFFE53935), // Red
    description: 'The color of the left swatch box.',
  );

  final mockItem = GlossaryItem(
    id: 1,
    createdTimestamp: DateTime.now().millisecondsSinceEpoch,
    tag: tag,
    colorArgb: color.toARGB32(),
    descr: descr,
  );

  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: GlossaryCard(
        item: mockItem,
      ),
    ),
  );
}
