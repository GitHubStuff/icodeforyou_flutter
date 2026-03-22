// int_ext.dart
import 'package:flutter/material.dart' show Color;

extension IntExt on int {
  Color toColor() => Color(this);

  DateTime toUtc() => DateTime.fromMicrosecondsSinceEpoch(this, isUtc: true);
}
