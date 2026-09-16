// test/glossary_edits/cubit/glossary_edit_cubit_test.dart
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sincewhen_models/sincewhen_models.dart';
import 'package:sincewhen_widgets/src/glossary_edits/cubit/glossary_edit_cubit.dart';
import 'package:sincewhen_widgets/src/glossary_edits/cubit/glossary_edit_state.dart';

class MockGlossaryRepository extends Mock implements GlossaryRepository {}

void main() {
  late MockGlossaryRepository mockGlossaryRepo;
  late DateTime testDateTime;

  const testGlossaryItem = GlossaryItem(
    id: 1,
    createdTimestamp: 1620000000000,
    tag: 'test-tag',
    colorArgb: 0xFF42A5F5,
    descr: 'Test description',
  );

  setUpAll(() {
    registerFallbackValue(testGlossaryItem);
  });

  setUp(() {
    mockGlossaryRepo = MockGlossaryRepository();
    testDateTime = DateTime.fromMicrosecondsSinceEpoch(1620000000000);
  });

  group('GlossaryEditCubit', () {
    test('initial state is GlossaryEditInitial', () {
      final cubit = GlossaryEditCubit(
        glossaryRepo: mockGlossaryRepo,
        uniqueTime: () async => testDateTime,
      );
      expect(cubit.state, equals(const GlossaryEditInitial()));
      cubit.close();
    });

    test('uses default RandomColorGenerator when colorGenerator is null', () {
      final cubit = GlossaryEditCubit(
        glossaryRepo: mockGlossaryRepo,
        uniqueTime: () async => testDateTime,
      );
      expect(cubit.state, const GlossaryEditInitial());
      unawaited(cubit.close());
    });

    group('requestRandomColors', () {
      const existingColorArgb = 0xFF111111;
      const existingColor = Color(existingColorArgb);
      const duplicateColor = Color(0xFF222222);
      const uniqueColor1 = Color(0xFF333333);
      const uniqueColor2 = Color(0xFF444444);

      blocTest<GlossaryEditCubit, GlossaryEditState>(
        'emits [GlossaryEditColorRequest, GlossaryEditColorList] and skips '
        'colors in colorSet or already in colorList',
        setUp: () {
          when(
            () => mockGlossaryRepo.allColorArgbValues(),
          ).thenAnswer((_) async => {existingColorArgb});
        },
        build: () {
          final generatedSequence = <Color>[
            existingColor,
            duplicateColor,
            duplicateColor,
            uniqueColor1,
            uniqueColor2,
          ];
          var index = 0;

          return GlossaryEditCubit(
            glossaryRepo: mockGlossaryRepo,
            uniqueTime: () async => testDateTime,
            colorGenerator: () => generatedSequence[index++],
          );
        },
        act: (cubit) => cubit.requestRandomColors(count: 2),
        expect: () => [
          const GlossaryEditColorRequest(),
          const GlossaryEditColorList([duplicateColor, uniqueColor1]),
        ],
        verify: (_) {
          verify(() => mockGlossaryRepo.allColorArgbValues()).called(1);
        },
      );
    });

    group('requestNewId', () {
      blocTest<GlossaryEditCubit, GlossaryEditState>(
        'emits GlossaryEditPopover with given color and microseconds timestamp',
        build: () => GlossaryEditCubit(
          glossaryRepo: mockGlossaryRepo,
          uniqueTime: () async => testDateTime,
        ),
        act: (cubit) => cubit.requestNewId(usingColor: 0xFFAABBCC),
        expect: () => [
          GlossaryEditPopover(0xFFAABBCC, testDateTime.microsecondsSinceEpoch),
        ],
      );
    });

    group('editComplete', () {
      blocTest<GlossaryEditCubit, GlossaryEditState>(
        'inserts item, queries itemCount, and emits GlossaryEditInitial when item is not null',
        setUp: () {
          when(
            () => mockGlossaryRepo.insertItem(any()),
          ).thenAnswer((_) async => testGlossaryItem);
          when(() => mockGlossaryRepo.itemCount()).thenAnswer((_) async => 42);
        },
        build: () => GlossaryEditCubit(
          glossaryRepo: mockGlossaryRepo,
          uniqueTime: () async => testDateTime,
        ),
        act: (cubit) => cubit.editComplete(glossaryItem: testGlossaryItem),
        expect: () => [
          const GlossaryEditInitial(),
        ],
        verify: (_) {
          verify(() => mockGlossaryRepo.insertItem(testGlossaryItem)).called(1);
          verify(() => mockGlossaryRepo.itemCount()).called(1);
        },
      );

      blocTest<GlossaryEditCubit, GlossaryEditState>(
        'emits GlossaryEditInitial without calling repo when item is null',
        build: () => GlossaryEditCubit(
          glossaryRepo: mockGlossaryRepo,
          uniqueTime: () async => testDateTime,
        ),
        act: (cubit) => cubit.editComplete(glossaryItem: null),
        expect: () => [
          const GlossaryEditInitial(),
        ],
        verify: (_) {
          verifyNever(() => mockGlossaryRepo.insertItem(any()));
          verifyNever(() => mockGlossaryRepo.itemCount());
        },
      );
    });
  });
}
