// programs/widgetbook_workspace/lib/packages/ext_duration/ext_duration.usecase.dart

import 'package:ext_duration/ext_duration.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// Shared knobs
// ---------------------------------------------------------------------------

/// Builds the subject [Duration] from one slider per unit plus a sign toggle.
Duration _durationKnob(BuildContext context) {
  final days = context.knobs.int.slider(
    label: 'Days',
    initialValue: 1,
    min: 0,
    max: 400,
  );
  final hours = context.knobs.int.slider(
    label: 'Hours',
    initialValue: 2,
    min: 0,
    max: 23,
  );
  final minutes = context.knobs.int.slider(
    label: 'Minutes',
    initialValue: 5,
    min: 0,
    max: 59,
  );
  final seconds = context.knobs.int.slider(
    label: 'Seconds',
    initialValue: 9,
    min: 0,
    max: 59,
  );
  final milliseconds = context.knobs.int.slider(
    label: 'Milliseconds',
    initialValue: 42,
    min: 0,
    max: 999,
  );
  final microseconds = context.knobs.int.slider(
    label: 'Microseconds',
    initialValue: 7,
    min: 0,
    max: 999,
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
  return negative ? -magnitude : magnitude;
}

// ---------------------------------------------------------------------------
// Shared presentation
// ---------------------------------------------------------------------------

class _Mono extends StatelessWidget {
  const _Mono(this.text, {this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontFamily: 'monospace',
      fontFeatures: const [FontFeature.tabularFigures()],
      color: color,
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 220, child: _Mono(label)),
        Expanded(child: value),
      ],
    ),
  );
}

class _Page extends StatelessWidget {
  const _Page({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: children,
  );
}

/// Renders a formatted result, or the [FormatException] it raised.
class _FormatResult extends StatelessWidget {
  const _FormatResult({required this.duration, required this.pattern});

  final Duration duration;
  final String pattern;

  @override
  Widget build(BuildContext context) {
    try {
      return _Mono(duration.format(pattern));
    } on FormatException catch (e) {
      return _Mono(
        '${e.message} (offset ${e.offset})',
        color: Theme.of(context).colorScheme.error,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// ExtDuration.format
// ---------------------------------------------------------------------------

/// Showcases `Duration.format(pattern)`.
class DurationFormatShowcase extends StatelessWidget {
  const DurationFormatShowcase({
    required this.duration,
    required this.pattern,
    super.key,
  });

  final Duration duration;
  final String pattern;

  static const _referencePatterns = <String, String>{
    'Clock': '%02H:%02m:%02s',
    'Day and clock': '%d day(s) %02h:%02m',
    'Seconds with millis': '%S.%03l s',
    'Signed minutes': '%n%M min',
    'Micro precision': '%n%S.%03l%03u',
    'Right-aligned': '[%8S]',
    'Left-aligned': '[%-8S]',
    'Zero-padded total hours': '%05H h',
    'Literal percent': '%d%% of a day',
  };

  @override
  Widget build(BuildContext context) => _Page(
    children: [
      _Section(
        title: 'Input',
        child: Column(
          children: [
            _Row(label: 'duration', value: _Mono('$duration')),
            _Row(label: 'pattern', value: _Mono(pattern)),
          ],
        ),
      ),
      _Section(
        title: 'Output',
        child: _FormatResult(duration: duration, pattern: pattern),
      ),
      _Section(
        title: 'Reference patterns',
        child: Column(
          children: [
            for (final entry in _referencePatterns.entries)
              _Row(
                label: '${entry.key}\n${entry.value}',
                value: _FormatResult(
                  duration: duration,
                  pattern: entry.value,
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Interactive', type: DurationFormatShowcase)
Widget interactiveDurationFormatShowcaseUseCase(BuildContext context) {
  final pattern = context.knobs.string(
    label: 'Pattern',
    initialValue: '%n%d %02h:%02m:%02s.%03l',
    description: 'sprintf-style; try %x to see the FormatException.',
  );

  return DurationFormatShowcase(
    duration: _durationKnob(context),
    pattern: pattern,
  );
}

// ---------------------------------------------------------------------------
// Conversion reference
// ---------------------------------------------------------------------------

/// One row per `DurationFormatter` conversion, evaluated for [duration].
class ConversionReference extends StatelessWidget {
  const ConversionReference({required this.duration, super.key});

  final Duration duration;

  static const _conversions = <String, String>{
    '%d': 'whole days',
    '%h': 'hours within the day (0–23)',
    '%H': 'total hours',
    '%m': 'minutes within the hour (0–59)',
    '%M': 'total minutes',
    '%s': 'seconds within the minute (0–59)',
    '%S': 'total seconds',
    '%l': 'milliseconds within the second (0–999)',
    '%L': 'total milliseconds',
    '%u': 'microseconds within the millisecond (0–999)',
    '%U': 'total microseconds',
    '%n': 'sign (- or empty)',
    '%%': 'literal percent',
  };

  static const _flags = <String, String>{
    '%5S': 'width 5, space-padded',
    '%05S': 'width 5, zero-padded',
    '%-5S|': 'width 5, left-aligned',
    '%-05S|': '- overrides 0',
  };

  @override
  Widget build(BuildContext context) => _Page(
    children: [
      _Section(
        title: 'Subject',
        child: _Mono('$duration'),
      ),
      _Section(
        title: 'Conversions',
        child: Column(
          children: [
            for (final entry in _conversions.entries)
              _Row(
                label: '${entry.key}  ${entry.value}',
                value: _Mono("'${duration.format(entry.key)}'"),
              ),
          ],
        ),
      ),
      _Section(
        title: 'Flags and width',
        child: Column(
          children: [
            for (final entry in _flags.entries)
              _Row(
                label: '${entry.key}  ${entry.value}',
                value: _Mono("'${duration.format(entry.key)}'"),
              ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'All conversions', type: ConversionReference)
Widget allConversionsConversionReferenceUseCase(BuildContext context) =>
    ConversionReference(duration: _durationKnob(context));

// ---------------------------------------------------------------------------
// ExtDuration.composeFormat
// ---------------------------------------------------------------------------

/// Showcases `composeFormat` — the template it builds and what that
/// template renders to via `format`.
class ComposeFormatShowcase extends StatelessWidget {
  const ComposeFormatShowcase({
    required this.duration,
    required this.showPlusSign,
    required this.showLeaderZero,
    required this.padHours,
    super.key,
  });

  final Duration duration;
  final bool showPlusSign;
  final bool showLeaderZero;
  final bool padHours;

  static const _ladder = <String, Duration>{
    'zero': Duration.zero,
    'seconds': Duration(seconds: 9),
    'minutes': Duration(minutes: 5, seconds: 9),
    'hours': Duration(hours: 1, minutes: 5, seconds: 9),
    'days': Duration(days: 2, hours: 3),
    'negative seconds': Duration(seconds: -9),
    'negative days': Duration(days: -2, hours: -3),
  };

  String _template(Duration d) => d.composeFormat(
    showPlusSign: showPlusSign,
    showLeaderZero: showLeaderZero,
    padHours: padHours,
  );

  @override
  Widget build(BuildContext context) {
    final template = _template(duration);

    return _Page(
      children: [
        _Section(
          title: 'Input',
          child: Column(
            children: [
              _Row(label: 'duration', value: _Mono('$duration')),
              _Row(label: 'showPlusSign', value: _Mono('$showPlusSign')),
              _Row(label: 'showLeaderZero', value: _Mono('$showLeaderZero')),
              _Row(label: 'padHours', value: _Mono('$padHours')),
            ],
          ),
        ),
        _Section(
          title: 'Template → rendered',
          child: Column(
            children: [
              _Row(label: 'composeFormat()', value: _Mono(template)),
              _Row(
                label: 'format(template)',
                value: _Mono(duration.format(template)),
              ),
            ],
          ),
        ),
        _Section(
          title: 'Leading-unit ladder (same flags)',
          child: Column(
            children: [
              for (final entry in _ladder.entries)
                _Row(
                  label: entry.key,
                  value: _Mono(
                    '${_template(entry.value).padRight(20)} '
                    '→ ${entry.value.format(_template(entry.value))}',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Interactive', type: ComposeFormatShowcase)
Widget interactiveComposeFormatShowcaseUseCase(BuildContext context) =>
    ComposeFormatShowcase(
      duration: _durationKnob(context),
      showPlusSign: context.knobs.boolean(
        label: 'showPlusSign',
        initialValue: false,
      ),
      showLeaderZero: context.knobs.boolean(
        label: 'showLeaderZero',
        initialValue: false,
      ),
      padHours: context.knobs.boolean(
        label: 'padHours',
        initialValue: false,
      ),
    );

@widgetbook.UseCase(name: 'Countdown preset', type: ComposeFormatShowcase)
Widget countdownPresetComposeFormatShowcaseUseCase(BuildContext context) =>
    ComposeFormatShowcase(
      duration: _durationKnob(context),
      showPlusSign: false,
      showLeaderZero: true,
      padHours: true,
    );

@widgetbook.UseCase(name: 'Signed delta preset', type: ComposeFormatShowcase)
Widget signedDeltaPresetComposeFormatShowcaseUseCase(BuildContext context) =>
    ComposeFormatShowcase(
      duration: _durationKnob(context),
      showPlusSign: true,
      showLeaderZero: false,
      padHours: false,
    );

// ---------------------------------------------------------------------------
// ExtDuration.toStopwatchDisplay
// ---------------------------------------------------------------------------

/// Showcases `toStopwatchDisplay`.
class StopwatchDisplayShowcase extends StatelessWidget {
  const StopwatchDisplayShowcase({
    required this.duration,
    required this.showPlusSign,
    super.key,
  });

  final Duration duration;
  final bool showPlusSign;

  static const _gallery = <String, Duration>{
    'zero': Duration.zero,
    'five seconds': Duration(seconds: 5),
    'sub-second (truncated)': Duration(milliseconds: 999),
    'one hour': Duration(hours: 1),
    'day boundary': Duration(hours: 24),
    'long': Duration(days: 146, hours: 23, minutes: 17, seconds: 14),
    'negative': Duration(hours: -1, minutes: -2, seconds: -3),
    'negative with days': Duration(days: -1, hours: -2),
  };

  @override
  Widget build(BuildContext context) => _Page(
    children: [
      _Section(
        title: 'Input',
        child: Column(
          children: [
            _Row(label: 'duration', value: _Mono('$duration')),
            _Row(label: 'showPlusSign', value: _Mono('$showPlusSign')),
          ],
        ),
      ),
      _Section(
        title: 'Output',
        child: Text(
          duration.toStopwatchDisplay(showPlusSign: showPlusSign),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontFamily: 'monospace',
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
      _Section(
        title: 'Gallery (same showPlusSign)',
        child: Column(
          children: [
            for (final entry in _gallery.entries)
              _Row(
                label: entry.key,
                value: _Mono(
                  entry.value.toStopwatchDisplay(
                    showPlusSign: showPlusSign,
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Interactive', type: StopwatchDisplayShowcase)
Widget interactiveStopwatchDisplayShowcaseUseCase(BuildContext context) =>
    StopwatchDisplayShowcase(
      duration: _durationKnob(context),
      showPlusSign: context.knobs.boolean(
        label: 'showPlusSign',
        initialValue: false,
      ),
    );

// ---------------------------------------------------------------------------
// DurationUnits
// ---------------------------------------------------------------------------

/// Tabulates every [DurationUnits] value.
class DurationUnitsTable extends StatelessWidget {
  const DurationUnitsTable({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) => _Page(
    children: [
      _Section(
        title: 'inMicroseconds',
        child: Column(
          children: [
            for (final unit in DurationUnits.values)
              _Row(
                label: unit.name,
                value: _Mono('${unit.inMicroseconds}'),
              ),
          ],
        ),
      ),
      _Section(
        title: 'times($count)',
        child: Column(
          children: [
            for (final unit in DurationUnits.values)
              _Row(
                label: unit.name,
                value: _Mono('${unit.times(count)}'),
              ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Table', type: DurationUnitsTable)
Widget tableDurationUnitsTableUseCase(BuildContext context) =>
    DurationUnitsTable(
      count: context.knobs.int.slider(
        label: 'count',
        initialValue: 3,
        min: -10,
        max: 100,
      ),
    );
