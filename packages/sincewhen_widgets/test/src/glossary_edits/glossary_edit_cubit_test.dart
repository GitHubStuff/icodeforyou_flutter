// packages/sincewhen_widgets/test/src/glossary_edits/glossary_edit_cubit_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sincewhen_drift_framework/sincewhen_drift_framework.dart'
    show GlossaryItemsDaoAbstract;
import 'package:sincewhen_widgets/src/glossary_edits/glossary_edit_cubit.dart'
    show GlossaryEditCubit;
import 'package:sincewhen_widgets/src/glossary_edits/glossary_edit_state.dart'
    show
        GlossaryEditColorList,
        GlossaryEditColorRequest,
        GlossaryEditInitial,
        GlossaryEditState;

// --- Mocks ---
class MockGlossaryItemsDao extends Mock implements GlossaryItemsDaoAbstract {}

// --- Test Constants ---
final List<Color> _testColors = [
  const Color(0xFFF44336), // Red
  const Color(0xFF2196F3), // Blue
  const Color(0xFF4CAF50), // Green
  const Color(0xFFFFEB3B), // Yellow
  const Color(0xFF9C27B0), // Purple
  const Color(0xFFFF9800), // Orange
];

void main() {
  group('GlossaryEditCubit', () {
    late MockGlossaryItemsDao mockDao;
    late int generatorIndex;

    // A fresh generator function for each test to avoid cross-test contamination
    Color testColorGenerator() {
      final result = _testColors[generatorIndex];
      generatorIndex = (generatorIndex + 1) % _testColors.length;
      return result;
    }

    setUp(() {
      mockDao = MockGlossaryItemsDao();
      generatorIndex = 0; // Reset the generator state before every test
    });

    test('initial state is GlossaryEditInitial', () {
      final cubit = GlossaryEditCubit(
        dao: mockDao,
        colorGenerator: testColorGenerator,
      );
      expect(cubit.state, equals(const GlossaryEditInitial()));
    });

    blocTest<GlossaryEditCubit, GlossaryEditState>(
      'emits [GlossaryEditColorRequest, GlossaryEditColorList] with requested count '
      'when no colors exist in the database',
      build: () {
        when(
          () => mockDao.allColorArgbValues(),
        ).thenAnswer((_) async => <int>{});
        return GlossaryEditCubit(
          dao: mockDao,
          colorGenerator: testColorGenerator,
        );
      },
      act: (cubit) => cubit.requestRandomColors(count: 3),
      expect: () => [
        const GlossaryEditColorRequest(),
        GlossaryEditColorList([
          _testColors[0], // Red
          _testColors[1], // Blue
          _testColors[2], // Green
        ]),
      ],
      verify: (_) {
        verify(() => mockDao.allColorArgbValues()).called(1);
      },
    );

    blocTest<GlossaryEditCubit, GlossaryEditState>(
      'skips colors that already exist in the database',
      build: () {
        // Let's pretend Blue (index 1) is already in the DB.
        // NOTE: We assume `.toInt()` matches the integer representation of the color.
        when(() => mockDao.allColorArgbValues()).thenAnswer(
          (_) async => {_testColors[1].toARGB32()},
        );
        return GlossaryEditCubit(
          dao: mockDao,
          colorGenerator: testColorGenerator,
        );
      },
      act: (cubit) => cubit.requestRandomColors(count: 3),
      expect: () => [
        const GlossaryEditColorRequest(),
        GlossaryEditColorList([
          _testColors[0], // Red
          // Blue is skipped because it's in the DB
          _testColors[2], // Green
          _testColors[3], // Yellow
        ]),
      ],
    );

    blocTest<GlossaryEditCubit, GlossaryEditState>(
      'skips duplicate colors returned by the generator in the same batch',
      build: () {
        when(
          () => mockDao.allColorArgbValues(),
        ).thenAnswer((_) async => <int>{});

        // Custom generator that intentionally returns duplicates
        int customIndex = 0;
        final duplicateColors = [
          _testColors[0], // Red
          _testColors[0], // Red (Duplicate)
          _testColors[1], // Blue
        ];

        return GlossaryEditCubit(
          dao: mockDao,
          colorGenerator: () => duplicateColors[customIndex++],
        );
      },
      act: (cubit) => cubit.requestRandomColors(count: 2),
      expect: () => [
        const GlossaryEditColorRequest(),
        GlossaryEditColorList([
          _testColors[0], // Red
          _testColors[1], // Blue
        ]),
      ],
    );
  });
}
