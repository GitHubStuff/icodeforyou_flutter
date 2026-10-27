// packages/platform_logs/lib/src/plog.dart

import 'package:ext_datetime/ext_datetime.dart' show ExtDateTime;
import 'package:flutter/foundation.dart';
import 'package:platform_logs/src/log_message.dart' show LogMessage;

/// The first three characters of [text], right-padded with spaces when
/// [text] is shorter than three characters.
String _abbr(String text) =>
    (text.length >= 4 ? text.substring(0, 4) : text).padRight(4);

///
@immutable
abstract final class PLog {
  const PLog();

  static String _log(
    String message, {
    String tag = 'Tag',
    LogMessage? logMessage,
  }) {
    final timeStamp = DateTime.now().timeStamp();
    final emoji = logMessage?.emoji ?? '';

    final textBody = '$timeStamp ${_abbr(tag)} $emoji: $message';

    final color = logMessage?.color;

    final text = color?.wrap(textBody) ?? textBody;
    debugPrint(text);
    return text;
  }

  /// Debug 🐞
  static String d(String text, {String tag = 'DBUG'}) =>
      _log(text, tag: tag, logMessage: LogMessage.debug);

  /// Mimics debugPrint 🖨️
  static String dp(String text) => _log(
    text,
    tag: '',
    logMessage: LogMessage.debugPrint,
  );

  /// Error 💥
  static String e(String message, {String tag = 'ERR'}) => _log(
    message,
    tag: tag,
    logMessage: LogMessage.error,
  );

  ///
  static String w(String message, {String tag = 'WARN'}) => _log(
    message,
    tag: tag,
    logMessage: LogMessage.warning,
  );
}
