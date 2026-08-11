// packages/ice_chips/test/src/ice_chip_tray/ice_chip_tray_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray_cubit.dart'
    show IceChipsTrayCubit;

void main() {
  group('IceChipsTrayCubit', () {
    test('initial state defaults to the empty set', () {
      final cubit = IceChipsTrayCubit();
      addTearDown(cubit.close);
      expect(cubit.state, isEmpty);
    });

    test('accepts a caller-supplied initial selection', () {
      final cubit = IceChipsTrayCubit({3, 4});
      addTearDown(cubit.close);
      expect(cubit.state, {3, 4});
    });

    test('toggle adds an unselected id', () {
      final cubit = IceChipsTrayCubit()..toggle(1);
      addTearDown(cubit.close);
      expect(cubit.state, {1});
    });

    test('toggle removes a selected id', () {
      final cubit = IceChipsTrayCubit({1, 2})..toggle(1);
      addTearDown(cubit.close);
      expect(cubit.state, {2});
    });

    test('selectAll replaces the selection wholesale', () {
      final cubit = IceChipsTrayCubit({9})..selectAll([1, 2, 2, 3]);
      addTearDown(cubit.close);
      expect(cubit.state, {1, 2, 3});
    });

    test('clear empties the selection', () {
      final cubit = IceChipsTrayCubit({1, 2})..clear();
      addTearDown(cubit.close);
      expect(cubit.state, isEmpty);
    });

    test('isSelected reflects membership', () {
      final cubit = IceChipsTrayCubit({5});
      addTearDown(cubit.close);
      expect(cubit.isSelected(5), isTrue);
      expect(cubit.isSelected(6), isFalse);
    });

    test('count reflects the selection size', () {
      final cubit = IceChipsTrayCubit({1, 2, 3});
      addTearDown(cubit.close);
      expect(cubit.count, 3);
    });
  });
}
