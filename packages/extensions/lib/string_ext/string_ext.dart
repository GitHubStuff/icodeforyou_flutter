// string_ext.dart
extension StringExt on String {
  /// Converts string to microseconds since epoch with error handling
  int? toMicrosecondsOrNull() {
    try {
      return DateTime.parse(this).microsecondsSinceEpoch;
    } catch (e) {
      return null;
    }
  }
}
