// test/src/app/splash_screen_test.dart

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

    Widget buildSubject(AppState state) {
      when(() => cubit.state).thenReturn(state);
      return MaterialApp(
        home: BlocProvider<AppCubit>.value(
          value: cubit,
          child: const SplashScreen(
            child: Text('splash'),
          ),
        ),
      );
    }

    testWidgets('renders child without spinner on AppSplashVisible',
        (tester) async {
      await tester.pumpWidget(buildSubject(const AppSplashVisible()));
      expect(find.text('splash'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders spinner overlay on AppSplashWaiting', (tester) async {
      await tester.pumpWidget(buildSubject(const AppSplashWaiting()));
      expect(find.text('splash'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders child without spinner on AppTasksComplete',
        (tester) async {
      await tester.pumpWidget(buildSubject(const AppTasksComplete()));
      expect(find.text('splash'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders child without spinner on AppReady', (tester) async {
      await tester.pumpWidget(buildSubject(const AppReady()));
      expect(find.text('splash'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
