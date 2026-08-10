// packages/ice_chips/test/src/ice_chip_tray/ice_chip_tray_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray.dart'
    show IceChipsTray;
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray_cubit.dart'
    show IceChipsTrayCubit;
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray_layout.dart'
    show IceChipsTrayLayoutWrap;
import 'package:ice_chips/src/ice_chip_widget/ice_chip.dart' show IceChip;
import 'package:ice_chips/src/ice_chip_widget/ice_chip_data.dart'
    show IceChipData;

/// Test chip data covering two ids so selection can distinguish chips.
const _kChips = [
  IceChipData(id: 1, label: 'ONE', colorInt: 0xFFFF0000),
  IceChipData(id: 2, label: 'TWO', colorInt: 0xFF00FF00),
];

/// Key applied by the custom chip builder so the test can prove the
/// builder wrapped each chip.
const _kWrapperKey = Key('wrapper-1');

/// Pumps an [IceChipsTray] under a [MaterialApp] with the given [cubit].
Future<void> _pumpTray(
  WidgetTester tester,
  IceChipsTrayCubit cubit, {
  Widget Function(BuildContext, IceChipData, Widget)? chipBuilder,
  TextStyle? style,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: IceChipsTray(
            chipCount: _kChips.length,
            chipDataAt: (index) => _kChips[index],
            layout: const IceChipsTrayLayoutWrap(),
            chipBuilder: chipBuilder ??
                (context, data, chip) => chip,
            style: style,
          ),
        ),
      ),
    ),
  );
}

/// Pumps the tray relying entirely on constructor defaults
/// (identity chip builder, null style).
Future<void> _pumpTrayWithDefaults(
  WidgetTester tester,
  IceChipsTrayCubit cubit,
) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: IceChipsTray(
            chipCount: _kChips.length,
            chipDataAt: (index) => _kChips[index],
            layout: const IceChipsTrayLayoutWrap(),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('IceChipsTray', () {
    testWidgets('renders one IceChip per data item via the default '
        'identity builder', (tester) async {
      final cubit = IceChipsTrayCubit();
      addTearDown(cubit.close);

      await _pumpTrayWithDefaults(tester, cubit);

      expect(find.byType(IceChip), findsNWidgets(2));
      expect(find.text('ONE'), findsOneWidget);
      expect(find.text('TWO'), findsOneWidget);
    });

    testWidgets('tapping a chip toggles its id in the cubit',
        (tester) async {
      final cubit = IceChipsTrayCubit();
      addTearDown(cubit.close);

      await _pumpTrayWithDefaults(tester, cubit);
      await tester.tap(find.text('ONE'));
      await tester.pump();

      expect(cubit.state, {1});

      await tester.tap(find.text('ONE'));
      await tester.pump();

      expect(cubit.state, isEmpty);
    });

    testWidgets('selected chips render with showBorder true',
        (tester) async {
      final cubit = IceChipsTrayCubit({2});
      addTearDown(cubit.close);

      await _pumpTrayWithDefaults(tester, cubit);

      final chipOne = tester.widget<IceChip>(
        find.widgetWithText(IceChip, 'ONE'),
      );
      final chipTwo = tester.widget<IceChip>(
        find.widgetWithText(IceChip, 'TWO'),
      );
      expect(chipOne.showBorder, isFalse);
      expect(chipTwo.showBorder, isTrue);
    });

    testWidgets('custom chipBuilder wraps each chip', (tester) async {
      final cubit = IceChipsTrayCubit();
      addTearDown(cubit.close);

      await _pumpTray(
        tester,
        cubit,
        chipBuilder: (context, data, chip) => data.id == 1
            ? KeyedSubtree(key: _kWrapperKey, child: chip)
            : chip,
      );

      expect(find.byKey(_kWrapperKey), findsOneWidget);
    });

    testWidgets('style is forwarded to each IceChip', (tester) async {
      final cubit = IceChipsTrayCubit();
      addTearDown(cubit.close);

      const style = TextStyle(fontSize: 22);
      await _pumpTray(tester, cubit, style: style);

      final chip = tester.widget<IceChip>(
        find.widgetWithText(IceChip, 'ONE'),
      );
      expect(chip.style, style);
    });
  });
}
