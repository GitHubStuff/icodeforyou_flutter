// packages/sincewhen_screens/test/src/sincewhen_mini/sincewhen_mini_test.dart

import 'package:extensions/datetime/src/datetime_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_models/sincewhen_models.dart';
import 'package:sincewhen_screens/src/cubit/cubit.dart';
import 'package:sincewhen_screens/src/cubit/state.dart';
import 'package:sincewhen_screens/src/sincewhen_mini/sincewhen_mini.dart';
import 'package:sincewhen_screens/src/widgets/since_when_mini_action_bar.dart';
import 'package:sincewhen_screens/src/widgets/since_when_mini_text_column.dart';
import 'package:sincewhen_screens/src/widgets/sincewhen_mini_timestamp_column.dart';

class _TestBlocObserver extends BlocObserver {
  BlocBase<dynamic>? lastCreatedBloc;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    lastCreatedBloc = bloc;
  }
}

void main() {
  late DateTime fixedNow;
  late _TestBlocObserver observer;

  setUp(() {
    DateTimeExt.reset();
    fixedNow = DateTime.utc(2026, 1, 1, 12, 0, 0);
    observer = _TestBlocObserver();
    Bloc.observer = observer;
  });

  SinceWhenItem createTestItem({
    int id = 1,
    int created = 1000,
    int reviewed = 2000,
    int edited = 3000,
    int sequenceNumber = 0,
    String content = 'Test Content',
    String? metaData = 'Test Metadata',
    String? tldr = 'Test TLDR',
    int? eventTimestamp = 4000,
  }) {
    return SinceWhenItem(
      id: id,
      createdTimestamp: created,
      reviewedTimestamp: reviewed,
      editedTimestamp: edited,
      sequenceNumber: sequenceNumber,
      content: content,
      metaData: metaData,
      tldr: tldr,
      eventTimestamp: eventTimestamp,
    );
  }

  Widget buildSubject({
    required Widget child,
    NavigatorObserver? navigatorObserver,
  }) {
    return MaterialApp(
      navigatorObservers: [
        if (navigatorObserver != null) navigatorObserver,
      ],
      home: child,
    );
  }

  group('SinceWhenMini Route & Construction', () {
    testWidgets('route builder instantiates SinceWhenMini with provided item', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1133, 744));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final testItem = createTestItem();
      final route = SinceWhenMini.route(item: testItem);

      expect(route, isA<MaterialPageRoute<SinceWhenItem?>>());

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => route,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SinceWhenMini), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('renders in create mode using default now clock', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1133, 744));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildSubject(
          child: const SinceWhenMini(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SinceWhenMini), findsOneWidget);
      expect(find.byType(SinceWhenMiniActionBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SinceWhenMiniActionBar),
          matching: find.text('Submit'),
        ),
        findsOneWidget,
      );
    });
  });

  group('SinceWhenMini Loading & Transition', () {
    testWidgets(
      'renders CircularProgressIndicator when state is kept in SinceWhenMiniLoading',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1133, 744));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildSubject(
            child: SinceWhenMini(
              item: null,
              now: () {
                observer.lastCreatedBloc?.close();
                return fixedNow;
              },
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(SinceWhenMiniActionBar), findsNothing);
      },
    );

    testWidgets(
      'grants initial focus on content field when starting in edit mode (Ready)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1133, 744));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final testItem = createTestItem();

        await tester.pumpWidget(
          buildSubject(
            child: SinceWhenMini(
              item: testItem,
              now: () => fixedNow,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SinceWhenMiniTextColumn), findsOneWidget);

        final editable = tester.widget<EditableText>(
          find.descendant(
            of: find.byType(SinceWhenMiniTextColumn),
            matching: find.byType(EditableText).first,
          ),
        );
        expect(editable.focusNode.hasFocus, isTrue);
      },
    );

    testWidgets(
      'grants focus on content field in create mode upon Loading -> Ready transition',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1133, 744));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildSubject(
            child: SinceWhenMini(
              item: null,
              now: () => fixedNow,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final editable = tester.widget<EditableText>(
          find.descendant(
            of: find.byType(SinceWhenMiniTextColumn),
            matching: find.byType(EditableText).first,
          ),
        );
        expect(editable.focusNode.hasFocus, isTrue);
      },
    );
  });

  group('_ReadyBody Layout & Cubit Forwarding', () {
    testWidgets(
      'forwards timestamp and text column callbacks to cubit and sets initial field text',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1133, 744));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final testItem = createTestItem(
          content: 'Original Content',
          metaData: 'Original Meta',
          tldr: 'Original TLDR',
          eventTimestamp: 4000,
        );

        await tester.pumpWidget(
          buildSubject(
            child: SinceWhenMini(
              item: testItem,
              now: () => fixedNow,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Original Content'), findsOneWidget);
        expect(find.text('Original Meta'), findsOneWidget);
        expect(find.text('Original TLDR'), findsOneWidget);

        expect(find.byType(SinceWhenMiniTimestampColumn), findsOneWidget);
        expect(find.byType(SinceWhenMiniTextColumn), findsOneWidget);
        expect(find.byType(SinceWhenMiniActionBar), findsOneWidget);

        final cubit = tester
            .element(find.byType(SinceWhenMiniActionBar))
            .read<SinceWhenMiniCubit>();

        final timestampColumn = tester.widget<SinceWhenMiniTimestampColumn>(
          find.byType(SinceWhenMiniTimestampColumn),
        );
        final newDate = DateTime.utc(2026, 7, 20);
        timestampColumn.onEventSelected(newDate);
        await tester.pump();
        expect(
          (cubit.state as SinceWhenMiniReady).eventTimestamp,
          equals(newDate.microsecondsSinceEpoch),
        );

        timestampColumn.onEventCleared();
        await tester.pump();
        expect((cubit.state as SinceWhenMiniReady).eventTimestamp, isNull);

        final textColumn = tester.widget<SinceWhenMiniTextColumn>(
          find.byType(SinceWhenMiniTextColumn),
        );
        textColumn.onContentChanged('Edited content');
        await tester.pump();
        expect(
          (cubit.state as SinceWhenMiniReady).content,
          equals('Edited content'),
        );

        textColumn.onTldrChanged('Edited tldr');
        await tester.pump();
        expect((cubit.state as SinceWhenMiniReady).tldr, equals('Edited tldr'));

        textColumn.onMetaDataChanged('Edited meta');
        await tester.pump();
        expect(
          (cubit.state as SinceWhenMiniReady).metaData,
          equals('Edited meta'),
        );
      },
    );

    testWidgets('handles item with null metaData and null tldr in edit mode', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1133, 744));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final testItem = createTestItem(metaData: null, tldr: null);

      await tester.pumpWidget(
        buildSubject(
          child: SinceWhenMini(
            item: testItem,
            now: () => fixedNow,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testItem.content), findsOneWidget);

      final cubit = tester
          .element(find.byType(SinceWhenMiniActionBar))
          .read<SinceWhenMiniCubit>();
      final ready = cubit.state as SinceWhenMiniReady;
      expect(ready.metaData, isEmpty);
      expect(ready.tldr, isEmpty);
    });
  });

  group('Navigation & Pops', () {
    testWidgets(
      'primary button press calls cubit.complete() and pops with result',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1133, 744));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final testItem = createTestItem(content: 'Final Item');
        SinceWhenItem? poppedResult;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    poppedResult = await Navigator.push<SinceWhenItem?>(
                      context,
                      SinceWhenMini.route(item: testItem),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(SinceWhenMini), findsOneWidget);

        final reviewedButton = find.descendant(
          of: find.byType(SinceWhenMiniActionBar),
          matching: find.text('Reviewed'),
        );
        expect(reviewedButton, findsOneWidget);
        await tester.tap(reviewedButton);
        await tester.pumpAndSettle();

        expect(find.byType(SinceWhenMini), findsNothing);
        expect(poppedResult, isNotNull);
        expect(poppedResult!.content, equals('Final Item'));
        expect(poppedResult!.id, equals(testItem.id));
      },
    );

    testWidgets('cancel button press pops route with null', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1133, 744));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final testItem = createTestItem();
      SinceWhenItem? poppedResult;
      var didPop = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  poppedResult = await Navigator.push<SinceWhenItem?>(
                    context,
                    SinceWhenMini.route(item: testItem),
                  );
                  didPop = true;
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(SinceWhenMini), findsOneWidget);

      final cancelButton = find.descendant(
        of: find.byType(SinceWhenMiniActionBar),
        matching: find.text('Cancel'),
      );
      expect(cancelButton, findsOneWidget);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      expect(find.byType(SinceWhenMini), findsNothing);
      expect(didPop, isTrue);
      expect(poppedResult, isNull);
    });
  });
}
