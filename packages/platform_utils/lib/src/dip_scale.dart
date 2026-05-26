// packages/platform_utils/lib/src/dip_scale.dart
// ignore_for_file: public_member_api_docs

/// The app's spacing scale, in logical pixels.
///
/// Based on an 8pt grid, with 4pt half-steps and a 12pt comfortable mid-step
/// between [sm] and [md] for the common "8 is tight, 16 is loose" case. All
/// values are divisible by 4, so they stay whole across 1.5x/2x/3x display
/// densities (no subpixel rounding).
///
/// Use these instead of literal numbers so spacing stays consistent and the
/// whole app's rhythm can be retuned from one place.
///
typedef Spacing = double;

abstract final class DipScale {
  const DipScale._();

  /// No space (0).
  static const double none = 0;

  /// Hairline / tight nudges (4).
  static const double xs = 4;

  /// Compact spacing (8).
  static const double sm = 8;

  /// Comfortable mid-step — the common 8/16 in-between (12).
  static const double smd = 12;

  /// Standard spacing (16).
  static const double md = 16;

  /// Group separation (24).
  static const double lg = 24;

  /// Section separation (32).
  static const double xl = 32;

  /// Large section separation (48).
  static const double xxl = 48;
}
