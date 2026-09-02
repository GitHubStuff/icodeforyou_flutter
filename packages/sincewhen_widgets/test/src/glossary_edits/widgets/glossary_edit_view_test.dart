// packages/sincewhen_widgets/test/src/glossary_edits/widgets/glossary_edit_view_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:color_grid/color_grid.dart' show ColorGrid;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sincewhen_widgets/sincewhen_widgets.dart'
    show
        GlossaryEditColorList,
        GlossaryEditColorRequest,
        GlossaryEditCubit,
        GlossaryEditInitial,
        GlossaryEditState,
        GlossaryEditView;

class _MockGlossaryEditCubit extends MockCubit<GlossaryEditState>
    implements GlossaryEditCubit {}

void main() {
  late GlossaryEditCubit mockCubit;

  setUp(() {
    mockCubit = _MockGlossaryEditCubit();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<GlossaryEditCubit>.value(
        value: mockCubit,
        child: const GlossaryEditView(),
      ),
    );
  }

  group('GlossaryEditView', () {
    testWidgets(
      'renders Load Color Grid button when state is GlossaryEditInitial and '
      'triggers requestRandomColors on press',
      (tester) async {
        when(() => mockCubit.state).thenReturn(const GlossaryEditInitial());
        when(
          () => mockCubit.requestRandomColors(count: any(named: 'count')),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(buildSubject());

        final buttonFinder = find.widgetWithText(
          ElevatedButton,
          'Load Color Grid',
        );
        expect(buttonFinder, findsOneWidget);

        await tester.tap(buttonFinder);
        await tester.pump();

        verify(() => mockCubit.requestRandomColors(count: 15)).called(1);
      },
    );

    testWidgets(
      'renders CircularProgressIndicator when state is '
      'GlossaryEditColorRequest',
      (tester) async {
        when(
          () => mockCubit.state,
        ).thenReturn(const GlossaryEditColorRequest());

        await tester.pumpWidget(buildSubject());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'renders ColorGrid when state is GlossaryEditColorList and handles '
      'refresh and color tap callbacks',
      (tester) async {
        final colors = List.generate(
          15,
          (index) => Color(0xFF000000 + index * 0x10),
        );
        when(
          () => mockCubit.state,
        ).thenReturn(GlossaryEditColorList(colors));
        when(
          () => mockCubit.requestRandomColors(count: any(named: 'count')),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(buildSubject());

        final colorGridFinder = find.byType(ColorGrid);
        expect(colorGridFinder, findsOneWidget);

        final colorGridWidget = tester.widget<ColorGrid>(colorGridFinder);
        expect(colorGridWidget.colors.length, 15);
        expect(
          colorGridWidget.colors.first,
          colors.first.toARGB32(),
        );

        // Exercise onColorTapped callback
        colorGridWidget.onColorTapped(0, colors.first.toARGB32());

        // Exercise onRefreshRequested callback
        colorGridWidget.onRefreshRequested();
        verify(() => mockCubit.requestRandomColors(count: 15)).called(1);
      },
    );
  });
}
