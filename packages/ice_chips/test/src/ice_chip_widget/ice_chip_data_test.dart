// packages/ice_chips/test/src/ice_chip_widget/ice_chip_data_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ice_chips/src/ice_chip_widget/ice_chip_data.dart'
    show IceChipData;

/// Reference DTO used across the tests.
const _kData = IceChipData(id: 1, label: 'ONE', colorInt: 0xFF112233);

void main() {
  group('IceChipData', () {
    test('copyWith with no arguments returns an equal instance', () {
      final copy = _kData.copyWith();
      expect(copy, equals(_kData));
      expect(copy.id, 1);
      expect(copy.label, 'ONE');
      expect(copy.colorInt, 0xFF112233);
    });

    test('copyWith replaces every provided field', () {
      final copy = _kData.copyWith(
        id: 2,
        label: 'TWO',
        colorInt: 0xFF445566,
      );
      expect(copy.id, 2);
      expect(copy.label, 'TWO');
      expect(copy.colorInt, 0xFF445566);
    });

    test('props carry all three fields', () {
      expect(_kData.props, [1, 'ONE', 0xFF112233]);
    });

    test('value equality follows props', () {
      const same = IceChipData(id: 1, label: 'ONE', colorInt: 0xFF112233);
      const other = IceChipData(id: 9, label: 'ONE', colorInt: 0xFF112233);
      expect(_kData, equals(same));
      expect(_kData, isNot(equals(other)));
    });

    test('toString is the documented debug format', () {
      expect(
        _kData.toString(),
        'IceChipData(id: 1, label: "ONE", colorInt: ${0xFF112233})',
      );
    });
  });
}
