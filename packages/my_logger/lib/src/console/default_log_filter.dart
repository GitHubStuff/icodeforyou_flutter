// default_log_filter.dart
// ignore_for_file: use_setters_to_change_properties

part of 'my_loggerlog.dart';

class _DefaultLogFilter implements _LogFilter {
  _DefaultLogFilter({String? filterTag}) : _filterTag = filterTag;

  String? _filterTag;

  void setTag(String? tag) => _filterTag = tag;
  String? get currentTag => _filterTag;

  @override
  bool shouldLog(_LogMessage message) {
    if (message.level >= LoggerLevel.warning) return true;
    if (_filterTag == null) return true;
    return message.normalizedTag == _filterTag;
  }
}
