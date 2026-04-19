// my_logger/lib/src/console/_log_level.dart
part of 'my_logger.dart';

const String _blue = '\x1B[34m';
const String _brightCyan = '\x1B[96m';
const String _brightRed = '\x1B[91m';
const String _cyan = '\x1B[36m';
const String _green = '\x1B[32m';
const String _grey = '\x1B[90m';
const String _magenta = '\x1B[35m';
const String _red = '\x1B[31m';
const String _yellow = '\x1B[33m';

/// Defines the severity levels available to [MyLogger].
///
/// Each level carries a numeric [value] for ordered comparison,
/// an [icon] prefix, an ANSI [color] code, and a [fat] flag that
/// controls whether the output is bold/emphasised in the console.
enum LoggerLevel {
  /// Captures all log output; used as a filter floor.
  all(0, '', _grey, false),

  /// Fine-grained diagnostic tracing.
  trace(1000, '🧭 ', _grey, true),

  /// Developer-facing debug information.
  debug(2000, '🐞 ', _cyan, true),

  /// General informational messages.
  info(3000, 'ℹ️ ', _blue, false),

  /// Markers for in-progress refactoring work.
  refactor(4000, '🪛 ', _green, false),

  /// Non-fatal conditions that warrant attention.
  warning(5000, '⚠️ ', _yellow, false),

  /// Events forwarded to a crash-reporting service.
  crashlytics(6000, '📉 ', _magenta, true),

  /// Recoverable errors.
  error(7000, '❗️ ', _red, true),

  /// Unrecoverable failures.
  fatal(8000, '☠️ ', _brightRed, false),

  /// Structured output intended for downstream consumers.
  output(9000, '💡 ', _brightCyan, true),
  ;

  /// Creates a [LoggerLevel] with the given [value], [icon], [color],
  /// and [fat] flag.
  // ignore: avoid_positional_boolean_parameters
  const LoggerLevel(this.value, this.icon, this.color, this.fat);

  /// Numeric severity; higher values indicate greater severity.
  final int value;

  /// Emoji prefix prepended to each log line.
  final String icon;

  /// ANSI escape code applied to the log line in console output.
  final String color;

  /// Whether the log line should be rendered in bold/emphasised style.
  final bool fat;

  /// Returns `true` if this level is less severe than [other].
  bool operator <(LoggerLevel other) => value < other.value;

  /// Returns `true` if this level is less severe than or equal to [other].
  bool operator <=(LoggerLevel other) => value <= other.value;

  /// Returns `true` if this level is more severe than [other].
  bool operator >(LoggerLevel other) => value > other.value;

  /// Returns `true` if this level is more severe than or equal to [other].
  bool operator >=(LoggerLevel other) => value >= other.value;
}
