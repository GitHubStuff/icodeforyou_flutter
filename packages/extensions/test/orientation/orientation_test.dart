// packages/extensions/test/orientation/orientation_test.dart

import 'package:extensions/extensions.dart' show OrientationExt;
import 'package:flutter/widgets.dart' show Orientation;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrientationExt', () {
    test('isPortrait is true only for portrait', () {
      expect(Orientation.portrait.isPortrait, isTrue);
      expect(Orientation.landscape.isPortrait, isFalse);
    });

    test('isLandscape is true only for landscape', () {
      expect(Orientation.landscape.isLandscape, isTrue);
      expect(Orientation.portrait.isLandscape, isFalse);
    });
  });
}
