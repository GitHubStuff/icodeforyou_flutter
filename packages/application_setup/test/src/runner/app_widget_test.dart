// test/src/runner/app_widget_test.dart

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/app/splash_screen.dart';
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

class _StubSplash extends SplashScreenAbstract {
  const _StubSplash({required super.onComplete});

  @override
  Widget build(BuildContext context) => const Text('splash');
}

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

    Widget buildSubject({
      SplashScreenAbstract Function(VoidCallback)? splashBuilder,
    }) =>
        AppWidget(
          themeCubit: themeCubit,
          appCubit: appCubit,
          splashBuilder:
              splashBuilder ?? (onDone) => _StubSplash(onComplete: onDone),
          app: const Text('app'),
          transitionDuration: Duration.zero,
          lightTheme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
        );

    testWidgets('renders splash via splashBuilder', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('splash'), findsOneWidget);
    });

    testWidgets('passes onSplashDone to splashBuilder', (tester) async {
      VoidCallback? captured;
      await tester.pumpWidget(
        buildSubject(
          splashBuilder: (onDone) {
            captured = onDone;
            return _StubSplash(onComplete: onDone);
          },
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
      await tester.pumpWidget(buildSubject());
      await tester.pump();
    });

    testWidgets('uses custom transitionsBuilder when provided', (tester) async {
      var builderCalled = false;
      await tester.pumpWidget(
        AppWidget(
          themeCubit: themeCubit,
          appCubit: appCubit,
          splashBuilder: (onDone) => _StubSplash(onComplete: onDone),
          app: const Text('app'),
          transitionDuration: Duration.zero,
          lightTheme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          transitionsBuilder: (context, animation, secondary, child) {
            builderCalled = true;
            return child;
          },
        ),
      );
      expect(builderCalled, isFalse);
    });
  });
}
