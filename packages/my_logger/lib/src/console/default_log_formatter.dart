// default_log_formatter.dart
part of 'my_loggerlog.dart';

class _DefaultLogFormatter implements _LogFormatter {
  _DefaultLogFormatter({
    _StackTraceFormatter? stackTraceFormatter,
    _ColorFormatter? colorFormatter,
  }) : _stackTraceFormatter =
           stackTraceFormatter ?? _DefaultStackTraceFormatter(),
       _colorFormatter = colorFormatter ?? _DefaultColorFormatter();

  final _StackTraceFormatter _stackTraceFormatter;
  final _ColorFormatter _colorFormatter;

  @override
  String format(_LogMessage message) {
    final timeString = _TimeFormatter.format(message.time);
    final iconString = _IconFormatter.format(message.level, message.showIcon);
    final baseMessage = '$timeString$iconString${message.message}';

    final coloredMessage = _colorFormatter.apply(
      baseMessage,
      message.level,
      message.showColor,
    );

    final stackTraceString = _stackTraceFormatter.format(
      message.stackTrace,
      message.frames,
      message.showColor,
      message.normalizedTag,
    );

    return stackTraceString != null
        ? '$coloredMessage\n$stackTraceString'
        : coloredMessage;
  }
}
