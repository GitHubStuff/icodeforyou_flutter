// my_logger/lib/src/console/_default_log_filter.dart
part of 'my_logger.dart';

final class _DefaultLogFilter implements _LogFilter {
  _DefaultLogFilter({String? filterTag}) : tag = filterTag;

  String? tag;

  @override
  bool shouldLog(_LogMessage message) {
    if (message.level >= LoggerLevel.warning) return true;
    if (tag == null) return true;
    return message.normalizedTag == tag;
  }
}
