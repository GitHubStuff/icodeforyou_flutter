// widgetbook_workspace/lib/ext_duration/ext_duration.usecase.dart

import 'package:ext_duration/ext_duration.dart' show DurationUnits, ExtDuration;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// Duration.format
// ---------------------------------------------------------------------------

/// Showcase for [ExtDuration.format].
///
/// Renders the [pattern], the [duration] it is applied to, and the formatted
/// result. A [FormatException] raised by an invalid pattern is caught and
/// shown in the error colour instead of crashing the Widgetbook.
class DurationFormatShowcase extends StatelessWidget {
  /// Creates a showcase that formats [duration] with [pattern].
  const DurationFormatShowcase({
    required this.pattern,
    required this.duration,
    super.key,
  });

  /// The `sprintf`-style pattern handed to [ExtDuration.format].
  final String pattern;

  /// The duration being formatted.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    String? result;
    FormatException? error;
    try {
      result = duration.format(pattern);
    } on FormatException catch (e) {
      error = e;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("pattern  '$pattern'", style: textTheme.bodySmall),
        Text(
          'duration $duration'
          '${duration.isNegative ? ' (negative)' : ''}',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        if (result != null)
          Text(
            result,
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.primary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        if (error != null)
          Text(
            'FormatException: ${error.message}'
            '${error.offset == null ? '' : ' (offset ${error.offset})'}',
            style: textTheme.titleSmall?.copyWith(color: colorScheme.error),
          ),
      ],
    );
  }
}

/// Interactive use case for [ExtDuration.format] with a free-text pattern
/// knob and one slider per [Duration] component.
@widgetbook.UseCase(name: 'Interactive', type: DurationFormatShowcase)
Widget buildDurationFormatInteractiveUseCase(BuildContext context) {
  final pattern = context.knobs.string(
    label: 'Pattern',
    initialValue: '%n%d d %02h:%02m:%02s.%03l',
  );
  final days = context.knobs.int.slider(
    label: 'Days',
    initialValue: 1,
    min: 0,
    max: 30,
  );
  final hours = context.knobs.int.slider(
    label: 'Hours',
    initialValue: 2,
    min: 0,
    max: 47,
  );
  final minutes = context.knobs.int.slider(
    label: 'Minutes',
    initialValue: 5,
    min: 0,
    max: 119,
  );
  final seconds = context.knobs.int.slider(
    label: 'Seconds',
    initialValue: 9,
    min: 0,
    max: 119,
  );
  final milliseconds = context.knobs.int.slider(
    label: 'Milliseconds',
    initialValue: 42,
    min: 0,
    max: 1999,
  );
  final microseconds = context.knobs.int.slider(
    label: 'Microseconds',
    initialValue: 0,
    min: 0,
    max: 1999,
  );
  final negative = context.knobs.boolean(
    label: 'Negative',
    initialValue: false,
  );

  final magnitude = Duration(
    days: days,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
    microseconds: microseconds,
  );

  return Padding(
    padding: const EdgeInsets.all(24),
    child: DurationFormatShowcase(
      pattern: pattern,
      duration: negative ? -magnitude : magnitude,
    ),
  );
}

/// Gallery of fixed [ExtDuration.format] scenarios: every documented
/// example, each conversion in isolation, flag and width behaviour, and the
/// two [FormatException] cases.
@widgetbook.UseCase(name: 'Preset Gallery', type: DurationFormatShowcase)
Widget buildDurationFormatPresetGalleryUseCase(BuildContext context) {
  const sample = Duration(hours: 26, minutes: 5, seconds: 9, milliseconds: 42);
  // Unary minus on Duration is not a const operation, so the negative
  // fixture is spelled out to keep the gallery tree fully const.
  const negativeSample = Duration(
    hours: -26,
    minutes: -5,
    seconds: -9,
    milliseconds: -42,
  );
  const micro = Duration(milliseconds: 1, microseconds: 7);

  return const SingleChildScrollView(
    padding: EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GallerySection(
          title: 'Documentation examples',
          children: [
            DurationFormatShowcase(
              pattern: '%02H:%02m:%02s',
              duration: sample,
            ),
            DurationFormatShowcase(
              pattern: '%d day(s) %02h:%02m',
              duration: sample,
            ),
            DurationFormatShowcase(pattern: '%S.%03l s', duration: sample),
            DurationFormatShowcase(pattern: '%n%M min', duration: sample),
            DurationFormatShowcase(
              pattern: '%n%M min',
              duration: negativeSample,
            ),
            DurationFormatShowcase(pattern: '100%%', duration: sample),
          ],
        ),
        _GallerySection(
          title: 'Each conversion in isolation',
          children: [
            DurationFormatShowcase(pattern: '%%d → %d', duration: sample),
            DurationFormatShowcase(pattern: '%%h → %h', duration: sample),
            DurationFormatShowcase(pattern: '%%H → %H', duration: sample),
            DurationFormatShowcase(pattern: '%%m → %m', duration: sample),
            DurationFormatShowcase(pattern: '%%M → %M', duration: sample),
            DurationFormatShowcase(pattern: '%%s → %s', duration: sample),
            DurationFormatShowcase(pattern: '%%S → %S', duration: sample),
            DurationFormatShowcase(pattern: '%%l → %l', duration: sample),
            DurationFormatShowcase(pattern: '%%L → %L', duration: sample),
            DurationFormatShowcase(pattern: '%%u → %u', duration: micro),
            DurationFormatShowcase(pattern: '%%U → %U', duration: micro),
            DurationFormatShowcase(
              pattern: "%%n → '%n'",
              duration: negativeSample,
            ),
          ],
        ),
        _GallerySection(
          title: 'Width and flags',
          children: [
            DurationFormatShowcase(pattern: '[%5S]', duration: sample),
            DurationFormatShowcase(pattern: '[%06S]', duration: sample),
            DurationFormatShowcase(pattern: '[%-6S]', duration: sample),
            DurationFormatShowcase(pattern: '[%-06S]', duration: sample),
            DurationFormatShowcase(
              pattern: '[%3h][%03h][%-3h]',
              duration: sample,
            ),
          ],
        ),
        _GallerySection(
          title: 'Invalid patterns',
          children: [
            DurationFormatShowcase(pattern: 'elapsed %', duration: sample),
            DurationFormatShowcase(pattern: '%02x', duration: sample),
          ],
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// DurationUnit
// ---------------------------------------------------------------------------

/// Showcase for [DurationUnit].
///
/// Displays [DurationUnit.inMicroseconds] for [unit] and the [Duration]
/// produced by [DurationUnit.times] for [count].
class DurationUnitShowcase extends StatelessWidget {
  /// Creates a showcase for [unit] multiplied by [count].
  const DurationUnitShowcase({
    required this.unit,
    required this.count,
    super.key,
  });

  /// The unit under inspection.
  final DurationUnits unit;

  /// The multiplier passed to [DurationUnit.times].
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final product = unit.times(count);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DurationUnit.${unit.name}', style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'inMicroseconds → ${unit.inMicroseconds}',
          style: textTheme.bodyMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          'times($count) → $product',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Interactive use case for [DurationUnit] with a unit dropdown and a count
/// slider.
@widgetbook.UseCase(name: 'Interactive', type: DurationUnitShowcase)
Widget buildDurationUnitInteractiveUseCase(BuildContext context) {
  final unit = context.knobs.object.dropdown<DurationUnits>(
    label: 'Unit',
    options: DurationUnits.values,
    initialOption: DurationUnits.minutes,
    labelBuilder: (unit) => unit.name,
  );
  final count = context.knobs.int.slider(
    label: 'Count',
    initialValue: 90,
    min: -100,
    max: 1000,
  );

  return Padding(
    padding: const EdgeInsets.all(24),
    child: DurationUnitShowcase(unit: unit, count: count),
  );
}

/// Gallery of every [DurationUnit] at a fixed count, so the microsecond
/// scale of each unit can be compared at a glance.
@widgetbook.UseCase(name: 'Preset Gallery', type: DurationUnitShowcase)
Widget buildDurationUnitPresetGalleryUseCase(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final unit in DurationUnits.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: DurationUnitShowcase(unit: unit, count: 3),
          ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

/// A titled group of showcases used by the preset galleries above.
class _GallerySection extends StatelessWidget {
  const _GallerySection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          for (final child in children)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: child,
            ),
        ],
      ),
    );
  }
}
