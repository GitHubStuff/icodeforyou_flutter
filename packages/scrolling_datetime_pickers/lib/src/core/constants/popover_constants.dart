// lib/src/core/constants/popover_constants.dart

// ignore_for_file: document_ignores, public_member_api_docs

import 'package:flutter/material.dart';

/// Default values for DateTimePickerPopover styling and animation.
class PopoverConstants {
  // Animation durations
  static const Duration crossfadeDuration = Duration(milliseconds: 550);
  static const Curve crossfadeCurve = Curves.linear;
  static const Duration popoverFadeDuration = Duration(milliseconds: 450);
  static const Curve popoverFadeCurve = Curves.linear;

  // Barrier
  static const Color barrierColor = Color.fromRGBO(0, 0, 0, 0.30);

  // Popover background
  static const Color defaultPopoverBackgroundColor = Color(0xFF2D2D2D);

  // Tab button colors
  static const Color defaultDateButtonColor = Color(0xFF4A90D9);
  static const Color defaultTimeButtonColor = Color(0xFF9B59B6);

  // Confirm button
  static const Color defaultConfirmButtonColor = Color(0xFF4CAF50);
  static const String defaultConfirmButtonText = 'Set';
  static const double confirmButtonHorizontalPadding = 16;
  static const double confirmButtonVerticalPadding = 8;
  static const double confirmButtonBorderRadius = 16;

  // Header
  static const double headerPadding = 12;
  static const double headerFontSize = 18;

  // Tab bar
  static const double tabBarHeight = 44;
  static const double tabButtonFontSize = 16;
  static const FontWeight tabButtonSelectedFontWeight = FontWeight.bold;
  static const FontWeight tabButtonUnselectedFontWeight = FontWeight.normal;

  // Popover dimensions
  static const double popoverBorderRadius = 12;
  static const double popoverScreenPadding = 16;

  // Date/Time format defaults
  static const String defaultDateFormat = 'EEE, dd-MMM-yyyy';
  static const String defaultTimeFormat = 'hh:mm:ss a';
  static const String defaultTimeFormatNoSeconds = 'hh:mm a';
}
