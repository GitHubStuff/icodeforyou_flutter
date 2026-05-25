// infinite_scroll_picking/example/lib/showcase_page.dart

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:example/pick_manager_cubit.dart' show PickManagerCubit;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart'
    show
        InfiniteScrollPicker,
        InfiniteScrollPickerConfig,
        InfiniteScrollPickerController,
        InfiniteScrollWheelConfig;

// ── Slider ranges (min, max) ─────────────────────────────────────────────────

// Frame
const _kFrameBorderRadiusRange = Size(0, 24);
const _kFrameHPadRange = Size(0, 32);
const _kFrameVPadRange = Size(0, 24);

// Wheel — dimensions
const _kItemExtentRange = Size(8, 70);
const _kWheelWidthRange = Size(14, 90);
const _kWheelHeightRange = Size(8, 140);
const _kWheelBorderRadiusRange = Size(0, 24);

// Wheel — selection band
const _kDividerThicknessRange = Size(0, 8);
const _kDividerInsetRange = Size(0, 16);

// Wheel — perspective / motion
const _kPerspectiveRange = Size(0.8, 2);
const _kMagnificationRange = Size(1, 2);
const _kDebounceMsRange = Size(0, 500);

// Picker config
const _kStartingIndexRange = Size(0, 99);

// Item rendering (showcase-only)
const _kFontSizeRange = Size(6, 48);

// Animate buttons
const _kAnimateMsRange = Size(50, 1500);

// ── Slider steps ─────────────────────────────────────────────────────────────

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
const _kFontSizeStep = 1.0;
const _kAnimateMsStep = 50.0;

// ── Defaults ─────────────────────────────────────────────────────────────────

// Frame
const _kFrameBorderRadiusDefault = 8.0;
const _kFrameHPadDefault = 12.0;
const _kFrameVPadDefault = 6.0;

// Wheel
const _kItemExtentDefault = 22.0;
const _kWheelWidthDefault = 32.0;
const _kWheelHeightDefault = 44.0;
const _kWheelBorderRadiusDefault = 8.0;
const _kDividerThicknessDefault = 1.0;
const _kDividerInsetDefault = 4.0;
const _kPerspectiveDefault = 1.2;
const _kMagnificationDefault = 1.25;
const _kDebounceMsDefault = 0.0;

// Picker
const _kStartingIndexDefault = 0;

// Item rendering
const _kFontSizeDefault = 14.0;
const _kLeadingZeroDefault = false;
const _kShowBorderDefault = true;

// Animate buttons
const _kAnimateMsDefault = 400.0;

// Item count
const _kItemCount = 100;

// ── Layout ───────────────────────────────────────────────────────────────────

const _kSliderLabelWidth = 140.0;
const _kSliderValueWidth = 52.0;
const _kPagePadding = 18.0;
const _kPinnedHeaderVPad = 12.0;

// ─────────────────────────────────────────────────────────────────────────────

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  // ── Frame ────────────────────────────────────────────────────────────────
  double _frameBorderRadius = _kFrameBorderRadiusDefault;
  double _frameHPad = _kFrameHPadDefault;
  double _frameVPad = _kFrameVPadDefault;

  // ── Wheel ────────────────────────────────────────────────────────────────
  double _itemExtent = _kItemExtentDefault;
  double _wheelWidth = _kWheelWidthDefault;
  double _wheelHeightValue = _kWheelHeightDefault;
  double _wheelBorderRadius = _kWheelBorderRadiusDefault;
  double _dividerThickness = _kDividerThicknessDefault;
  double _dividerInset = _kDividerInsetDefault;
  double _perspectiveDiameter = _kPerspectiveDefault;
  double _magnification = _kMagnificationDefault;
  double _debounceMs = _kDebounceMsDefault;
  bool _showBorder = _kShowBorderDefault;

  // ── Picker config ────────────────────────────────────────────────────────
  int _startingIndex = _kStartingIndexDefault;

  // ── Item rendering (showcase-only) ───────────────────────────────────────
  double _fontSize = _kFontSizeDefault;
  bool _leadingZero = _kLeadingZeroDefault;

  // ── Controller animation duration (showcase-only) ────────────────────────
  double _animateMs = _kAnimateMsDefault;

  late final InfiniteScrollPickerController _pickerController;

  @override
  void initState() {
    super.initState();
    _pickerController = InfiniteScrollPickerController();
  }

  @override
  void dispose() {
    _pickerController.dispose();
    super.dispose();
  }

  /// The wheel asserts `wheelHeight >= itemExtent * 1.1`. Clamp on read so
  /// the slider can range freely without ever building an invalid config.
  double get _wheelHeight {
    final min = _itemExtent * 1.1 + 0.1;
    return _wheelHeightValue < min ? min : _wheelHeightValue;
  }

  Duration get _animateDuration => Duration(milliseconds: _animateMs.round());

  String _format(int n) => _leadingZero ? n.toString().padLeft(2, '0') : '$n';

  void _resetDefaults() {
    setState(() {
      _frameBorderRadius = _kFrameBorderRadiusDefault;
      _frameHPad = _kFrameHPadDefault;
      _frameVPad = _kFrameVPadDefault;
      _itemExtent = _kItemExtentDefault;
      _wheelWidth = _kWheelWidthDefault;
      _wheelHeightValue = _kWheelHeightDefault;
      _wheelBorderRadius = _kWheelBorderRadiusDefault;
      _dividerThickness = _kDividerThicknessDefault;
      _dividerInset = _kDividerInsetDefault;
      _perspectiveDiameter = _kPerspectiveDefault;
      _magnification = _kMagnificationDefault;
      _debounceMs = _kDebounceMsDefault;
      _showBorder = _kShowBorderDefault;
      _startingIndex = _kStartingIndexDefault;
      _fontSize = _kFontSizeDefault;
      _leadingZero = _kLeadingZeroDefault;
      _animateMs = _kAnimateMsDefault;
    });
    unawaited(_pickerController.reset());
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PickManagerCubit>();
    final colorScheme = Theme.of(context).colorScheme;

    final wheelConfig = InfiniteScrollWheelConfig(
      itemExtent: _itemExtent,
      dividerThickness: _dividerThickness,
      dividerInset: _dividerInset,
      wheelWidth: _wheelWidth,
      wheelHeight: _wheelHeight,
      perspectiveDiameter: _perspectiveDiameter,
      magnification: _magnification,
      wheelBorderRadius: _wheelBorderRadius,
      showBorder: _showBorder,
      selectionDebounce: Duration(milliseconds: _debounceMs.round()),
    );

    final pickerConfig = InfiniteScrollPickerConfig<int, String>(
      items: List.generate(_kItemCount, (i) => i),
      pickerId: 'number',
      startingIndex: _startingIndex,
      wheelConfig: wheelConfig,
      frameBorderRadius: _frameBorderRadius,
      frameHorizontalPadding: _frameHPad,
      frameVerticalPadding: _frameVPad,
    );

    final picker = InfiniteScrollPicker<int, String>(
      controller: _pickerController,
      config: pickerConfig,
      label: const Text('Number'),
      itemBuilder: (n, isSelected) => Text(
        _format(n),
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
      ),
      onItemSelected: cubit.setItem,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Infinite Scroll Picker — Showcase')),
      body: Column(
        children: [
          // ── Pinned picker (always visible) ──────────────────────────────
          Material(
            elevation: 2,
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kPagePadding,
                vertical: _kPinnedHeaderVPad,
              ),
              child: Center(child: picker),
            ),
          ),

          // ── Scrollable controls ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_kPagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Controller buttons
                  const _SectionHeader('Controller'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => _pickerController.reset(),
                        child: const Text('reset() — snap'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            _pickerController.reset(duration: _animateDuration),
                        child: const Text('reset() — animate'),
                      ),
                      OutlinedButton(
                        onPressed: () => _pickerController.jumpToIndex(42),
                        child: const Text('jumpToIndex(42)'),
                      ),
                      OutlinedButton(
                        onPressed: () => _pickerController.animateToIndex(
                          0,
                          duration: _animateDuration,
                        ),
                        child: const Text('animateToIndex(0)'),
                      ),
                      OutlinedButton(
                        onPressed: () => _pickerController.animateToIndex(
                          99,
                          duration: _animateDuration,
                        ),
                        child: const Text('animateToIndex(99)'),
                      ),
                    ],
                  ),
                  _SliderRow(
                    label: 'animate ms',
                    value: _animateMs,
                    range: _kAnimateMsRange,
                    step: _kAnimateMsStep,
                    fractionDigits: 0,
                    onChanged: (v) => setState(() => _animateMs = v),
                  ),
                  const Gap(20),

                  // Frame
                  const _SectionHeader('Frame'),
                  _SliderRow(
                    label: 'frameBorderRadius',
                    value: _frameBorderRadius,
                    range: _kFrameBorderRadiusRange,
                    step: _kBorderRadiusStep,
                    onChanged: (v) => setState(() => _frameBorderRadius = v),
                  ),
                  _SliderRow(
                    label: 'frameHorizontalPadding',
                    value: _frameHPad,
                    range: _kFrameHPadRange,
                    step: _kFramePadStep,
                    fractionDigits: 0,
                    onChanged: (v) => setState(() => _frameHPad = v),
                  ),
                  _SliderRow(
                    label: 'frameVerticalPadding',
                    value: _frameVPad,
                    range: _kFrameVPadRange,
                    step: _kFramePadStep,
                    fractionDigits: 0,
                    onChanged: (v) => setState(() => _frameVPad = v),
                  ),
                  const Gap(20),

                  // Wheel — dimensions
                  const _SectionHeader('Wheel — dimensions'),
                  _SliderRow(
                    label: 'itemExtent',
                    value: _itemExtent,
                    range: _kItemExtentRange,
                    step: _kItemExtentStep,
                    fractionDigits: 0,
                    onChanged: (v) => setState(() {
                      _itemExtent = v;
                      final min = v * 1.1 + 0.1;
                      if (_wheelHeightValue < min) _wheelHeightValue = min;
                    }),
                  ),
                  _SliderRow(
                    label: 'wheelWidth',
                    value: _wheelWidth,
                    range: _kWheelWidthRange,
                    step: _kWheelWidthStep,
                    onChanged: (v) => setState(() => _wheelWidth = v),
                  ),
                  _SliderRow(
                    label: 'wheelHeight',
                    value: _wheelHeight,
                    range: _kWheelHeightRange,
                    step: _kWheelHeightStep,
                    fractionDigits: 0,
                    onChanged: (v) => setState(() {
                      final min = _itemExtent * 1.1 + 0.1;
                      _wheelHeightValue = v < min ? min : v;
                    }),
                  ),
                  _SliderRow(
                    label: 'wheelBorderRadius',
                    value: _wheelBorderRadius,
                    range: _kWheelBorderRadiusRange,
                    step: _kBorderRadiusStep,
                    onChanged: (v) => setState(() => _wheelBorderRadius = v),
                  ),
                  const Gap(20),

                  // Wheel — selection band
                  const _SectionHeader('Wheel — selection band'),
                  _SliderRow(
                    label: 'dividerThickness',
                    value: _dividerThickness,
                    range: _kDividerThicknessRange,
                    step: _kDividerThicknessStep,
                    onChanged: (v) => setState(() => _dividerThickness = v),
                  ),
                  _SliderRow(
                    label: 'dividerInset',
                    value: _dividerInset,
                    range: _kDividerInsetRange,
                    step: _kDividerInsetStep,
                    onChanged: (v) => setState(() => _dividerInset = v),
                  ),
                  const Gap(20),

                  // Wheel — perspective / motion
                  const _SectionHeader('Wheel — perspective & motion'),
                  _SliderRow(
                    label: 'perspectiveDiameter',
                    value: _perspectiveDiameter,
                    range: _kPerspectiveRange,
                    step: _kPerspectiveStep,
                    fractionDigits: 2,
                    onChanged: (v) => setState(() => _perspectiveDiameter = v),
                  ),
                  _SliderRow(
                    label: 'magnification',
                    value: _magnification,
                    range: _kMagnificationRange,
                    step: _kMagnificationStep,
                    fractionDigits: 2,
                    onChanged: (v) => setState(() => _magnification = v),
                  ),
                  _SliderRow(
                    label: 'selectionDebounce ms',
                    value: _debounceMs,
                    range: _kDebounceMsRange,
                    step: _kDebounceMsStep,
                    fractionDigits: 0,
                    onChanged: (v) => setState(() => _debounceMs = v),
                  ),
                  const Gap(20),

                  // Picker config
                  const _SectionHeader('Picker'),
                  _SliderRow(
                    label: 'startingIndex',
                    value: _startingIndex.toDouble(),
                    range: _kStartingIndexRange,
                    step: _kStartingIndexStep,
                    fractionDigits: 0,
                    onChanged: (v) =>
                        setState(() => _startingIndex = v.round()),
                  ),
                  const Gap(20),

                  // Item rendering
                  const _SectionHeader('Item rendering'),
                  _SliderRow(
                    label: 'fontSize',
                    value: _fontSize,
                    range: _kFontSizeRange,
                    step: _kFontSizeStep,
                    fractionDigits: 0,
                    onChanged: (v) => setState(() => _fontSize = v),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _SwitchRow(
                          label: 'showBorder',
                          value: _showBorder,
                          onChanged: (v) => setState(() => _showBorder = v),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _SwitchRow(
                          label: 'leadingZero',
                          value: _leadingZero,
                          onChanged: (v) => setState(() => _leadingZero = v),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),

                  _StateReadout(onReset: _resetDefaults),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private helpers ──────────────────────────────────────────────────────────

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
  const _StateReadout({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickManagerCubit, Map<String, Object>>(
      builder: (context, state) {
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
                      'Current picks',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: onReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lime,
                      ),
                      child: const Text('Reset all'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.isEmpty)
                  const Text('Nothing picked yet.')
                else
                  ...state.entries.map((e) => Text('${e.key}: ${e.value}')),
              ],
            ),
          ),
        );
      },
    );
  }
}
