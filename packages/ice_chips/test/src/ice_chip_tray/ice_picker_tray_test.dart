// packages/ice_chips/test/src/ice_chip_tray/ice_picker_tray_test.dart

import 'dart:async' show Completer, unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:ice_chips/src/glossary_types_todo.dart'
    show GlossaryReader, RecordTagDefinition, SinceWhenFailure;
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray.dart'
    show IceChipsTray;
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray_cubit.dart'
    show IceChipsTrayCubit;
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray_layout.dart'
    show IceChipsTrayLayoutWrap;
import 'package:ice_chips/src/ice_chip_tray/ice_picker_tray.dart'
    show IcePickerTray;
import 'package:ice_chips/src/ice_chip_widget/ice_chip.dart' show IceChip;
import 'package:ice_chips/src/ice_chip_widget/ice_chip_data.dart'
    show IceChipData;
import 'package:ice_chips/src/tags/tags_cubit.dart' show TagsCubit;
import 'package:since_when_framework/database.dart'
    show DatabaseOpenFailure;

/// Concrete cause wrapped by the error-state failure under test.
const _kCause = DatabaseOpenFailure('db exploded');

/// Reader whose [fetchAllTagDefinitions] resolves to a canned result,
/// or never resolves when [result] is left null (loading case).
final class _FakeReader implements GlossaryReader {
  /// Creates a reader returning [result], or hanging forever when null.
  _FakeReader([this.result]);

  /// Canned result; null means the returned future never completes.
  final Either<SinceWhenFailure, List<RecordTagDefinition>>? result;

  @override
  Future<Either<SinceWhenFailure, List<RecordTagDefinition>>>
      fetchAllTagDefinitions() {
    final canned = result;
    if (canned == null) {
      return Completer<
          Either<SinceWhenFailure, List<RecordTagDefinition>>>().future;
    }
    return Future.value(canned);
  }
}

/// Persisted tag rendered in the loaded-state tests.
const _kTag = RecordTagDefinition(
  id: 42,
  createdTimeStamp: 1000,
  tagName: 'FROST',
  color: 0xFF0000FF,
);

/// Key applied by the custom chip builder to prove it ran.
const _kWrapperKey = Key('picker-wrapper');

/// Pumps an [IcePickerTray] with the given [tagsCubit] provided above it.
Future<void> _pumpPicker(
  WidgetTester tester,
  TagsCubit tagsCubit, {
  Widget Function(BuildContext, IceChipData, Widget)? chipBuilder,
  TextStyle? style,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: tagsCubit),
            BlocProvider(create: (_) => IceChipsTrayCubit()),
          ],
          child: IcePickerTray(
            layout: const IceChipsTrayLayoutWrap(),
            chipBuilder: chipBuilder,
            style: style,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('IcePickerTray', () {
    testWidgets('TagsInitial renders nothing', (tester) async {
      final cubit = TagsCubit(reader: _FakeReader());
      addTearDown(cubit.close);

      await _pumpPicker(tester, cubit);

      expect(find.byType(IceChipsTray), findsNothing);
      expect(find.byType(IceChip), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('TagsLoading renders a progress indicator',
        (tester) async {
      final cubit = TagsCubit(reader: _FakeReader());
      addTearDown(cubit.close);
      unawaited(cubit.load());

      await _pumpPicker(tester, cubit);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TagsError renders the failure text in the error color',
        (tester) async {
      const failure = SinceWhenFailure(_kCause);
      final cubit = TagsCubit(reader: _FakeReader(Either.left(failure)));
      addTearDown(cubit.close);
      await cubit.load();

      await _pumpPicker(tester, cubit);

      final text = tester.widget<Text>(
        find.text('SinceWhenFailure: DatabaseOpenFailure: db exploded'),
      );
      expect(text.style?.color, isNotNull);
    });

    testWidgets('TagsLoaded renders the tray with translated chip data',
        (tester) async {
      final cubit = TagsCubit(
        reader: _FakeReader(Either.right(const [_kTag])),
      );
      addTearDown(cubit.close);
      await cubit.load();

      await _pumpPicker(tester, cubit);

      final chip = tester.widget<IceChip>(
        find.widgetWithText(IceChip, 'FROST'),
      );
      expect(chip.backgroundColorInt, 0xFF0000FF);
      expect(find.byType(IceChipsTray), findsOneWidget);
    });

    testWidgets('custom chipBuilder is forwarded to the tray',
        (tester) async {
      final cubit = TagsCubit(
        reader: _FakeReader(Either.right(const [_kTag])),
      );
      addTearDown(cubit.close);
      await cubit.load();

      await _pumpPicker(
        tester,
        cubit,
        chipBuilder: (context, data, chip) =>
            KeyedSubtree(key: _kWrapperKey, child: chip),
      );

      expect(find.byKey(_kWrapperKey), findsOneWidget);
    });

    testWidgets('style is forwarded through to each IceChip',
        (tester) async {
      final cubit = TagsCubit(
        reader: _FakeReader(Either.right(const [_kTag])),
      );
      addTearDown(cubit.close);
      await cubit.load();

      const style = TextStyle(fontSize: 20);
      await _pumpPicker(tester, cubit, style: style);

      final chip = tester.widget<IceChip>(
        find.widgetWithText(IceChip, 'FROST'),
      );
      expect(chip.style, style);
    });
  });
}
