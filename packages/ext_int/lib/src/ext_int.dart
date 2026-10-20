// packages/ext_int/lib/src/ext_int.dart

import 'package:flutter/material.dart' show Color;

/// Extension methods on [int] for common conversions used throughout the
/// monorepo: colours, human-readable pluralised phrases, and UTC timestamps.
///
/// Import the barrel and call the methods directly on any integer:
///
/// ```dart
/// import 'package:ext_int/ext_int.dart';
///
/// final accent = 0xFF2196F3.toColor();
/// final label = 3.toSimpleSpeech(name: 'item'); // '3 items'
/// final when = 1700000000000000.toUtc();         // 2023-11-14 22:13:20.000Z
/// ```

/// Conversion helpers on [int].
///
/// Every method is pure and allocation-light; none of them mutate state or
/// depend on anything other than the receiver and their arguments, so they
/// are safe to call from `build` methods and from isolates.
extension ExtInt on int {
  /// Interprets this integer as a 32-bit ARGB value and returns the
  /// corresponding [Color].
  ///
  /// The layout is the standard Flutter one: the highest byte is alpha, then
  /// red, green and blue. An integer that fits in 24 bits therefore has an
  /// alpha of `0x00` and is fully transparent — a frequent source of
  /// "my colour isn't showing" bugs:
  ///
  /// ```dart
  /// 0xFF2196F3.toColor(); // opaque Material blue
  /// 0x2196F3.toColor();   // the same hue, but alpha 0 — invisible
  /// ```
  ///
  /// Bits above the 32nd are ignored by [Color], which masks the value.
  Color toColor() => Color(this);

  /// Formats this integer as a count followed by the correctly pluralised
  /// noun.
  ///
  /// [singular] is used when the magnitude of this integer is exactly `1`;
  /// [plural] is used for every other value, including `0` and negatives:
  ///
  /// ```dart
  /// 1.toSpeech(singular: 'day', plural: 'days');   // '1 day'
  /// -1.toSpeech(singular: 'day', plural: 'days');  // '-1 day'
  /// 0.toSpeech(singular: 'day', plural: 'days');   // '0 days'
  /// 12.toSpeech(singular: 'day', plural: 'days');  // '12 days'
  /// ```
  ///
  /// The number is rendered with [toString], so the sign is always
  /// preserved. This method performs no locale-aware number formatting; if
  /// you need thousands separators or localised plural rules, format the
  /// number yourself before building the phrase.
  ///
  /// See also [toSimpleSpeech], which derives [plural] by appending `s`.
  String toSpeech({required String singular, required String plural}) =>
      (abs() == 1) ? '$this $singular' : '$this $plural';

  /// Formats this integer as a count followed by [name], pluralised with a
  /// trailing `s` when the magnitude is not exactly `1`.
  ///
  /// This is a convenience wrapper over [toSpeech] for the overwhelmingly
  /// common regular-English case:
  ///
  /// ```dart
  /// 1.toSimpleSpeech(name: 'file'); // '1 file'
  /// 4.toSimpleSpeech(name: 'file'); // '4 files'
  /// ```
  ///
  /// It does **not** handle irregular plurals (`child`/`children`,
  /// `box`/`boxes`, `sheep`/`sheep`). For those, call [toSpeech] and supply
  /// the plural form explicitly.
  String toSimpleSpeech({required String name}) =>
      toSpeech(singular: name, plural: '${name}s');

  /// Interprets this integer as a number of microseconds since the Unix epoch
  /// (`1970-01-01T00:00:00Z`) and returns the corresponding UTC [DateTime].
  ///
  /// This is the inverse of [DateTime.microsecondsSinceEpoch] and matches
  /// the storage convention used for timestamps across the monorepo's Drift
  /// schemas, where every timestamp column is an integer of microseconds:
  ///
  /// ```dart
  /// 0.toUtc();                // 1970-01-01 00:00:00.000Z
  /// 1700000000000000.toUtc(); // 2023-11-14 22:13:20.000Z
  /// (-1000000).toUtc();       // 1969-12-31 23:59:59.000Z
  /// ```
  ///
  /// The result always has [DateTime.isUtc] set to `true`; convert with
  /// [DateTime.toLocal] if you need wall-clock time for display.
  ///
  /// Do not pass milliseconds or seconds — the value will be silently
  /// interpreted as microseconds and land in early 1970.
  DateTime toUtc() => DateTime.fromMicrosecondsSinceEpoch(this, isUtc: true);
}
