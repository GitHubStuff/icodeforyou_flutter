// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

part '_counted_text_field_state.dart';
part '_counted_text_field_overlays.dart';

/// A text field with a rounded border and a (n/maxLength) badge
/// embedded in the top-right of the border (LTR) or top-left (RTL).
///
/// An optional [caption] is embedded in the top-left of the border (LTR)
/// or top-right (RTL), mirroring the badge position.
///
/// Input is hard-truncated at [maxLength] characters. When truncation
/// occurs a floating message appears for [durationMs] milliseconds,
/// then fades out over [fadeMs] milliseconds.
///
/// Surfaces only the current text via [onChanged].
class CountedTextField extends StatefulWidget {
  const CountedTextField({
    required this.onChanged,
    super.key,
    this.maxLength = 20,
    this.borderColor = const Color(0xFF9C27B0),
    this.errorBorderColor = const Color(0xFFF44336),
    this.clearWidget = const Icon(Icons.cancel_outlined, size: 20),
    this.textDirection,
    this.durationMs = 750,
    this.fadeMs = 250,
    this.caption,
    this.hintText = 'Enter text',
  });

  final int maxLength;
  final Color borderColor;
  final Color errorBorderColor;
  final Widget clearWidget;
  final TextDirection? textDirection;
  final int durationMs;
  final int fadeMs;
  final String? caption;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<CountedTextField> createState() => _CountedTextFieldState();
}
