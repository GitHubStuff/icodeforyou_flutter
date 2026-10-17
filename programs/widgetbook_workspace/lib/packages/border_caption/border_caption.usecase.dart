// widgetbook_workspace/lib/border_caption/border_caption.usecase.dart
import 'package:border_caption/border_caption.dart'
    show BorderCaption, LabelBorder;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Alignments offered by the Interactive use case's dropdown.
const _alignments = <AlignmentDirectional>[
  AlignmentDirectional.centerStart,
  AlignmentDirectional.center,
  AlignmentDirectional.centerEnd,
];

String _alignmentLabel(AlignmentDirectional alignment) => switch (alignment) {
  AlignmentDirectional.centerStart => 'Start',
  AlignmentDirectional.center => 'Center',
  AlignmentDirectional.centerEnd => 'End',
  _ => alignment.toString(),
};

String _labelBorderLabel(LabelBorder border) => switch (border) {
  LabelBorder.top => 'Top',
  LabelBorder.bottom => 'Bottom',
};

/// Content shared by every use case so the presets differ only in the
/// [BorderCaption] parameters under inspection.
Widget _content() => const Padding(
  padding: EdgeInsets.all(16),
  child: Text('Some static stuff'),
);

@widgetbook.UseCase(
  name: 'Interactive',
  type: BorderCaption,
  path: '[Packages]/border_caption',
)
Widget interactiveBorderCaption(BuildContext context) {
  final label = context.knobs.string(
    label: 'label',
    initialValue: 'some text',
  );
  final labelBorder = context.knobs.object.dropdown<LabelBorder>(
    label: 'labelBorder',
    options: LabelBorder.values,
    initialOption: LabelBorder.bottom,
    labelBuilder: _labelBorderLabel,
  );
  final labelAlignment = context.knobs.object.dropdown<AlignmentDirectional>(
    label: 'labelAlignment',
    options: _alignments,
    initialOption: AlignmentDirectional.centerStart,
    labelBuilder: _alignmentLabel,
  );
  final labelInset = context.knobs.double.slider(
    label: 'labelInset',
    initialValue: 16,
    max: 64,
  );
  final labelHorizontalPadding = context.knobs.double.slider(
    label: 'labelPadding (horizontal)',
    initialValue: 4,
    max: 24,
  );
  final labelVerticalPadding = context.knobs.double.slider(
    label: 'labelPadding (vertical)',
    max: 24,
  );
  final labelFontSize = context.knobs.double.slider(
    label: 'labelStyle.fontSize',
    initialValue: 14,
    min: 8,
    max: 32,
  );
  final useThemeBackground = context.knobs.boolean(
    label: 'backgroundColor from Theme',
    initialValue: true,
  );
  final backgroundColor = context.knobs.color(
    label: 'backgroundColor',
    initialValue: Theme.of(context).scaffoldBackgroundColor,
  );
  final borderColor = context.knobs.color(
    label: 'borderColor',
    initialValue: Theme.of(context).colorScheme.outline,
  );
  final borderWidth = context.knobs.double.slider(
    label: 'borderWidth',
    initialValue: 1,
    min: 1,
    max: 8,
  );
  final borderRadius = context.knobs.double.slider(
    label: 'borderRadius',
    initialValue: 8,
    max: 32,
  );

  return Center(
    child: ColoredBox(
      color: useThemeBackground
          ? Theme.of(context).scaffoldBackgroundColor
          : backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: BorderCaption.outlined(
          label: label,
          labelBorder: labelBorder,
          labelAlignment: labelAlignment,
          labelInset: labelInset,
          labelStyle: TextStyle(fontSize: labelFontSize),
          labelPadding: EdgeInsets.symmetric(
            horizontal: labelHorizontalPadding,
            vertical: labelVerticalPadding,
          ),
          backgroundColor: useThemeBackground ? null : backgroundColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
          borderRadius: BorderRadius.circular(borderRadius),
          padding: EdgeInsets.zero,
          child: _content(),
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Gallery',
  type: BorderCaption,
  path: '[Packages]/border_caption',
)
Widget galleryBorderCaption(BuildContext context) {
  final outline = Theme.of(context).colorScheme.outline;

  return SingleChildScrollView(
    padding: const EdgeInsets.all(32),
    child: Wrap(
      spacing: 32,
      runSpacing: 32,
      children: [
        BorderCaption.outlined(
          label: 'Bottom · Start',
          borderColor: outline,
          padding: EdgeInsets.zero,
          child: _content(),
        ),
        BorderCaption.outlined(
          label: 'Bottom · Center',
          labelAlignment: AlignmentDirectional.center,
          borderColor: outline,
          padding: EdgeInsets.zero,
          child: _content(),
        ),
        BorderCaption.outlined(
          label: 'Bottom · End',
          labelAlignment: AlignmentDirectional.centerEnd,
          borderColor: outline,
          padding: EdgeInsets.zero,
          child: _content(),
        ),
        BorderCaption.outlined(
          label: 'Top · Start',
          labelBorder: LabelBorder.top,
          borderColor: outline,
          padding: EdgeInsets.zero,
          child: _content(),
        ),
        BorderCaption.outlined(
          label: 'Top · Center',
          labelBorder: LabelBorder.top,
          labelAlignment: AlignmentDirectional.center,
          borderColor: outline,
          padding: EdgeInsets.zero,
          child: _content(),
        ),
        BorderCaption.outlined(
          label: 'Top · End',
          labelBorder: LabelBorder.top,
          labelAlignment: AlignmentDirectional.centerEnd,
          borderColor: outline,
          padding: EdgeInsets.zero,
          child: _content(),
        ),
        BorderCaption.outlined(
          label: 'Thick border',
          labelAlignment: AlignmentDirectional.center,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          borderColor: outline,
          borderWidth: 4,
          padding: EdgeInsets.zero,
          child: _content(),
        ),
        BorderCaption.outlined(
          label: 'Square corners',
          labelInset: 4,
          borderColor: outline,
          borderRadius: BorderRadius.zero,
          padding: EdgeInsets.zero,
          child: _content(),
        ),
        BorderCaption.outlined(
          label: 'Styled label',
          labelAlignment: AlignmentDirectional.center,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
          borderColor: outline,
          padding: EdgeInsets.zero,
          child: _content(),
        ),
        Directionality(
          textDirection: TextDirection.rtl,
          child: BorderCaption.outlined(
            label: 'RTL · Start',
            borderColor: outline,
            padding: EdgeInsets.zero,
            child: _content(),
          ),
        ),
        BorderCaption(
          label: 'Custom child (Card)',
          labelAlignment: AlignmentDirectional.center,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Card(
            margin: EdgeInsets.zero,
            child: _content(),
          ),
        ),
      ],
    ),
  );
}
