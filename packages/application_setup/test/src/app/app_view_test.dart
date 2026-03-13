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

    setUp(() => cubit = _MockAppCubit());
    tearDown(() => cubit.close());

    testWidgets('displays SplashScreen initially', (tester) async {
      when(() => cubit.state).thenReturn(const AppSplashVisible());
      when(() => cubit.initialize()).thenAnswer((_) async {});
      whenListen(
        cubit,
        const Stream<AppState>.empty(),
        initialState: const AppSplashVisible(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AppCubit>.value(
            value: cubit,
            child: const AppView(
              transitionDuration: Duration.zero,
              splashScreen: SplashScreen(child: Text('splash')),
              landingPage: LandingPage(child: Text('landing')),
            ),
          ),
        ),
      );

      expect(find.text('splash'), findsOneWidget);
      expect(find.text('landing'), findsNothing);
    });

    testWidgets('navigates to LandingPage on AppReady', (tester) async {
      when(() => cubit.state).thenReturn(const AppSplashVisible());
      when(() => cubit.initialize()).thenAnswer((_) async {});
      whenListen(
        cubit,
        Stream.value(const AppReady()),
        initialState: const AppSplashVisible(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AppCubit>.value(
            value: cubit,
            child: const AppView(
              transitionDuration: Duration.zero,
              splashScreen: SplashScreen(child: Text('splash')),
              landingPage: LandingPage(child: Text('landing')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('landing'), findsOneWidget);
    });

    test('crossFade returns FadeTransition', () {
      final animation = AnimationController(
        vsync: const TestVSync(),
        duration: Duration.zero,
      );
      final result = AppView.crossFade(
        _FakeBuildContext(),
        animation,
        animation,
        const Text('child'),
      );
      expect(result, isA<FadeTransition>());
      animation.dispose();
    });
  });
}

class _FakeBuildContext extends Fake implements BuildContext {}
