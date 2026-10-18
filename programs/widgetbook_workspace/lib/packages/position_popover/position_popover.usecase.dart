// programs/widgetbook_workspace/lib/packages/position_popover/position_popover.usecase.dart
import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:position_popover/position_popover.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const String _path = '[position_popover]';

const List<Alignment> _alignments = <Alignment>[
  PositionPopover.standard,
  Alignment.topLeft,
  Alignment.topCenter,
  Alignment.topRight,
  Alignment.centerLeft,
  Alignment.center,
  Alignment.centerRight,
  Alignment.bottomLeft,
  Alignment.bottomCenter,
  Alignment.bottomRight,
];

const List<String> _choices = <String>['Alpha', 'Bravo', 'Charlie'];

/// Box styles the Interactive use case can switch between.
enum _BoxStyle {
  none,
  outline,
  filled,
  pill;

  Decoration? decoration(ColorScheme scheme) {
    switch (this) {
      case _BoxStyle.none:
        return null;
      case _BoxStyle.outline:
        return BoxDecoration(
          border: Border.all(color: scheme.outline),
          borderRadius: BorderRadius.circular(8),
        );
      case _BoxStyle.filled:
        return BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        );
      case _BoxStyle.pill:
        return ShapeDecoration(
          shape: StadiumBorder(side: BorderSide(color: scheme.primary)),
        );
    }
  }
}

@widgetbook.UseCase(
  name: 'Interactive',
  type: PositionPopover,
  path: _path,
)
Widget buildPositionPopoverInteractiveUseCase(BuildContext context) {
  final alignment = context.knobs.object.dropdown<Alignment>(
    label: 'alignment',
    options: _alignments,
    initialOption: PositionPopover.standard,
    labelBuilder: _alignmentLabel,
  );
  final boxStyle = context.knobs.object.dropdown<_BoxStyle>(
    label: 'decoration',
    options: _BoxStyle.values,
    initialOption: _BoxStyle.outline,
    labelBuilder: (_BoxStyle value) => value.name,
  );
  final paddingValue = context.knobs.double.slider(
    label: 'padding',
    initialValue: 8,
    min: 0,
    max: 24,
  );
  final showLeading = context.knobs.boolean(
    label: 'leadingIcon',
    initialValue: true,
  );
  final showTrailing = context.knobs.boolean(
    label: 'trailingIcon',
    initialValue: true,
  );
  final barrierDismissible = context.knobs.boolean(
    label: 'barrierDismissible',
    initialValue: true,
  );
  final barrierOpacity = context.knobs.double.slider(
    label: 'barrier opacity',
    initialValue: 0.54,
    min: 0,
    max: 1,
  );
  final hapticIntensity = context.knobs.object.dropdown<HapticIntensity>(
    label: 'hapticIntensity',
    options: HapticIntensity.values,
    initialOption: HapticIntensity.light,
    labelBuilder: (HapticIntensity value) => value.name,
  );
  final timeoutSeconds = context.knobs.int.slider(
    label: 'timeout (seconds, 0 = none)',
    initialValue: 0,
    min: 0,
    max: 10,
  );

  return _ResultHost<String>(
    builder: (BuildContext context, ValueChanged<String?> onResult) {
      final scheme = Theme.of(context).colorScheme;
      return PositionPopover<String>(
        alignment: alignment,
        decoration: boxStyle.decoration(scheme),
        padding: EdgeInsets.all(paddingValue),
        barrierDismissible: barrierDismissible,
        barrierColor: Colors.black.withValues(alpha: barrierOpacity),
        hapticIntensity: hapticIntensity,
        timeout: _timeoutFromSeconds(timeoutSeconds),
        onResult: onResult,
        leadingIcon: showLeading ? const _LeadingGlyph() : null,
        trailingIcon: showTrailing
            ? _TrailingButton(onPressed: () => onResult(null))
            : null,
        parent: const _DemoParent(label: 'Tap me'),
        popover: const _ChoiceMenu(),
      );
    },
  );
}

@widgetbook.UseCase(
  name: 'Alignment Gallery',
  type: PositionPopover,
  path: _path,
)
Widget buildPositionPopoverAlignmentGalleryUseCase(BuildContext context) {
  return _ResultHost<String>(
    builder: (BuildContext context, ValueChanged<String?> onResult) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 24,
          children: <Widget>[
            for (final alignment in _alignments)
              PositionPopover<String>(
                alignment: alignment,
                onResult: onResult,
                parent: _DemoParent(label: _alignmentLabel(alignment)),
                popover: const _ChoiceMenu(),
              ),
          ],
        ),
      );
    },
  );
}

@widgetbook.UseCase(
  name: 'Date Field',
  type: PositionPopover,
  path: _path,
)
Widget buildPositionPopoverDateFieldUseCase(BuildContext context) {
  return const Scaffold(
    body: Center(child: _DateField()),
  );
}

Duration? _timeoutFromSeconds(int seconds) {
  if (seconds <= 0) {
    return null;
  }
  return Duration(seconds: seconds);
}

String _alignmentLabel(Alignment alignment) {
  if (alignment == PositionPopover.standard) {
    return 'standard';
  }
  return alignment.toString().replaceFirst('Alignment.', '');
}

typedef _HostBuilder<T> =
    Widget Function(
      BuildContext context,
      ValueChanged<T?> onResult,
    );

/// Hosts a demo and shows the last value the popover returned.
class _ResultHost<T> extends StatefulWidget {
  const _ResultHost({required this.builder});

  final _HostBuilder<T> builder;

  @override
  State<_ResultHost<T>> createState() => _ResultHostState<T>();
}

class _ResultHostState<T> extends State<_ResultHost<T>> {
  T? _lastResult;
  int _resultCount = 0;

  void _onResult(T? value) {
    setState(() {
      _lastResult = value;
      _resultCount += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          _ResultBanner(count: _resultCount, value: _lastResult),
          Expanded(
            child: Center(child: widget.builder(context, _onResult)),
          ),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.count, required this.value});

  final int count;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = count == 0
        ? 'No result yet'
        : 'Result #$count: ${value ?? 'null'}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Text(text, style: theme.textTheme.titleMedium),
    );
  }
}

/// A tappable tile that sizes to its label, so it never overflows the
/// trigger's [Row] on a narrow canvas.
class _DemoParent extends StatelessWidget {
  const _DemoParent({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(color: scheme.onPrimaryContainer),
      ),
    );
  }
}

/// A static glyph with no gesture handling, placed before the trigger.
class _LeadingGlyph extends StatelessWidget {
  const _LeadingGlyph();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 8),
      child: Icon(Icons.calendar_today),
    );
  }
}

/// A button with its own callback, placed after the trigger.
class _TrailingButton extends StatelessWidget {
  const _TrailingButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.clear),
      tooltip: 'Clear',
      onPressed: onPressed,
    );
  }
}

/// Pops with the tapped choice, or `null` via the cancel tile.
class _ChoiceMenu extends StatelessWidget {
  const _ChoiceMenu();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final choice in _choices)
              ListTile(
                title: Text(choice),
                onTap: () => Navigator.pop<String>(context, choice),
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop<String>(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Calendar glyph, tappable date, clear button, all inside one outlined
/// box: the leading icon is inert, the trailing button resets the value
/// without opening the popover.
class _DateField extends StatefulWidget {
  const _DateField();

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  DateTime? _selected;

  void _onResult(DateTime? picked) {
    if (picked == null) {
      return;
    }
    setState(() => _selected = picked);
  }

  void _clear() {
    setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PositionPopover<DateTime>(
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 12, right: 4),
      onResult: _onResult,
      leadingIcon: const _LeadingGlyph(),
      trailingIcon: IconButton(
        icon: const Icon(Icons.clear),
        tooltip: 'Clear date',
        onPressed: _selected == null ? null : _clear,
      ),
      parent: _DateLabel(date: _selected),
      popover: _DatePickerPopover(initialDate: _selected),
    );
  }
}

/// The tappable date text; the box around it belongs to the popover.
class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = this.date;
    final text = date == null
        ? 'Select date'
        : MaterialLocalizations.of(context).formatMediumDate(date);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text,
        style: date == null
            ? theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor)
            : theme.textTheme.bodyLarge,
      ),
    );
  }
}

class _DatePickerPopover extends StatelessWidget {
  const _DatePickerPopover({required this.initialDate});

  final DateTime? initialDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 320,
        child: CalendarDatePicker(
          initialDate: initialDate ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 5),
          onDateChanged: (DateTime picked) {
            Navigator.pop<DateTime>(context, picked);
          },
        ),
      ),
    );
  }
}
