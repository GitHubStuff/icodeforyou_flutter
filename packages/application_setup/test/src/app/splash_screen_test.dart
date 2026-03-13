// test/src/app/splash_screen_test.dart

// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/app/splash_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  group('SplashScreen', () {
    late _MockAppCubit cubit;

    setUp(() => cubit = _MockAppCubit());
    tearDown(() => cubit.close());

    Widget buildSubject(AppState state) {
      when(() => cubit.state).thenReturn(state);
      whenListen(cubit, Stream.value(state), initialState: state);
      return MaterialApp(
        home: BlocProvider<AppCubit>.value(
          value: cubit,
          child: const SplashScreen(
            child: Text('splash content'),
          ),
        ),
      );
    }

    testWidgets('renders child when AppSplashVisible', (tester) async {
      await tester.pumpWidget(buildSubject(const AppSplashVisible()));
      await tester.pump();
      expect(find.text('splash content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders spinner overlay when AppSplashWaiting', (tester) async {
      await tester.pumpWidget(buildSubject(const AppSplashWaiting()));
      await tester.pump();
      expect(find.text('splash content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not rebuild on AppReady', (tester) async {
      when(() => cubit.state).thenReturn(const AppSplashVisible());
      whenListen(
        cubit,
        Stream.fromIterable([
          const AppSplashVisible(),
          const AppReady(),
        ]),
        initialState: const AppSplashVisible(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AppCubit>.value(
            value: cubit,
            child: const SplashScreen(child: Text('splash content')),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
