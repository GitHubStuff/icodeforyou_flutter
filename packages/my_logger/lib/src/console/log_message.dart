// log_message.dart
part of 'my_loggerlog.dart';

// ============================================================================
// Private Data Models
// ============================================================================

class _LogMessage {
  const _LogMessage({
    required this.level,
    required this.message,
    required this.tag,
    required this.time,
    this.error,
    this.stackTrace,
    this.showIcon = true,
    this.showColor = true,
    this.frames = 1,
  });

  final LoggerLevel level;
  final dynamic message;
  final String tag;
  final DateTime time;
  final Object? error;
  final StackTrace? stackTrace;
  final bool showIcon;
  final bool showColor;
  final int frames;

  String get normalizedTag => tag.isEmpty ? _LogConstants.defaultTag : tag;
}
