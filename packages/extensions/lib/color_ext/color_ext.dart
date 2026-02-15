import 'package:flutter/material.dart';

extension ColorExtension on Color {
  /// Compares two colors by ARGB value.
  bool equals(Color other) =>
      a == other.a && r == other.r && g == other.g && b == other.b;
}
