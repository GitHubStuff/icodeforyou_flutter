// infinite_scroll_picking_settings/lib/src/widgets/settings_screen_widgets.dart

// ignore_for_file: public_member_api_docs

part of 'settings_screen.dart';

// ── Layout constants ─────────────────────────────────────────────────────────

const _kSliderLabelWidth = 140.0;
const _kSliderValueWidth = 52.0;

// ── AppBar actions ───────────────────────────────────────────────────────────

class _SaveAction extends StatelessWidget {
  const _SaveAction();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final canSave = state is SettingsLoaded && state.isDirty;
        return TextButton(
          onPressed: canSave
              ? () => context.read<SettingsCubit>().save()
              : null,
          child: const Text('Save'),
        );
      },
    );
  }
}

class _ResetAction extends StatelessWidget {
  const _ResetAction();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Reset to defaults',
      icon: const Icon(Icons.refresh),
      onPressed: () => context.read<SettingsCubit>().reset(),
    );
  }
}

class _ClearAction extends StatelessWidget {
  const _ClearAction();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Clear stored settings',
      icon: const Icon(Icons.delete_outline),
      onPressed: () => context.read<SettingsCubit>().clearPersisted(),
    );
  }
}

// ── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

// ── Generic UI primitives ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.range,
    required this.step,
    required this.onChanged,
    this.fractionDigits = 1,
  });

  final String label;
  final double value;
  final Size range;
  final double step;
  final ValueChanged<double> onChanged;
  final int fractionDigits;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(range.width, range.height);
    return Row(
      children: [
        SizedBox(
          width: _kSliderLabelWidth,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(
          child: Slider(
            value: clamped,
            min: range.width,
            max: range.height,
            divisions: ((range.height - range.width) / step).round(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: _kSliderValueWidth,
          child: Text(
            value.toStringAsFixed(fractionDigits),
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _StateReadout extends StatelessWidget {
  const _StateReadout({required this.settings, required this.isDirty});

  final PickerVisualSettings settings;
  final bool isDirty;

  @override
  Widget build(BuildContext context) {
    final s = settings;
    final w = s.wheel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current settings',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (isDirty)
                  const Chip(
                    label: Text('unsaved'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('startingIndex: ${s.startingIndex}'),
            Text('frameBorderRadius: ${s.frameBorderRadius}'),
            Text('frameHorizontalPadding: ${s.frameHorizontalPadding}'),
            Text('frameVerticalPadding: ${s.frameVerticalPadding}'),
            const SizedBox(height: 8),
            const Text('Wheel', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('itemExtent: ${w.itemExtent}'),
            Text('wheelWidth: ${w.wheelWidth}'),
            Text('wheelHeight: ${w.wheelHeight}'),
            Text('magnification: ${w.magnification}'),
            Text(
              'selectionDebounce: ${w.selectionDebounce.inMilliseconds}ms',
            ),
          ],
        ),
      ),
    );
  }
}
