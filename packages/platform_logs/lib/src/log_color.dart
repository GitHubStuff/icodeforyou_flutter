// packages/platform_logs/lib/src/log_color.dart
enum LogColor {
  /// SGR 30.
  black('\x1B[30m'),

  /// SGR 31.
  red('\x1B[31m'),

  /// SGR 32.
  green('\x1B[32m'),

  /// SGR 33.
  yellow('\x1B[33m'),

  /// SGR 34.
  blue('\x1B[34m'),

  /// SGR 35.
  magenta('\x1B[35m'),

  /// SGR 36.
  cyan('\x1B[36m'),

  /// SGR 37.
  white('\x1B[37m'),

  /// SGR 90 — bright black, which every palette renders as a grey.
  grey('\x1B[90m'),

  /// SGR 91.
  brightRed('\x1B[91m'),

  /// SGR 92.
  brightGreen('\x1B[92m'),

  /// SGR 93.
  brightYellow('\x1B[93m'),

  /// SGR 94.
  brightBlue('\x1B[94m'),

  /// SGR 95.
  brightMagenta('\x1B[95m'),

  /// SGR 96.
  brightCyan('\x1B[96m'),

  /// SGR 97.
  brightWhite('\x1B[97m');

  const LogColor(this.code);

  /// SGR 0 — clears every attribute, including color.
  static const String reset = '\x1B[0m';

  /// The raw escape sequence that switches the foreground to this color.
  ///
  /// Everything printed after it stays colored until [reset] is emitted.
  /// Prefer [wrap], which pairs the two for you.
  final String code;

  /// Returns [text] colored with this color and followed by [reset].
  String wrap(String text) => '$code$text$reset';
}
