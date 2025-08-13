// int_ext.dart
extension IntExt on int {
  DateTime toUtc() {
    return DateTime.fromMicrosecondsSinceEpoch(this, isUtc: true);
  }
}
