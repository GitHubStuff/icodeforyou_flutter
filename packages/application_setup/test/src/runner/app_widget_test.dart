// test/src/runner/app_widget_test.dart

import 'dart:async';

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/app/app_view.dart';
import 'package:application_setup/src/runner/_app_widget.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:theme_manager/theme_manager.dart';

class _MockAppCubit extends MockCubit<AppState> implements AppCubit {}
class _MockThemeCubit extends MockCubit<ThemeMode> implements ThemeCubit {}

void main() {
  group('AppWidget', () {
    late _MockAppCubit appCubit;
    late _MockThemeCubit themeCubit;

    setUp(() {
      appCubit = _MockAppCubit();
      themeCubit = _MockThemeCubit();
    });

    tearDown(() {
      unawaited(appCubit.close());
      unawaited(themeCubit.close());
    });

    testWidgets('renders splash child inside MaterialApp', (tester) async {
      when(() => appCubit.state).thenReturn(const AppSplashVisible());
      when(() => appCubit.initialize()).thenAnswer((_) async {});
      whenListen(
        appCubit,
        const Stream<AppState>.empty(),
        initialState: const AppSplashVisible(),
      );
      when(() => themeCubit.state).thenReturn(ThemeMode.dark);
      whenListen(
        themeCubit,
        const Stream<ThemeMode>.empty(),
        initialState: ThemeMode.dark,
      );

      await tester.pumpWidget(
        AppWidget(
          themeCubit: themeCubit,
          appCubit: appCubit,
          splashChild: const Text('splash'),
          landingChild: const Text('landing'),
          transitionDuration: Duration.zero,
          splashDuration: Duration.zero,
          lightTheme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          transitionsBuilder: AppView.crossFade,
        ),
      );

      expect(find.text('splash'), findsOneWidget);
    });

    testWidgets('rebuilds MaterialApp on theme change', (tester) async {
      when(() => appCubit.state).thenReturn(const AppSplashVisible());
      when(() => appCubit.initialize()).thenAnswer((_) async {});
      whenListen(
        appCubit,
        const Stream<AppState>.empty(),
        initialState: const AppSplashVisible(),
      );
      when(() => themeCubit.state).thenReturn(ThemeMode.light);
      whenListen(
        themeCubit,
        Stream.value(ThemeMode.dark),
        initialState: ThemeMode.light,
      );

      await tester.pumpWidget(
        AppWidget(
          themeCubit: themeCubit,
          appCubit: appCubit,
          splashChild: const Text('splash'),
          landingChild: const Text('landing'),
          transitionDuration: Duration.zero,
          splashDuration: Duration.zero,
          lightTheme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          transitionsBuilder: AppView.crossFade,
        ),
      );

      await tester.pump();
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
