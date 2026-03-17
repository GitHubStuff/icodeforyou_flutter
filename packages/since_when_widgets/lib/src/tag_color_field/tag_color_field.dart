// lib/src/tag_color_field/tag_color_field.dart

import 'package:flutter/material.dart';
import 'package:random_color_generator/random_color_generator.dart';

part '_tag_color_field_state.dart';

/// A color-swatch field that generates a random color, excluding any
/// colors in [skipColors].
///
/// Tapping [refresh] permanently excludes the current color and offers
/// a new one, fading it in over [fadeTime].
///
/// [onChanged] fires with the `toARGB32()` value of the color immediately
/// on mount and on every refresh tap.
///
/// Width is controlled by the caller's layout, identical to
/// [CountedTextField].
class TagColorField extends StatefulWidget {
  const TagColorField({
    required this.onChanged,
    super.key,
    this.skipColors = const [],
    this.refresh = const Icon(Icons.refresh),
    this.height = 32,
    this.fadeTime = const Duration(milliseconds: 250),
  });

  final ValueChanged<int> onChanged;
  final List<int> skipColors;
  final Widget refresh;
  final double height;
  final Duration fadeTime;

  @override
  State<TagColorField> createState() => _TagColorFieldState();
}
