// lib/src/console/_default_log_filter.dart

part of 'my_logger.dart';

final class _DefaultLogFilter implements _LogFilter {
  _DefaultLogFilter({String? filterTag}) : _filterTag = filterTag;

  String? _filterTag;

  set tag(String? value) => _filterTag = value;
  // ignore: unnecessary_getters_setters
  String? get tag => _filterTag;

  @override
  bool shouldLog(_LogMessage message) {
    if (message.level >= LoggerLevel.warning) return true;
    if (_filterTag == null) return true;
    return message.normalizedTag == _filterTag;
  }
}
