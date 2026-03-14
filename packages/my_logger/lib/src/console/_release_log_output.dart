// lib/src/console/_release_log_output.dart

part of 'my_logger.dart';

final class _ReleaseLogOutput implements _LogOutput {
  const _ReleaseLogOutput();

  @override
  String write(String formattedMessage, _LogMessage message) {
    final output = message.error != null
        // ignore: lines_longer_than_80_chars
        ? '[${message.normalizedTag}] $formattedMessage\nError: ${message.error}'
        : '[${message.normalizedTag}] $formattedMessage';

    // ignore: avoid_print
    print(output);
    return output;
  }
}
