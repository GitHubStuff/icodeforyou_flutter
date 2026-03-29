// test/src/icechips/ice_chip_padding_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:since_when_widgets/since_when_widgets.dart';

void main() {
  group('IceChipPadding', () {
    test('tight has padding value of 2', () {
      expect(IceChipPadding.tight.padding, 2.0);
    });

    test('normal has padding value of 4', () {
      expect(IceChipPadding.normal.padding, 4.0);
    });

    test('loose has padding value of 6', () {
      expect(IceChipPadding.loose.padding, 6.0);
    });

    test('values contains all three cases', () {
      expect(IceChipPadding.values, [
        IceChipPadding.tight,
        IceChipPadding.normal,
        IceChipPadding.loose,
      ]);
    });
  });
}
