// widgetbook/lib/infinite_scroll_picking/infinite_scroll_picker.usecase.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: InfiniteScrollPicker<int, String>,
)
Widget infiniteScrollPickerUseCase(BuildContext context) {
  // ── Items / picker identity ─────────────────────────────────────────────────

  final itemCount = context.knobs.int.slider(
    label: 'Item count',
    initialValue: 50,
    min: 2,
    max: 200,
  );

  final startingIndex = context.knobs.int.slider(
    label: 'Starting index',
    initialValue: 0,
    min: 0,
    max: 199,
  );

  final pickerId = context.knobs.string(
    label: 'Picker id',
    initialValue: 'showcase',
  );

  // ── Frame ───────────────────────────────────────────────────────────────────

  final frameBorderRadius = context.knobs.double.slider(
    label: 'Frame border radius',
    initialValue: 8,
    min: 0,
    max: 32,
  );

  final frameHorizontalPadding = context.knobs.double.slider(
    label: 'Frame horizontal padding',
    initialValue: 12,
    min: 0,
    max: 32,
  );

  final frameVerticalPadding = context.knobs.double.slider(
    label: 'Frame vertical padding',
    initialValue: 6,
    min: 0,
    max: 24,
  );

  // ── Wheel — dimensions ─────────────────────────────────────────────────────

  final itemExtent = context.knobs.double.slider(
    label: 'Item extent',
    initialValue: 24,
    min: 12,
    max: 60,
  );

  final wheelWidth = context.knobs.double.slider(
    label: 'Wheel width',
    initialValue: 56,
    min: 20,
    max: 160,
  );

  final wheelHeight = context.knobs.double.slider(
    label: 'Wheel height',
    initialValue: 48,
    min: 20,
    max: 240,
  );

  final wheelBorderRadius = context.knobs.double.slider(
    label: 'Wheel border radius',
    initialValue: 8,
    min: 0,
    max: 32,
  );

  // ── Wheel — selection band ─────────────────────────────────────────────────

  final dividerThickness = context.knobs.double.slider(
    label: 'Divider thickness',
    initialValue: 1,
    min: 0,
    max: 6,
  );

  final dividerInset = context.knobs.double.slider(
    label: 'Divider inset',
    initialValue: 4,
    min: 0,
    max: 24,
  );

  // ── Wheel — perspective & motion ───────────────────────────────────────────

  final perspectiveDiameter = context.knobs.double.slider(
    label: 'Perspective diameter',
    initialValue: 1.2,
    min: 0.6,
    max: 3,
  );

  final magnification = context.knobs.double.slider(
    label: 'Magnification',
    initialValue: 1.25,
    min: 1,
    max: 2,
  );

  final showBorder = context.knobs.boolean(
    label: 'Show wheel border',
    initialValue: true,
  );

  final selectionDebounceMs = context.knobs.int.slider(
    label: 'Selection debounce (ms)',
    initialValue: 0,
    min: 0,
    max: 1000,
  );

  // ── Item rendering (showcase-only) ─────────────────────────────────────────

  final fontSize = context.knobs.double.slider(
    label: 'Font size',
    initialValue: 18,
    min: 8,
    max: 40,
  );

  final leadingZero = context.knobs.boolean(
    label: 'Leading zero',
    initialValue: false,
  );

  // ── Clamp interdependent knobs to satisfy config asserts ───────────────────

  // startingIndex < items.length
  final safeStartingIndex = startingIndex >= itemCount
      ? itemCount - 1
      : startingIndex;

  // wheelHeight >= itemExtent * 1.1
  final minWheelHeight = itemExtent * 1.1;
  final safeWheelHeight = wheelHeight < minWheelHeight
      ? minWheelHeight
      : wheelHeight;

  // ── Build ──────────────────────────────────────────────────────────────────

  final wheelConfig = InfiniteScrollWheelConfig(
    itemExtent: itemExtent,
    dividerThickness: dividerThickness,
    dividerInset: dividerInset,
    wheelWidth: wheelWidth,
    wheelHeight: safeWheelHeight,
    perspectiveDiameter: perspectiveDiameter,
    magnification: magnification,
    wheelBorderRadius: wheelBorderRadius,
    showBorder: showBorder,
    selectionDebounce: Duration(milliseconds: selectionDebounceMs),
  );

  final config = InfiniteScrollPickerConfig<int, String>(
    items: List.generate(itemCount, (i) => i + 1),
    pickerId: pickerId,
    startingIndex: safeStartingIndex,
    wheelConfig: wheelConfig,
    frameBorderRadius: frameBorderRadius,
    frameHorizontalPadding: frameHorizontalPadding,
    frameVerticalPadding: frameVerticalPadding,
  );

  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InfiniteScrollPicker<int, String>(
          config: config,
          label: const Text('Showcase'),
          itemBuilder: (item, isSelected) => Text(
            leadingZero ? item.toString().padLeft(3, '0') : item.toString(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onItemSelected: (id, item) => debugPrint('[$id] selected: $item'),
        ),
      ),
    ),
  );
}
