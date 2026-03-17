// test/src/app/app_view_test.dart

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/app/app_view.dart';
import 'package:application_setup/src/app/landing_page.dart';
import 'package:application_setup/src/app/splash_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  group('AppView', () {
    late _MockAppCubit cubit;

    setUp(() {
      cubit = _MockAppCubit();
      when(() => cubit.state).thenReturn(const AppSplashVisible());
      when(() => cubit.initialize()).thenAnswer((_) async {});
    });

    Widget buildSubject() => MaterialApp(
      home: BlocProvider<AppCubit>.value(
        value: cubit,
        child: const AppView(
          transitionDuration: Duration.zero,
          splashScreen: SplashScreen(child: Text('splash')),
          landingPage: LandingPage(child: Text('app')),
        ),
      ),
    );

    testWidgets('calls initialize on AppCubit on mount', (tester) async {
      await tester.pumpWidget(buildSubject());
      verify(() => cubit.initialize()).called(1);
    });

    testWidgets('shows splash screen initially', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('splash'), findsOneWidget);
      expect(find.text('app'), findsNothing);
    });

    testWidgets('navigates to landing page when AppReady emitted', (
      tester,
    ) async {
      whenListen(
        cubit,
        Stream.fromIterable([const AppReady()]),
        initialState: const AppSplashVisible(),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('app'), findsOneWidget);
    });

    group('crossFade', () {
      testWidgets('returns FadeTransition', (tester) async {
        late Widget result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // ignore: join_return_with_assignment
                result = AppView.crossFade(
                  context,
                  const AlwaysStoppedAnimation(1),
                  const AlwaysStoppedAnimation(0),
                  const Text('child'),
                );
                return result;
              },
            ),
          ),
        );
        expect(result, isA<FadeTransition>());
      });
    });
  });
}
