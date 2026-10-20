// packages/ext_duration/lib/src/formatter/compose_format.dart

String composeFormat(
  Duration duration, {
  required bool showPlusSign,
  required bool showLeaderZero,
  required bool padHours,
}) {
  final StringBuffer result = StringBuffer();

  if (duration.isNegative) {
    result.write('%n');
  } else {
    final plusSign = showPlusSign ? '+' : '';
    result.write(plusSign);
  }

  bool showZero = showLeaderZero;
  final abs = duration.abs();

  if (abs.inDays > 0 || showZero) {
    result.write('%d ');
    showZero = true;
  }

  if (abs.inHours % Duration.hoursPerDay > 0 || showZero) {
    final fmt = padHours ? '%02h:' : '%h:';
    result.write(fmt);
    showZero = true;
  }

  if (abs.inMinutes % Duration.minutesPerDay > 0 || showZero) {
    final minFmt = showZero ? '%02m:' : '%m:';
    result.write(minFmt);
    showZero = true;
  }

  /// seconds are always shown, thare has to be at least one number
  final secFmt = showZero ? '%02s' : '%s';
  result.write(secFmt);

  return result.toString();
}
