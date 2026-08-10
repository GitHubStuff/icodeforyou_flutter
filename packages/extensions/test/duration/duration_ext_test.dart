// test/duration/duration_ext_test.dart

import 'package:extensions/duration/duration_ext.dart' show DurationExt;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DurationExt', () {
    test('animate is the 200ms minimum animation duration', () {
      expect(DurationExt.animate, const Duration(milliseconds: 200));
    });
  });
}
