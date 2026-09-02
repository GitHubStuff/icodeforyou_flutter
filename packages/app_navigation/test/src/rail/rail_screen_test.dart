// packages/app_navigation/test/src/rail/rail_screen_test.dart
import 'dart:async';

import 'package:app_navigation/app_navigation.dart';
import 'package:custom_widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

enum _MockDestination implements NavigableDestinationAbstract {
  home(
    caption: 'Home',
    iconData: Icons.home,
  ),
  search(
    caption: 'Search',
    iconData: Icons.search,
  ),
  profile(
    caption: 'Profile',
    iconData: Icons.person,
  );

  const _MockDestination({
    required this.caption,
    required this.iconData,
  });

  @override
  final String caption;

  @override
  final IconData iconData;

  @override
  Widget Function() get viewBuilder =>
      () => Text('$name view');
}

void main() {
  late NavigationCubit navigationCubit;

  setUp(() {
    navigationCubit = NavigationCubit();
  });

  tearDown(() {
    unawaited(navigationCubit.close());
  });

  Widget buildSubject({
    List<_MockDestination> values = _MockDestination.values,
    List<_MockDestination> visible = const [
      _MockDestination.home,
      _MockDestination.search,
    ],
    List<_MockDestination> overflowed = const [],
    _MockDestination initial = _MockDestination.home,
    Map<_MockDestination, Size> sizeOverrides = const {},
  }) {
    return MaterialApp(
      home: BlocProvider<NavigationCubit>.value(
        value: navigationCubit,
        child: RailScreen<_MockDestination>(
          values: values,
          visible: visible,
          overflowed: overflowed,
          initial: initial,
          sizeOverrides: sizeOverrides,
        ),
      ),
    );
  }

  group('RailScreen', () {
    testWidgets(
      'renders layout structure and all destination views within SlideIndexedStack',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SafeArea), findsOneWidget);
        expect(find.byType(SlideIndexedStack), findsOneWidget);
        expect(
          find.byType(RailDestinationButtons<_MockDestination>),
          findsOneWidget,
        );

        for (final destination in _MockDestination.values) {
          expect(
            find.text('${destination.name} view', skipOffstage: false),
            findsOneWidget,
          );
        }
      },
    );

    testWidgets(
      'renders rail visibility toggle button with correct icon and tooltip when visible',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        expect(find.byTooltip('Hide rail'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);

        final animatedAlign = tester.widget<AnimatedAlign>(
          find.byType(AnimatedAlign),
        );
        expect(animatedAlign.widthFactor, equals(1));
      },
    );

    testWidgets(
      'toggles rail visibility on chevron tap and updates toggle button state',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        expect(navigationCubit.state.railVisible, isFalse);
        expect(find.byTooltip('Show rail'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);

        final animatedAlign = tester.widget<AnimatedAlign>(
          find.byType(AnimatedAlign),
        );
        expect(animatedAlign.widthFactor, equals(0));
      },
    );

    testWidgets(
      'selects destination matching state and passes correct index to stack',
      (tester) async {
        navigationCubit.select('search');

        await tester.pumpWidget(buildSubject());

        final stack = tester.widget<SlideIndexedStack>(
          find.byType(SlideIndexedStack),
        );
        expect(stack.index, equals(1)); // _MockDestination.search index is 1
      },
    );

    testWidgets(
      'falls back to initial when destinationName in state does not exist in values',
      (tester) async {
        navigationCubit.select('non_existent_destination');

        await tester.pumpWidget(
          buildSubject(
            initial: _MockDestination.profile,
          ),
        );

        final stack = tester.widget<SlideIndexedStack>(
          find.byType(SlideIndexedStack),
        );
        expect(stack.index, equals(2)); // _MockDestination.profile index is 2
      },
    );

    testWidgets(
      'forwards onSelect interaction from buttons to NavigationCubit.select',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            overflowed: const [_MockDestination.profile],
            sizeOverrides: const {
              _MockDestination.home: Size(80, 80),
            },
          ),
        );

        final railButtons = tester
            .widget<RailDestinationButtons<_MockDestination>>(
              find.byType(RailDestinationButtons<_MockDestination>),
            );

        railButtons.onSelect(_MockDestination.search);
        await tester.pump();

        expect(navigationCubit.state.destinationName, equals('search'));
      },
    );
  });
}
