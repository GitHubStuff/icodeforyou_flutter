// packages/platform_logs/lib/src/log_color.dart

/// ANSI foreground color escape codes used to style console and terminal logs.
///
/// Each constant encapsulates an ECMA-48 Select Graphic Rendition (SGR) code
/// that alters subsequent terminal output color until [reset] is encountered.
///
/// For convenient, scoped formatting that automatically resets formatting,
/// use [wrap].
///
/// Example:
/// ```dart
/// print(LogColor.green.wrap('Success!'));
/// print('${LogColor.red.code}Error occurred${LogColor.reset}');
/// ```
enum LogColor {
  /// SGR 30 — standard black foreground.
  black('\x1B[30m'),

  /// SGR 31 — standard red foreground.
  red('\x1B[31m'),

  /// SGR 32 — standard green foreground.
  green('\x1B[32m'),

  /// SGR 33 — standard yellow foreground.
  yellow('\x1B[33m'),

  /// SGR 34 — standard blue foreground.
  blue('\x1B[34m'),

  /// SGR 35 — standard magenta foreground.
  magenta('\x1B[35m'),

  /// SGR 36 — standard cyan foreground.
  cyan('\x1B[36m'),

  /// SGR 37 — standard white foreground.
  white('\x1B[37m'),

  /// SGR 90 — bright black foreground, rendered as grey across terminal
  /// palettes.
  grey('\x1B[90m'),

  /// SGR 91 — high-intensity bright red foreground.
  brightRed('\x1B[91m'),

  /// SGR 92 — high-intensity bright green foreground.
  brightGreen('\x1B[92m'),

  /// SGR 93 — high-intensity bright yellow foreground.
  brightYellow('\x1B[93m'),

  /// SGR 94 — high-intensity bright blue foreground.
  brightBlue('\x1B[94m'),

  /// SGR 95 — high-intensity bright magenta foreground.
  brightMagenta('\x1B[95m'),

  /// SGR 96 — high-intensity bright cyan foreground.
  brightCyan('\x1B[96m'),

  /// SGR 97 — high-intensity bright white foreground.
  brightWhite('\x1B[97m');

  /// Creates a [LogColor] with the associated ANSI escape [code].
  const LogColor(this.code);

  /// SGR 0 — clears all applied text attributes, styles, and colors.
  static const String reset = '\x1B[0m';

  /// The raw ANSI escape sequence that switches the terminal foreground to
  /// this color.
  ///
  /// Output emitted after this sequence remains colored until [reset]
  /// is output.
  /// Prefer using [wrap] to handle formatting and resetting automatically.
  final String code;

  /// Returns [text] prefixed with this color's ANSI [code] and suffixed
  /// with [reset].
  ///
  /// Safe for inline printing without leaking styles into subsequent output.
  ///
  /// Example:
  /// ```dart
  /// print(LogColor.cyan.wrap('Connected to server'));
  /// ```
  String wrap(String text) => '$code$text$reset';
}
