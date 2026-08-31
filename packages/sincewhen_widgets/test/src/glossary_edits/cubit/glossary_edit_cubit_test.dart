// packages/sincewhen_widgets/test/src/glossary_edits/cubit/glossary_edit_cubit_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:extensions/extensions.dart' show ColorExt;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sincewhen_models/sincewhen_models.dart' show GlossaryRepository;
import 'package:sincewhen_widgets/src/glossary_edits/cubit/glossary_edit_cubit.dart'
    show GlossaryEditCubit;
import 'package:sincewhen_widgets/src/glossary_edits/cubit/glossary_edit_state.dart'
    show
        GlossaryEditColorList,
        GlossaryEditColorRequest,
        GlossaryEditInitial,
        GlossaryEditState;

// --- Mocks ---
class MockGlossaryRepository extends Mock implements GlossaryRepository {}

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
    late MockGlossaryRepository mockRepo;
    late int generatorIndex;

    Color testColorGenerator() {
      final result = _testColors[generatorIndex];
      generatorIndex = (generatorIndex + 1) % _testColors.length;
      return result;
    }

    setUp(() {
      mockRepo = MockGlossaryRepository();
      generatorIndex = 0;
    });

    test('initial state is GlossaryEditInitial', () {
      final cubit = GlossaryEditCubit(
        glossaryRepo: mockRepo,
        colorGenerator: testColorGenerator,
      );
      expect(cubit.state, equals(const GlossaryEditInitial()));
    });

    test('uses default colorGenerator when none is provided', () {
      final cubit = GlossaryEditCubit(glossaryRepo: mockRepo);
      expect(cubit.state, equals(const GlossaryEditInitial()));
    });

    blocTest<GlossaryEditCubit, GlossaryEditState>(
      'emits [GlossaryEditColorRequest, GlossaryEditColorList] with requested '
      'count when no colors exist in repository',
      build: () {
        when(
          () => mockRepo.allColorArgbValues(),
        ).thenAnswer((_) async => <int>{});
        return GlossaryEditCubit(
          glossaryRepo: mockRepo,
          colorGenerator: testColorGenerator,
        );
      },
      act: (cubit) => cubit.requestRandomColors(count: 3),
      expect: () => [
        const GlossaryEditColorRequest(),
        GlossaryEditColorList([
          _testColors[0],
          _testColors[1],
          _testColors[2],
        ]),
      ],
      verify: (_) {
        verify(() => mockRepo.allColorArgbValues()).called(1);
      },
    );

    blocTest<GlossaryEditCubit, GlossaryEditState>(
      'skips colors that already exist in the repository',
      build: () {
        when(() => mockRepo.allColorArgbValues()).thenAnswer(
          (_) async => {_testColors[1].toInt()},
        );
        return GlossaryEditCubit(
          glossaryRepo: mockRepo,
          colorGenerator: testColorGenerator,
        );
      },
      act: (cubit) => cubit.requestRandomColors(count: 3),
      expect: () => [
        const GlossaryEditColorRequest(),
        GlossaryEditColorList([
          _testColors[0],
          _testColors[2],
          _testColors[3],
        ]),
      ],
    );

    blocTest<GlossaryEditCubit, GlossaryEditState>(
      'skips duplicate colors returned in the same batch',
      build: () {
        when(
          () => mockRepo.allColorArgbValues(),
        ).thenAnswer((_) async => <int>{});

        int customIndex = 0;
        final duplicateColors = [
          _testColors[0],
          _testColors[0],
          _testColors[1],
        ];

        return GlossaryEditCubit(
          glossaryRepo: mockRepo,
          colorGenerator: () => duplicateColors[customIndex++],
        );
      },
      act: (cubit) => cubit.requestRandomColors(count: 2),
      expect: () => [
        const GlossaryEditColorRequest(),
        GlossaryEditColorList([
          _testColors[0],
          _testColors[1],
        ]),
      ],
    );
  });
}
