// release_log_output.dart

part of 'my_loggerlog.dart';

class _ReleaseLogOutput implements _LogOutput {
  @override
  String write(String formattedMessage, _LogMessage message) {
    String completeOutput = '[${message.normalizedTag}] $formattedMessage';
    if (message.error != null) {
      completeOutput += '\nError: ${message.error}';
    }
    // ignore: avoid_print
    print(completeOutput);
    return completeOutput;
  }
}
