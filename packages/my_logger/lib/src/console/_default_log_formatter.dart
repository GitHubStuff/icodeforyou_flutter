// lib/src/console/_default_log_formatter.dart

part of 'my_logger.dart';

final class _DefaultLogFormatter implements _LogFormatter {
  const _DefaultLogFormatter({
    _StackTraceFormatter? stackTraceFormatter,
    _ColorFormatter? colorFormatter,
  })  : _stackTraceFormatter =
            stackTraceFormatter ?? const _DefaultStackTraceFormatter(),
        _colorFormatter = colorFormatter ?? const _DefaultColorFormatter();

  final _StackTraceFormatter _stackTraceFormatter;
  final _ColorFormatter _colorFormatter;

  @override
  String format(_LogMessage message) {
    final time = _formatTime(message.time);
    final icon = _formatIcon(message.level, message.showIcon);
    final colored = _colorFormatter.apply(
      '$time$icon${message.message}',
      message.level,
      message.showColor,
    );
    final stackTrace = _stackTraceFormatter.format(
      message.stackTrace,
      message.frames,
      message.showColor,
      message.normalizedTag,
    );

    return stackTrace != null ? '$colored\n$stackTrace' : colored;
  }
}
