// programs/widgetbook_workspace/lib/packages/border_caption/border_caption.usecase.dart

import 'package:border_caption/border_caption.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// Shared knobs
// ---------------------------------------------------------------------------

const _alignments = <String, AlignmentGeometry>{
  'centerStart': AlignmentDirectional.centerStart,
  'center': AlignmentDirectional.center,
  'centerEnd': AlignmentDirectional.centerEnd,
};

BorderPosition _positionKnob(BuildContext context) =>
    context.knobs.object.dropdown<BorderPosition>(
      label: 'borderPosition',
      options: BorderPosition.values,
      initialOption: BorderPosition.bottom,
      labelBuilder: (option) => option.name,
    );

AlignmentGeometry _alignmentKnob(
  BuildContext context, {
  required String initialOption,
}) {
  final selected = context.knobs.object.dropdown<String>(
    label: 'labelAlignment',
    options: _alignments.keys.toList(),
    initialOption: initialOption,
    labelBuilder: (option) => option,
  );
  return _alignments[selected]!;
}

double _insetKnob(BuildContext context) => context.knobs.double.slider(
  label: 'labelInset',
  initialValue: 16,
  min: 0,
  max: 64,
);

EdgeInsets _labelPaddingKnob(BuildContext context) {
  final horizontal = context.knobs.double.slider(
    label: 'labelPadding.horizontal',
    initialValue: 4,
    min: 0,
    max: 24,
  );
  final vertical = context.knobs.double.slider(
    label: 'labelPadding.vertical',
    initialValue: 0,
    min: 0,
    max: 24,
  );
  return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
}

TextStyle? _labelStyleKnob(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  final options = <String, TextStyle?>{
    'inherit': null,
    'labelSmall': textTheme.labelSmall,
    'labelLarge': textTheme.labelLarge,
    'titleMedium': textTheme.titleMedium,
    'titleLarge': textTheme.titleLarge,
    'bold primary': TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    ),
  };
  final selected = context.knobs.object.dropdown<String>(
    label: 'labelStyle',
    options: options.keys.toList(),
    initialOption: 'inherit',
    labelBuilder: (option) => option,
  );
  return options[selected];
}

Color? _backgroundColorKnob(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  final options = <String, Color?>{
    'scaffold (default)': null,
    'surface': scheme.surface,
    'surfaceContainer': scheme.surfaceContainer,
    'primaryContainer': scheme.primaryContainer,
    'mismatch (red)': Colors.red,
  };
  final selected = context.knobs.object.dropdown<String>(
    label: 'backgroundColor',
    options: options.keys.toList(),
    initialOption: 'scaffold (default)',
    labelBuilder: (option) => option,
  );
  return options[selected];
}

TextDirection _directionKnob(BuildContext context) =>
    context.knobs.object.dropdown<TextDirection>(
      label: 'Directionality',
      options: TextDirection.values,
      initialOption: TextDirection.ltr,
      labelBuilder: (option) => option.name,
    );

// ---------------------------------------------------------------------------
// Shared presentation
// ---------------------------------------------------------------------------

/// Centres [child] on the scaffold background and applies [textDirection].
class _Stage extends StatelessWidget {
  const _Stage({required this.child, this.textDirection = TextDirection.ltr});

  final Widget child;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: textDirection,
    child: Center(
      child: Padding(padding: const EdgeInsets.all(32), child: child),
    ),
  );
}

/// A bordered box that brings its own outline, for the general constructor.
class _BorderedContent extends StatelessWidget {
  const _BorderedContent({this.radius = 8});

  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outline),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: const Text('Some static stuff'),
  );
}

// ---------------------------------------------------------------------------
// General constructor
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Interactive', type: BorderCaption)
Widget interactiveBorderCaptionUseCase(BuildContext context) {
  final label = context.knobs.string(label: 'label', initialValue: 'some text');
  final radius = context.knobs.double.slider(
    label: 'child borderRadius',
    initialValue: 8,
    min: 0,
    max: 32,
  );

  return _Stage(
    textDirection: _directionKnob(context),
    child: BorderCaption(
      label: label,
      borderPosition: _positionKnob(context),
      labelAlignment: _alignmentKnob(context, initialOption: 'centerEnd'),
      labelInset: _insetKnob(context),
      labelStyle: _labelStyleKnob(context),
      labelPadding: _labelPaddingKnob(context),
      backgroundColor: _backgroundColorKnob(context),
      child: _BorderedContent(radius: radius),
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive child', type: BorderCaption)
Widget interactiveChildBorderCaptionUseCase(BuildContext context) => _Stage(
  child: BorderCaption(
    label: 'tap anywhere, even on me',
    labelAlignment: _alignmentKnob(context, initialOption: 'center'),
    borderPosition: _positionKnob(context),
    child: const _TapCounter(),
  ),
);

/// Proves the label never intercepts pointer events.
class _TapCounter extends StatefulWidget {
  const _TapCounter();

  @override
  State<_TapCounter> createState() => _TapCounterState();
}

class _TapCounterState extends State<_TapCounter> {
  var _taps = 0;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: () => setState(() => _taps++),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Text('Tapped $_taps time(s)'),
    ),
  );
}

@widgetbook.UseCase(name: 'Both borders', type: BorderCaption)
Widget bothBordersBorderCaptionUseCase(BuildContext context) => _Stage(
  child: BorderCaption(
    label: 'Title',
    borderPosition: BorderPosition.top,
    labelAlignment: AlignmentDirectional.centerStart,
    labelStyle: Theme.of(context).textTheme.titleSmall,
    child: const BorderCaption(
      label: 'some text',
      labelAlignment: AlignmentDirectional.center,
      child: _BorderedContent(),
    ),
  ),
);

@widgetbook.UseCase(name: 'Alignment gallery', type: BorderCaption)
Widget alignmentGalleryBorderCaptionUseCase(BuildContext context) {
  final direction = _directionKnob(context);

  return _Stage(
    textDirection: direction,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final position in BorderPosition.values)
          for (final entry in _alignments.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: 320,
                child: BorderCaption(
                  label: '${position.name} · ${entry.key}',
                  borderPosition: position,
                  labelAlignment: entry.value,
                  child: const _BorderedContent(),
                ),
              ),
            ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Long label', type: BorderCaption)
Widget longLabelBorderCaptionUseCase(BuildContext context) {
  final width = context.knobs.double.slider(
    label: 'child width',
    initialValue: 240,
    min: 80,
    max: 480,
  );

  return _Stage(
    child: SizedBox(
      width: width,
      child: const BorderCaption(
        label: 'A label that is considerably longer than its child',
        labelAlignment: AlignmentDirectional.center,
        child: _BorderedContent(),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'On a Card', type: BorderCaption)
Widget onACardBorderCaptionUseCase(BuildContext context) => const _Stage(
  child: BorderCaption(
    label: 'Card footer',
    labelAlignment: AlignmentDirectional.centerEnd,
    child: Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('A Card draws its own outline and elevation.'),
      ),
    ),
  ),
);

// ---------------------------------------------------------------------------
// Outlined constructor
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Outlined interactive', type: BorderCaption)
Widget outlinedInteractiveBorderCaptionUseCase(BuildContext context) {
  final label = context.knobs.string(label: 'label', initialValue: 'some text');
  final content = context.knobs.string(
    label: 'content',
    initialValue: 'Some static stuff',
  );
  final themeColor = context.knobs.boolean(
    label: 'borderColor = colorScheme.outline',
    initialValue: true,
  );
  final borderWidth = context.knobs.double.slider(
    label: 'borderWidth',
    initialValue: 1,
    min: 0.5,
    max: 8,
  );
  final borderRadius = context.knobs.double.slider(
    label: 'borderRadius',
    initialValue: 8,
    min: 0,
    max: 32,
  );
  final padding = context.knobs.double.slider(
    label: 'padding',
    initialValue: 16,
    min: 0,
    max: 48,
  );

  return _Stage(
    textDirection: _directionKnob(context),
    child: BorderCaption.outlined(
      label: label,
      borderPosition: _positionKnob(context),
      labelAlignment: _alignmentKnob(context, initialOption: 'centerStart'),
      labelInset: _insetKnob(context),
      labelStyle: _labelStyleKnob(context),
      labelPadding: _labelPaddingKnob(context),
      backgroundColor: _backgroundColorKnob(context),
      borderColor: themeColor
          ? Theme.of(context).colorScheme.outline
          : const Color(0xFF000000),
      borderWidth: borderWidth,
      borderRadius: BorderRadius.circular(borderRadius),
      padding: EdgeInsets.all(padding),
      child: Text(content),
    ),
  );
}

@widgetbook.UseCase(name: 'Outlined form section', type: BorderCaption)
Widget outlinedFormSectionBorderCaptionUseCase(BuildContext context) => _Stage(
  child: SizedBox(
    width: 360,
    child: BorderCaption.outlined(
      label: 'Account',
      borderPosition: BorderPosition.top,
      labelStyle: Theme.of(context).textTheme.labelLarge,
      borderColor: Theme.of(context).colorScheme.outline,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(decoration: InputDecoration(labelText: 'Username')),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
        ],
      ),
    ),
  ),
);
