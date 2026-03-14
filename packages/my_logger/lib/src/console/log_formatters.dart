// log_formatters.dart
part of 'my_loggerlog.dart';

// ============================================================================
// Private Implementations
// ============================================================================
class _TimeFormatter {
  static String format(DateTime time) {
    final buffer = StringBuffer()
      ..write('${time.hour.toString().padLeft(2, '0')}:')
      ..write('${time.minute.toString().padLeft(2, '0')}:')
      ..write('${time.second.toString().padLeft(2, '0')}.')
      ..write('${time.millisecond.toString().padLeft(3, '0')} ');

    return buffer.toString();
  }
}

class _IconFormatter {
  static String format(LoggerLevel level, bool showIcon) {
    if (!showIcon) return '';

    return kReleaseMode
        ? (level.fat ? level.icon : '${level.icon} ')
        : level.icon;
  }
}

class _DefaultColorFormatter implements _ColorFormatter {
  @override
  String apply(String message, LoggerLevel level, bool showColor) {
    if (!showColor) return message;
    return '${level.color}$message${_LogConstants.reset}';
  }
}

class _DefaultStackTraceFormatter implements _StackTraceFormatter {
  @override
  String? format(
    StackTrace? stackTrace,
    int frames,
    bool showColor,
    String tag,
  ) {
    if (stackTrace == null) return null;

    final lines = stackTrace.toString().split('\n').take(frames).toList();

    if (frames == 1) {
      return _formatSingleFrame(lines.first, showColor, tag);
    }

    return _formatMultipleFrames(lines, showColor, tag);
  }

  String _formatSingleFrame(String line, bool showColor, String tag) {
    final cleanedLine = _cleanStackTraceLine(line);
    return showColor
        ? '[$tag]  ${_LogConstants.red}$cleanedLine${_LogConstants.reset}'
        : '[$tag]  $cleanedLine';
  }

  String _formatMultipleFrames(List<String> lines, bool showColor, String tag) {
    final buffer = StringBuffer(
      showColor
          ? '[$tag] ${_LogConstants.red}StackTrace(${_LogConstants.reset}\n'
          : '[$tag] StackTrace(\n',
    );

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      final cleanedLine = _cleanStackTraceLine(line);

      if (showColor) {
        buffer.writeln(
          '[$tag] ${_LogConstants.red}     $cleanedLine${_LogConstants.reset}',
        );
      } else {
        buffer.writeln('[$tag]      $cleanedLine');
      }
    }

    buffer.write(
      showColor
          ? '[$tag] ${_LogConstants.red})${_LogConstants.reset}'
          : '[$tag] )',
    );

    return buffer.toString();
  }

  String _cleanStackTraceLine(String line) {
    return line
        .replaceFirst('_StringStackTrace', 'StackTrace')
        .replaceFirst('*StringStackTrace', 'StackTrace');
  }
}
