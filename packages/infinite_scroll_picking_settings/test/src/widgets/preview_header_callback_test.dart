// infinite_scroll_picking_settings/test/src/widgets/preview_header_callback_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';
import 'package:infinite_scroll_picking_settings/src/picker_visual_settings/picker_visual_settings.dart';
import 'package:infinite_scroll_picking_settings/src/settings/settings_cubit.dart';
import 'package:infinite_scroll_picking_settings/src/settings/settings_state/settings_state.dart';
import 'package:infinite_scroll_picking_settings/src/widgets/settings_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

void main() {
  late _MockSettingsCubit cubit;

  setUp(() {
    cubit = _MockSettingsCubit();
    when(() => cubit.state).thenReturn(
      const SettingsLoaded(settings: PickerVisualSettings(), isDirty: false),
    );
  });

  testWidgets(
    'preview picker onItemSelected is a no-op and is invokable',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SettingsCubit>.value(
            value: cubit,
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump();

      final picker = tester.widget<InfiniteScrollPicker<int, String>>(
        find.byType(InfiniteScrollPicker<int, String>),
      );

      expect(
        () => picker.onItemSelected('0', 0),
        returnsNormally,
      );
    },
  );
}
