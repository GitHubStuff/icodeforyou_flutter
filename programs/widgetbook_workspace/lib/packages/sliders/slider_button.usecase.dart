// programs/widgetbook_workspace/lib/sliders/slider_button.usecase.dart
import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:sliders/sliders.dart' show SliderButton;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

/// Knob-driven [SliderButton] with a tap counter.
///
/// Every knob maps to one constructor parameter, so the use case doubles as
/// a live reading of the widget's API.
@UseCase(name: 'Interactive', type: SliderButton)
Widget buildSliderButtonInteractive(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  final hint = context.knobs.string(label: 'Hint', initialValue: 'Increase');
  final color = context.knobs.colorOrNull(label: 'Icon color');
  final icon = context.knobs.object.dropdown<_ButtonIcon>(
    label: 'Icon',
    options: _ButtonIcon.values,
    initialOption: .addCircleOutline,
    labelBuilder: (icon) => icon.name,
  );
  final haptic = context.knobs.object.dropdown<HapticIntensity>(
    label: 'Haptic',
    options: HapticIntensity.values,
    initialOption: .light,
    labelBuilder: (haptic) => haptic.name,
  );

  return _TapCounter(
    builder: (onTap) => SliderButton(
      icon: Icon(icon.data, color: color),
      hint: hint,
      haptic: haptic,
      onTap: enabled ? onTap : null,
    ),
  );
}

/// Every visual state of [SliderButton] side by side.
@UseCase(name: 'Gallery', type: SliderButton)
Widget buildSliderButtonGallery(BuildContext context) {
  return _Gallery(
    rows: [
      (
        'Enabled',
        SliderButton(
          icon: const Icon(Icons.add_circle_outline),
          hint: 'Increase',
          onTap: () {},
        ),
      ),
      (
        'Disabled',
        const SliderButton(
          icon: Icon(Icons.add_circle_outline),
          hint: 'Increase',
        ),
      ),
      (
        'Tinted',
        SliderButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.teal),
          hint: 'Decrease',
          onTap: () {},
        ),
      ),
      (
        'Silent (no haptic)',
        SliderButton(
          icon: const Icon(Icons.volume_off_outlined),
          hint: 'Mute',
          haptic: .none,
          onTap: () {},
        ),
      ),
      (
        'Heavy haptic',
        SliderButton(
          icon: const Icon(Icons.vibration),
          hint: 'Thump',
          haptic: .heavy,
          onTap: () {},
        ),
      ),
    ],
  );
}

/// The icons offered by the `Icon` knob.
///
/// An enum rather than a `Map<IconData, String>`: [IconData] overrides `==`
/// and so cannot be a const map key, whereas an enum value is a legal const
/// key, carries its own label via [Enum.name], and keeps the knob's option
/// identity stable across rebuilds.
enum _ButtonIcon {
  addCircleOutline(Icons.add_circle_outline),
  removeCircleOutline(Icons.remove_circle_outline),
  chevronLeft(Icons.chevron_left),
  chevronRight(Icons.chevron_right),
  volumeDown(Icons.volume_down),
  volumeUp(Icons.volume_up);

  const _ButtonIcon(this.data);

  /// The Material icon this option renders.
  final IconData data;
}

/// Hosts a button and shows how many times it has been tapped.
class _TapCounter extends StatefulWidget {
  const _TapCounter({required this.builder});

  final Widget Function(VoidCallback onTap) builder;

  @override
  State<_TapCounter> createState() => _TapCounterState();
}

class _TapCounterState extends State<_TapCounter> {
  int _taps = 0;

  void _onTap() => setState(() => _taps++);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.builder(_onTap),
          const SizedBox(height: 16),
          Text('Taps: $_taps', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// A labelled column of widgets, one per row.
class _Gallery extends StatelessWidget {
  const _Gallery({required this.rows});

  final List<(String, Widget)> rows;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (label, child) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 160,
                      child: Text(label, style: labelStyle),
                    ),
                    child,
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
