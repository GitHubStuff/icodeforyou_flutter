// programs/widgetbook_workspace/lib/packages/ext_string/ext_string.usecase.dart

import 'package:ext_string/ext_string.dart' show ExtString;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// pixelSize
// ---------------------------------------------------------------------------

/// Showcase for [ExtString.pixelSize].
///
/// Renders [text] with the real [Text] widget and overlays a box sized to
/// the result of [ExtString.pixelSize], so the measurement can be compared
/// visually with the framework's own layout.
class PixelSizeShowcase extends StatelessWidget {
  /// Creates a showcase that measures and renders [text] with [style].
  const PixelSizeShowcase({
    required this.text,
    required this.style,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.start,
    this.textScaler = TextScaler.noScaling,
    this.maxWidth = double.infinity,
    this.maxLines,
    super.key,
  });

  /// The string being measured.
  final String text;

  /// The style applied to the whole string.
  final TextStyle style;

  /// The base directionality used for layout.
  final TextDirection textDirection;

  /// How lines are aligned within the available width.
  final TextAlign textAlign;

  /// The scaling applied to font sizes.
  final TextScaler textScaler;

  /// The width at which the text wraps.
  final double maxWidth;

  /// An optional cap on the number of lines.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final size = text.pixelSize(
      style: style,
      textDirection: textDirection,
      textAlign: textAlign,
      textScaler: textScaler,
      maxWidth: maxWidth,
      maxLines: maxLines,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            SizedBox(
              width: size.width,
              height: size.height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.error),
                  color: colorScheme.errorContainer.withValues(alpha: 0.25),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Text(
                text,
                style: style,
                textDirection: textDirection,
                textAlign: textAlign,
                textScaler: textScaler,
                maxLines: maxLines,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'pixelSize → '
          '${size.width.toStringAsFixed(1)} × '
          '${size.height.toStringAsFixed(1)} logical px',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Interactive use case for [ExtString.pixelSize] with every parameter
/// exposed as a knob.
@widgetbook.UseCase(name: 'Interactive', type: PixelSizeShowcase)
Widget buildPixelSizeInteractiveUseCase(BuildContext context) {
  final text = context.knobs.string(
    label: 'Text',
    initialValue: 'The quick brown fox jumps over the lazy dog',
  );
  final fontSize = context.knobs.double.slider(
    label: 'Font size',
    initialValue: 16,
    min: 8,
    max: 64,
  );
  final fontWeight = context.knobs.object.dropdown<FontWeight>(
    label: 'Font weight',
    options: FontWeight.values,
    initialOption: FontWeight.w400,
    labelBuilder: (weight) => 'w${weight.value}',
  );
  final letterSpacing = context.knobs.double.slider(
    label: 'Letter spacing',
    initialValue: 0,
    min: -2,
    max: 8,
  );
  final textDirection = context.knobs.object.dropdown<TextDirection>(
    label: 'Text direction',
    options: TextDirection.values,
    initialOption: TextDirection.ltr,
    labelBuilder: (direction) => direction.name,
  );
  final textAlign = context.knobs.object.dropdown<TextAlign>(
    label: 'Text align',
    options: TextAlign.values,
    initialOption: TextAlign.start,
    labelBuilder: (align) => align.name,
  );
  final textScale = context.knobs.double.slider(
    label: 'Text scale',
    initialValue: 1,
    min: 0.5,
    max: 3,
  );
  final constrainWidth = context.knobs.boolean(
    label: 'Constrain width',
    initialValue: true,
  );
  final maxWidth = context.knobs.double.slider(
    label: 'Max width',
    initialValue: 240,
    min: 40,
    max: 800,
  );
  final maxLines = context.knobs.intOrNull.slider(
    label: 'Max lines',
    min: 1,
    max: 10,
  );

  return Padding(
    padding: const EdgeInsets.all(24),
    child: PixelSizeShowcase(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ),
      textDirection: textDirection,
      textAlign: textAlign,
      textScaler: TextScaler.linear(textScale),
      maxWidth: constrainWidth ? maxWidth : double.infinity,
      maxLines: maxLines,
    ),
  );
}

/// Gallery of fixed [ExtString.pixelSize] scenarios covering single-line,
/// wrapped, capped, empty, right-to-left, and scaled text.
@widgetbook.UseCase(name: 'Preset Gallery', type: PixelSizeShowcase)
Widget buildPixelSizePresetGalleryUseCase(BuildContext context) {
  const baseStyle = TextStyle(fontSize: 16);
  const boldStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  const wrappingText =
      'A somewhat longer label that will wrap onto '
      'several lines when constrained';

  return const SingleChildScrollView(
    padding: EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GalleryEntry(
          title: 'Single line, unconstrained',
          child: PixelSizeShowcase(text: 'Sign in', style: baseStyle),
        ),
        _GalleryEntry(
          title: 'Single line, bold',
          child: PixelSizeShowcase(text: 'Sign in', style: boldStyle),
        ),
        _GalleryEntry(
          title: 'Wrapped to 160 px',
          child: PixelSizeShowcase(
            text: wrappingText,
            style: baseStyle,
            maxWidth: 160,
          ),
        ),
        _GalleryEntry(
          title: 'Wrapped to 160 px, max two lines',
          child: PixelSizeShowcase(
            text: wrappingText,
            style: baseStyle,
            maxWidth: 160,
            maxLines: 2,
          ),
        ),
        _GalleryEntry(
          title: 'Explicit line breaks',
          child: PixelSizeShowcase(
            text: 'First line\nSecond, longer line\nThird',
            style: baseStyle,
          ),
        ),
        _GalleryEntry(
          title: 'Empty string (height of one line, zero width)',
          child: PixelSizeShowcase(text: '', style: baseStyle),
        ),
        _GalleryEntry(
          title: 'Right-to-left',
          child: PixelSizeShowcase(
            text: 'مرحبا بالعالم',
            style: baseStyle,
            textDirection: TextDirection.rtl,
          ),
        ),
        _GalleryEntry(
          title: 'Text scaled ×2',
          child: PixelSizeShowcase(
            text: 'Sign in',
            style: baseStyle,
            textScaler: TextScaler.linear(2),
          ),
        ),
        _GalleryEntry(
          title: 'Wide letter spacing',
          child: PixelSizeShowcase(
            text: 'SPACED OUT',
            style: TextStyle(fontSize: 16, letterSpacing: 4),
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// toMicrosecondsOrNull
// ---------------------------------------------------------------------------

/// Showcase for [ExtString.toMicrosecondsOrNull].
///
/// Displays the parsed microsecond value for [input], or `null` when parsing
/// fails, alongside the round-tripped UTC [DateTime] for sanity checking.
class MicrosecondsShowcase extends StatelessWidget {
  /// Creates a showcase that parses [input].
  const MicrosecondsShowcase({required this.input, super.key});

  /// The string handed to [ExtString.toMicrosecondsOrNull].
  final String input;

  @override
  Widget build(BuildContext context) {
    final micros = input.toMicrosecondsOrNull();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final roundTrip = micros == null
        ? null
        : DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("'$input'", style: textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          'toMicrosecondsOrNull → ${micros ?? 'null'}',
          style: textTheme.titleMedium?.copyWith(
            color: micros == null ? colorScheme.error : colorScheme.primary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (roundTrip != null)
          Text(
            'round trip (UTC) → ${roundTrip.toIso8601String()}',
            style: textTheme.bodySmall,
          ),
      ],
    );
  }
}

/// Interactive use case for [ExtString.toMicrosecondsOrNull] driven by a
/// free-text knob.
@widgetbook.UseCase(name: 'Interactive', type: MicrosecondsShowcase)
Widget buildMicrosecondsInteractiveUseCase(BuildContext context) {
  final input = context.knobs.string(
    label: 'Input',
    initialValue: '2024-01-01T00:00:00Z',
  );

  return Padding(
    padding: const EdgeInsets.all(24),
    child: MicrosecondsShowcase(input: input),
  );
}

/// Gallery of fixed [ExtString.toMicrosecondsOrNull] inputs covering every
/// documented accepted format, pre-epoch values, and failure cases.
@widgetbook.UseCase(name: 'Preset Gallery', type: MicrosecondsShowcase)
Widget buildMicrosecondsPresetGalleryUseCase(BuildContext context) {
  const inputs = <String>[
    '2024-01-01',
    '2024-01-01T13:45:00',
    '2024-01-01T13:45:00Z',
    '2024-01-01T13:45:00+02:00',
    '2024-01-01 13:45:00.123456',
    '1970-01-01T00:00:00Z',
    '1969-12-31T23:59:59Z',
    ' 2024-01-01 ',
    'not a date',
    '',
  ];

  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final input in inputs)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: MicrosecondsShowcase(input: input),
          ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

/// A titled gallery row used by the preset galleries above.
class _GalleryEntry extends StatelessWidget {
  const _GalleryEntry({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
