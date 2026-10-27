// packages/platform_logs/lib/src/log_message.dart

import 'package:platform_logs/src/log_color.dart' show LogColor;

enum LogMessage {
  debug('🐞', LogColor.white),
  debugPrint('🖨️', LogColor.grey),
  error('💥', LogColor.red),
  warning('⚠️', LogColor.yellow),
  ;

  const LogMessage(this.emoji, this.color);

  final String emoji;
  final LogColor? color;
}
