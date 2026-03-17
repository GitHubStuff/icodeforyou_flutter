// test/src/runner/app_widget_test.dart

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/runner/_app_widget.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:theme_manager/theme_manager.dart';

class _MockAppCubit extends MockCubit<AppState> implements AppCubit {
  @override
  void onSplashDone() {}
}

class _MockThemeCubit extends MockCubit<ThemeMode> implements ThemeCubit {}

void main() {
  group('AppWidget', () {
    late _MockAppCubit appCubit;
    late _MockThemeCubit themeCubit;

    setUp(() {
      appCubit = _MockAppCubit();
      themeCubit = _MockThemeCubit();
      when(() => appCubit.state).thenReturn(const AppSplashVisible());
      when(() => appCubit.initialize()).thenAnswer((_) async {});
      when(() => themeCubit.state).thenReturn(ThemeMode.system);
    });

    testWidgets('renders splash via splashBuilder', (tester) async {
      await tester.pumpWidget(
        AppWidget(
          themeCubit: themeCubit,
          appCubit: appCubit,
          splashBuilder: (_) => const Text('splash'),
          app: const Text('app'),
          transitionDuration: Duration.zero,
          lightTheme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
        ),
      );
      expect(find.text('splash'), findsOneWidget);
    });

    testWidgets('passes onSplashDone to splashBuilder', (tester) async {
      VoidCallback? captured;
      await tester.pumpWidget(
        AppWidget(
          themeCubit: themeCubit,
          appCubit: appCubit,
          splashBuilder: (onDone) {
            captured = onDone;
            return const Text('splash');
          },
          app: const Text('app'),
          transitionDuration: Duration.zero,
          lightTheme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
        ),
      );
      expect(captured, isNotNull);
    });

    testWidgets('reacts to ThemeMode changes', (tester) async {
      whenListen(
        themeCubit,
        Stream.fromIterable([ThemeMode.dark]),
        initialState: ThemeMode.system,
      );
      await tester.pumpWidget(
        AppWidget(
          themeCubit: themeCubit,
          appCubit: appCubit,
          splashBuilder: (_) => const Text('splash'),
          app: const Text('app'),
          transitionDuration: Duration.zero,
          lightTheme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
        ),
      );
      await tester.pump();
    });
  });
}
