// programs/widgetbook_workspace/lib/packages/color_grid/color_grid.usecase.dart
import 'package:color_grid/color_grid.dart' show ColorGrid;
import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart'
    show BuildContext, Center, Widget;
import 'package:oktoast/oktoast.dart' show showToast;
import 'package:widgetbook/widgetbook.dart' show KnobsExtension;
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook
    show UseCase;

/// A named fifteen-color palette selectable from the palette knob.
///
/// Each value carries exactly the fifteen ARGB colors [ColorGrid]
/// requires; the widget's own constructor assert enforces the count.
enum _Palette {
  /// The Material primary swatch at shade 500, minus blue-grey.
  material('Material 500', [
    0xFFF44336,
    0xFFE91E63,
    0xFF9C27B0,
    0xFF673AB7,
    0xFF3F51B5,
    0xFF2196F3,
    0xFF03A9F4,
    0xFF00BCD4,
    0xFF009688,
    0xFF4CAF50,
    0xFF8BC34A,
    0xFFCDDC39,
    0xFFFFEB3B,
    0xFFFF9800,
    0xFF795548,
  ]),

  /// Soft, low-saturation pastel tones.
  pastel('Pastel', [
    0xFFFFB3BA,
    0xFFFFDFBA,
    0xFFFFFFBA,
    0xFFBAFFC9,
    0xFFBAE1FF,
    0xFFE3BAFF,
    0xFFFFC8DD,
    0xFFBDE0FE,
    0xFFA2D2FF,
    0xFFCDB4DB,
    0xFFB5EAD7,
    0xFFC7CEEA,
    0xFFFFDAC1,
    0xFFE2F0CB,
    0xFFF1F0C0,
  ]),

  /// Even grey steps from near-black to near-white.
  grayscale('Grayscale', [
    0xFF101010,
    0xFF202020,
    0xFF303030,
    0xFF404040,
    0xFF505050,
    0xFF606060,
    0xFF707070,
    0xFF808080,
    0xFF909090,
    0xFFA0A0A0,
    0xFFB0B0B0,
    0xFFC0C0C0,
    0xFFD0D0D0,
    0xFFE0E0E0,
    0xFFF0F0F0,
  ]);

  /// Creates a palette with a human-readable [label] and its [colors].
  const _Palette(this.label, this.colors);

  /// The label shown in the palette dropdown knob.
  final String label;

  /// The fifteen ARGB values handed to [ColorGrid.colors].
  final List<int> colors;
}

/// Builds the default [ColorGrid] use case.
///
/// Exposes two knobs: a palette dropdown selecting one of the
/// [_Palette] color sets, and a haptics dropdown covering every
/// [HapticIntensity] value. Cell taps and refresh requests are
/// reported via [showToast] so knob-driven rebuilds stay pure.
@widgetbook.UseCase(name: 'Default', type: ColorGrid)
Widget buildColorGridUseCase(BuildContext context) {
  final palette = context.knobs.object.dropdown<_Palette>(
    label: 'Palette',
    options: _Palette.values,
    initialOption: _Palette.material,
    labelBuilder: (palette) => palette.label,
  );

  final haptics = context.knobs.object.dropdown<HapticIntensity>(
    label: 'Haptics',
    options: HapticIntensity.values,
    initialOption: HapticIntensity.light,
    labelBuilder: (haptics) => haptics.name,
  );

  return Center(
    child: ColorGrid(
      colors: palette.colors,
      haptics: haptics,
      onColorTapped: (index, colorValue) => showToast(
        'ColorGrid tapped index $index, '
        'color 0x${colorValue.toRadixString(16).toUpperCase()}',
      ),
      onRefreshRequested: () => showToast('ColorGrid refresh requested'),
    ),
  );
}
