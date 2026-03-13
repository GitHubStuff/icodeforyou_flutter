// lib/src/_theme_option.dart

import 'package:flutter/material.dart';

class ThemeOption {
  const ThemeOption({
    required this.mode,
    required this.icon,
    required this.label,
  });

  final ThemeMode mode;
  final IconData icon;
  final String label;
}
