// lib/src/console/_log_formatters.dart

part of 'my_logger.dart';

String _formatTime(DateTime time) {
  final buffer = StringBuffer()
    ..write('${time.hour.toString().padLeft(2, '0')}:')
    ..write('${time.minute.toString().padLeft(2, '0')}:')
    ..write('${time.second.toString().padLeft(2, '0')}.')
    ..write('${time.millisecond.toString().padLeft(3, '0')} ');
  return buffer.toString();
}

String _formatIcon(LoggerLevel level, bool showIcon) {
  if (!showIcon) return '';
  return level.icon;
}

final class _DefaultColorFormatter implements _ColorFormatter {
  const _DefaultColorFormatter();

  @override
  String apply(String message, LoggerLevel level, bool showColor) {
    if (!showColor) return message;
    return '${level.color}$message${_LogConstants.reset}';
  }
}

final class _DefaultStackTraceFormatter implements _StackTraceFormatter {
  const _DefaultStackTraceFormatter();

  @override
  String? format(
    StackTrace? stackTrace,
    int frames,
    bool showColor,
    String tag,
  ) {
    if (stackTrace == null) return null;

    final lines = stackTrace.toString().split('\n').take(frames).toList();

    return frames == 1
        ? _formatSingleFrame(lines.first, showColor, tag)
        : _formatMultipleFrames(lines, showColor, tag);
  }

  String _formatSingleFrame(String line, bool showColor, String tag) {
    final cleaned = _clean(line);
    return showColor
        ? '[$tag]  ${_LogConstants.red}$cleaned${_LogConstants.reset}'
        : '[$tag]  $cleaned';
  }

  String _formatMultipleFrames(
    List<String> lines,
    bool showColor,
    String tag,
  ) {
    final buffer = StringBuffer(
      showColor
          ? '[$tag] ${_LogConstants.red}StackTrace(${_LogConstants.reset}\n'
          : '[$tag] StackTrace(\n',
    );

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final cleaned = _clean(line);
      buffer.writeln(
        showColor
            ? '[$tag] ${_LogConstants.red}     $cleaned${_LogConstants.reset}'
            : '[$tag]      $cleaned',
      );
    }

    buffer.write(
      showColor
          ? '[$tag] ${_LogConstants.red})${_LogConstants.reset}'
          : '[$tag] )',
    );

    return buffer.toString();
  }

  String _clean(String line) => line
      .replaceFirst('_StringStackTrace', 'StackTrace')
      .replaceFirst('*StringStackTrace', 'StackTrace');
}
