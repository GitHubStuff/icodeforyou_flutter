// package/lib/src/utils/trace_color.dart
// ignore_for_file: comment_references, public_member_api_docs

import 'dart:io';

enum TraceColor {
  blue('\x1B[34m'),
  brightCyan('\x1B[96m'),
  brightRed('\x1B[91m'),
  cyan('\x1B[36m'),
  green('\x1B[32m'),
  grey('\x1B[90m'),
  magenta('\x1B[35m'),
  red('\x1B[31m'),
  yellow('\x1B[33m')
  ;

  const TraceColor(this.code);

  final String code;

  static const String reset = '\x1B[0m';

  /// Wraps [text] in this color's escape codes when ANSI is supported;
  /// otherwise returns [text] unchanged.
  ///
  /// [supportsAnsi] overrides the default TTY check. Pass `() => true`
  /// to force coloring on, `() => false` to force it off (e.g. when the
  /// result is destined for a file or backend). Defaults to checking
  /// [stdout.supportsAnsiEscapes].
  String apply(String text, {bool Function()? supportsAnsi}) {
    final canColor = (supportsAnsi ?? _defaultSupportsAnsi)();
    return canColor ? '$code$text$reset' : text;
  }

  static bool _defaultSupportsAnsi() => stdout.supportsAnsiEscapes;
}
