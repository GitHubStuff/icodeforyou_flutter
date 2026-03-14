// log_abstracts.dart
// ignore_for_file: one_member_abstracts

part of 'my_loggerlog.dart';

abstract class _LogFormatter {
  String format(_LogMessage message);
}

abstract class _LogOutput {
  String write(String formattedMessage, _LogMessage message);
}

abstract class _StackTraceFormatter {
  String? format(
    StackTrace? stackTrace,
    int frames,
    bool showColor,
    String tag,
  );
}

abstract class _ColorFormatter {
  String apply(String message, LoggerLevel level, bool showColor);
}

abstract class _LogFilter {
  bool shouldLog(_LogMessage message);
}
