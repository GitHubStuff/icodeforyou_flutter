// lib/src/console/_debug_log_output.dart

part of 'my_logger.dart';

final class _DebugLogOutput implements _LogOutput {
  const _DebugLogOutput();

  @override
  String write(String formattedMessage, _LogMessage message) {
    developer.log(
      formattedMessage,
      name: message.normalizedTag,
      time: message.time,
      level: message.level.value,
      error: message.error,
    );
    return formattedMessage;
  }
}
