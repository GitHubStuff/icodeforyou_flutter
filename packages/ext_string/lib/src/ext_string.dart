// packages/ext_string/lib/src/ext_string.dart

import 'package:flutter/widgets.dart';

/// Convenience extensions on [String] for Flutter applications.
///
/// Every member is a pure function of the receiver and its arguments: no
/// member mutates shared state, touches the widget tree, or requires a
/// [BuildContext]. This makes them safe to call from anywhere — build
/// methods, cubits, isolates, or unit tests — as long as the Flutter
/// bindings are initialised where a member depends on them (see
/// [pixelSize]).
///
/// ```dart
/// import 'package:ext_string/ext_string.dart';
///
/// final size = 'Hello'.pixelSize(style: const TextStyle(fontSize: 14));
/// final micros = '2024-01-01'.toMicrosecondsOrNull();
/// ```
extension ExtString on String {
  /// Measures the space this string occupies when rendered with [style].
  ///
  /// Lays the text out with a short-lived [TextPainter] and returns the
  /// resulting [TextPainter.size], in logical pixels. This is the same
  /// measurement the framework performs inside [RichText], so the result
  /// matches what a [Text] widget using the same [style] would occupy —
  /// provided the widget is given the same constraints and text settings
  /// (see *Caveats* below). The painter is disposed before returning, so
  /// no engine resources outlive the call.
  ///
  /// Typical uses are sizing a container before the text is laid out,
  /// deciding whether a label fits a fixed-width slot, computing column
  /// widths for tabular layouts, or checking for overflow ahead of time.
  ///
  /// ## Parameters
  ///
  /// * [style] — the [TextStyle] applied to the whole string. Required,
  ///   because an unstyled [TextSpan] inherits nothing outside a widget
  ///   tree and would measure with platform defaults you did not choose.
  ///   At minimum, supply [TextStyle.fontSize]; include
  ///   [TextStyle.fontFamily], [TextStyle.fontWeight], and
  ///   [TextStyle.letterSpacing] whenever the on-screen text uses them,
  ///   since each one changes the measured width.
  /// * [textDirection] — the directionality used for layout. Defaults to
  ///   [TextDirection.ltr]. Pass [TextDirection.rtl] for right-to-left
  ///   scripts; mixed-direction text is resolved according to the Unicode
  ///   bidirectional algorithm relative to this base direction.
  /// * [textAlign] — how lines are aligned within the available width.
  ///   Defaults to [TextAlign.start]. Alignment affects line placement,
  ///   not the returned size, unless [maxWidth] is finite, in which case
  ///   [TextAlign.justify] and friends can change the width of the
  ///   reported bounds.
  /// * [textScaler] — the scaling applied to font sizes, mirroring the
  ///   user's accessibility text-size setting. Defaults to
  ///   [TextScaler.noScaling]. To match an on-screen [Text] widget, pass
  ///   `MediaQuery.textScalerOf(context)` from the same subtree.
  /// * [maxWidth] — the width at which the text wraps. Defaults to
  ///   [double.infinity], meaning the text is laid out on a single
  ///   unbroken line (explicit `\n` characters still break). Pass the
  ///   actual constraint the text will be rendered under to get an
  ///   accurate multi-line height.
  /// * [maxLines] — an optional cap on the number of lines. When set,
  ///   text beyond the cap is truncated and the returned height reflects
  ///   at most [maxLines] lines. Pass `null` (the default) for no cap.
  ///
  /// ## Returns
  ///
  /// A [Size] whose [Size.width] is the width of the widest laid-out line
  /// and whose [Size.height] is the total height of all laid-out lines,
  /// both in logical pixels. For an empty string the width is `0` and the
  /// height is one line of [style] (fonts have height even with no
  /// glyphs).
  ///
  /// ## Caveats
  ///
  /// * [DefaultTextStyle], [Directionality], and [MediaQuery] from the
  ///   widget tree are **not** consulted, since no [BuildContext] is
  ///   available. Everything — including [textScaler] — must be passed
  ///   in explicitly.
  /// * Requires an initialised Flutter binding, because [TextPainter]
  ///   depends on the engine's font subsystem. In tests, use
  ///   `testWidgets` or call
  ///   `TestWidgetsFlutterBinding.ensureInitialized()` first.
  /// * Each call allocates a [TextPainter] and performs a full layout.
  ///   This is cheap for a handful of calls per frame but should not be
  ///   invoked in a tight loop over thousands of strings; memoise the
  ///   result when the inputs are stable.
  /// * Glyph fallback, emoji, and complex scripts are measured using
  ///   whatever fonts the engine resolves on the current platform, so
  ///   results can differ across operating systems.
  ///
  /// ## Example
  ///
  /// ```dart
  /// const style = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  ///
  /// // Single line, unconstrained width.
  /// final single = 'Sign in'.pixelSize(style: style);
  ///
  /// // Wrapped to 120 logical pixels, at most two lines, honouring the
  /// // user's text-size setting.
  /// final wrapped = 'A somewhat longer label that will wrap'.pixelSize(
  ///   style: style,
  ///   textScaler: MediaQuery.textScalerOf(context),
  ///   maxWidth: 120,
  ///   maxLines: 2,
  /// );
  ///
  /// final fits = single.width <= 96;
  /// ```
  ///
  /// See also:
  ///
  /// * [TextPainter], which performs the underlying layout.
  /// * [TextPainter.layout], which accepts the same width constraint.
  /// * [Text] and [RichText], the widgets whose rendering this mirrors.
  Size pixelSize({
    required TextStyle style,
    TextDirection textDirection = TextDirection.ltr,
    TextAlign textAlign = TextAlign.start,
    TextScaler textScaler = TextScaler.noScaling,
    double maxWidth = double.infinity,
    int? maxLines,
  }) {
    final textPainter =
        TextPainter(
          text: TextSpan(
            text: this,
            style: style,
          ),
          textDirection: textDirection,
          textAlign: textAlign,
          textScaler: textScaler,
          maxLines: maxLines,
        )..layout(
          maxWidth: maxWidth,
        );
    final size = textPainter.size;
    textPainter.dispose();
    return size;
  }

  /// Parses this string as an ISO 8601 date-time and returns the number of
  /// microseconds since the Unix epoch, or `null` if parsing fails.
  ///
  /// The result is the value of [DateTime.microsecondsSinceEpoch] for the
  /// parsed instant, where the epoch is `1970-01-01T00:00:00Z`. Strings
  /// before the epoch yield negative values.
  ///
  /// ## Accepted formats
  ///
  /// Parsing is delegated to [DateTime.tryParse], so every form it accepts
  /// is accepted here, including:
  ///
  /// * `"2024-01-01"` — date only, interpreted as local midnight.
  /// * `"2024-01-01T13:45:00"` — date and time, interpreted as local time.
  /// * `"2024-01-01T13:45:00Z"` — UTC.
  /// * `"2024-01-01T13:45:00+02:00"` — with an explicit UTC offset.
  /// * `"2024-01-01 13:45:00.123456"` — space separator, fractional seconds.
  ///
  /// Strings without a `Z` suffix or offset are treated as **local time**,
  /// so the returned microsecond value depends on the device's time zone.
  /// Append `Z` (or an offset) when a zone-independent result is required.
  ///
  /// ## Failure
  ///
  /// Any string [DateTime.tryParse] rejects yields `null`; no exception is
  /// thrown. Leading or trailing whitespace is **not** trimmed and will
  /// cause parsing to fail; call [String.trim] first if the input may be
  /// padded.
  ///
  /// ## Example
  ///
  /// ```dart
  /// '2024-01-01T00:00:00Z'.toMicrosecondsOrNull(); // 1704067200000000
  /// '1969-12-31T23:59:59Z'.toMicrosecondsOrNull(); // -1000000
  /// 'not a date'.toMicrosecondsOrNull();           // null
  /// ''.toMicrosecondsOrNull();                     // null
  /// ```
  ///
  /// See also:
  ///
  /// * [DateTime.parse], for the full grammar of accepted strings.
  /// * [DateTime.fromMicrosecondsSinceEpoch], to turn the result back into
  ///   a [DateTime].
  int? toMicrosecondsOrNull() =>
      DateTime.tryParse(this)?.microsecondsSinceEpoch;
}
