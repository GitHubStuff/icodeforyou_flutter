part of 'my_loggerlog.dart';

class _DebugLogOutput implements _LogOutput {
  @override
  String write(String formattedMessage, _LogMessage message) {
    if (kDebugMode) {
      debugPrint(formattedMessage);
    } else {
      // Profile mode/other scenarios: use developer.log() for IDE vs standalone
      developer.log(
        formattedMessage,
        name: message.normalizedTag,
        time: message.time,
        level: message.level.value,
        error: message.error,
      );
    }
    return formattedMessage;
  }
}
