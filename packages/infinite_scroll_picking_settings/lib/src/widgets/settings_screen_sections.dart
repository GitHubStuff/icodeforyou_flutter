// infinite_scroll_picking_settings/lib/src/widgets/settings_screen_sections.dart

// ignore_for_file: public_member_api_docs

part of 'settings_screen.dart';

// ── Slider ranges (min, max) ──────────────────────────────────────────────────

const _kFrameBorderRadiusRange = Size(0, 24);
const _kFrameHPadRange = Size(0, 32);
const _kFrameVPadRange = Size(0, 24);

const _kItemExtentRange = Size(8, 70);
const _kWheelWidthRange = Size(14, 90);
const _kWheelHeightRange = Size(8, 140);
const _kWheelBorderRadiusRange = Size(0, 24);

const _kDividerThicknessRange = Size(0, 8);
const _kDividerInsetRange = Size(0, 16);

const _kPerspectiveRange = Size(0.8, 2);
const _kMagnificationRange = Size(1, 2);
const _kDebounceMsRange = Size(0, 500);

const _kStartingIndexRange = Size(0, 99);

// ── Slider steps ──────────────────────────────────────────────────────────────

const _kBorderRadiusStep = 0.5;
const _kFramePadStep = 1.0;
const _kItemExtentStep = 1.0;
const _kWheelWidthStep = 0.5;
const _kWheelHeightStep = 1.0;
const _kDividerThicknessStep = 0.5;
const _kDividerInsetStep = 0.5;
const _kPerspectiveStep = 0.05;
const _kMagnificationStep = 0.05;
const _kDebounceMsStep = 25.0;
const _kStartingIndexStep = 1.0;

// ── Section callback signature ───────────────────────────────────────────────

typedef _OnSettingsChanged = void Function(PickerVisualSettings next);

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Wheel asserts `wheelHeight >= itemExtent * 1.1`. Clamp here so sliders
/// can range freely without ever building an invalid settings.
double _clampWheelHeight(double wheelHeight, double itemExtent) {
  final min = itemExtent * 1.1 + 0.1;
  return wheelHeight < min ? min : wheelHeight;
}

// ── Pinned preview header ────────────────────────────────────────────────────

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({required this.settings});

  final PickerVisualSettings settings;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final pickerConfig = settings.toPickerConfig<int, String>(
      items: List.generate(_kPreviewItemCount, (i) => i),
      pickerId: 'preview',
    );

    return Material(
      elevation: 2,
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _kPagePadding,
          vertical: _kPinnedHeaderVPad,
        ),
        child: Center(
          child: InfiniteScrollPicker<int, String>(
            config: pickerConfig,
            label: const Text('Preview'),
            itemBuilder: (n, isSelected) => Text(
              '$n',
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            onItemSelected: (_, _) {},
          ),
        ),
      ),
    );
  }
}

// ── Section widgets ──────────────────────────────────────────────────────────

class _FrameSection extends StatelessWidget {
  const _FrameSection({required this.settings, required this.onChanged});

  final PickerVisualSettings settings;
  final _OnSettingsChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final s = settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Frame'),
        _SliderRow(
          label: 'frameBorderRadius',
          value: s.frameBorderRadius,
          range: _kFrameBorderRadiusRange,
          step: _kBorderRadiusStep,
          onChanged: (x) => onChanged(s.copyWith(frameBorderRadius: x)),
        ),
        _SliderRow(
          label: 'frameHorizontalPadding',
          value: s.frameHorizontalPadding,
          range: _kFrameHPadRange,
          step: _kFramePadStep,
          fractionDigits: 0,
          onChanged: (x) => onChanged(s.copyWith(frameHorizontalPadding: x)),
        ),
        _SliderRow(
          label: 'frameVerticalPadding',
          value: s.frameVerticalPadding,
          range: _kFrameVPadRange,
          step: _kFramePadStep,
          fractionDigits: 0,
          onChanged: (x) => onChanged(s.copyWith(frameVerticalPadding: x)),
        ),
      ],
    );
  }
}

class _WheelDimensionsSection extends StatelessWidget {
  const _WheelDimensionsSection({
    required this.settings,
    required this.onChanged,
  });

  final PickerVisualSettings settings;
  final _OnSettingsChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final s = settings;
    final w = s.wheel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Wheel — dimensions'),
        _SliderRow(
          label: 'itemExtent',
          value: w.itemExtent,
          range: _kItemExtentRange,
          step: _kItemExtentStep,
          fractionDigits: 0,
          onChanged: (x) {
            final clampedHeight = _clampWheelHeight(w.wheelHeight, x);
            onChanged(
              s.copyWith(
                wheel: w.copyWith(
                  itemExtent: x,
                  wheelHeight: clampedHeight,
                ),
              ),
            );
          },
        ),
        _SliderRow(
          label: 'wheelWidth',
          value: w.wheelWidth,
          range: _kWheelWidthRange,
          step: _kWheelWidthStep,
          onChanged: (x) =>
              onChanged(s.copyWith(wheel: w.copyWith(wheelWidth: x))),
        ),
        _SliderRow(
          label: 'wheelHeight',
          value: w.wheelHeight,
          range: _kWheelHeightRange,
          step: _kWheelHeightStep,
          fractionDigits: 0,
          onChanged: (x) {
            final clamped = _clampWheelHeight(x, w.itemExtent);
            onChanged(s.copyWith(wheel: w.copyWith(wheelHeight: clamped)));
          },
        ),
        _SliderRow(
          label: 'wheelBorderRadius',
          value: w.wheelBorderRadius,
          range: _kWheelBorderRadiusRange,
          step: _kBorderRadiusStep,
          onChanged: (x) =>
              onChanged(s.copyWith(wheel: w.copyWith(wheelBorderRadius: x))),
        ),
      ],
    );
  }
}

class _SelectionBandSection extends StatelessWidget {
  const _SelectionBandSection({
    required this.settings,
    required this.onChanged,
  });

  final PickerVisualSettings settings;
  final _OnSettingsChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final s = settings;
    final w = s.wheel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Wheel — selection band'),
        _SliderRow(
          label: 'dividerThickness',
          value: w.dividerThickness,
          range: _kDividerThicknessRange,
          step: _kDividerThicknessStep,
          onChanged: (x) =>
              onChanged(s.copyWith(wheel: w.copyWith(dividerThickness: x))),
        ),
        _SliderRow(
          label: 'dividerInset',
          value: w.dividerInset,
          range: _kDividerInsetRange,
          step: _kDividerInsetStep,
          onChanged: (x) =>
              onChanged(s.copyWith(wheel: w.copyWith(dividerInset: x))),
        ),
      ],
    );
  }
}

class _PerspectiveSection extends StatelessWidget {
  const _PerspectiveSection({
    required this.settings,
    required this.onChanged,
  });

  final PickerVisualSettings settings;
  final _OnSettingsChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final s = settings;
    final w = s.wheel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Wheel — perspective & motion'),
        _SliderRow(
          label: 'perspectiveDiameter',
          value: w.perspectiveDiameter,
          range: _kPerspectiveRange,
          step: _kPerspectiveStep,
          fractionDigits: 2,
          onChanged: (x) => onChanged(
            s.copyWith(wheel: w.copyWith(perspectiveDiameter: x)),
          ),
        ),
        _SliderRow(
          label: 'magnification',
          value: w.magnification,
          range: _kMagnificationRange,
          step: _kMagnificationStep,
          fractionDigits: 2,
          onChanged: (x) =>
              onChanged(s.copyWith(wheel: w.copyWith(magnification: x))),
        ),
        _SliderRow(
          label: 'selectionDebounce ms',
          value: w.selectionDebounce.inMilliseconds.toDouble(),
          range: _kDebounceMsRange,
          step: _kDebounceMsStep,
          fractionDigits: 0,
          onChanged: (x) => onChanged(
            s.copyWith(
              wheel: w.copyWith(
                selectionDebounce: Duration(milliseconds: x.round()),
              ),
            ),
          ),
        ),
        _SwitchRow(
          label: 'showBorder',
          value: w.showBorder,
          onChanged: (x) =>
              onChanged(s.copyWith(wheel: w.copyWith(showBorder: x))),
        ),
      ],
    );
  }
}

class _PickerSection extends StatelessWidget {
  const _PickerSection({required this.settings, required this.onChanged});

  final PickerVisualSettings settings;
  final _OnSettingsChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final s = settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Picker'),
        _SliderRow(
          label: 'startingIndex',
          value: s.startingIndex.toDouble(),
          range: _kStartingIndexRange,
          step: _kStartingIndexStep,
          fractionDigits: 0,
          onChanged: (x) => onChanged(s.copyWith(startingIndex: x.round())),
        ),
      ],
    );
  }
}
