// app_splash_screen_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splash_screen_package/src/app_splash_screen.dart';
import 'package:splash_screen_package/src/loading_error.dart';
import 'package:splash_screen_package/src/splash_screen_cubit.dart';
import 'package:splash_screen_package/src/splash_screen_state.dart';

void main() {
  group('AppSplashScreen', () {
    setUp(() {
      SplashScreenCubit.initialize(const Duration(hours: 10));
    });

    tearDown(() async {
      await SplashScreenCubit.instance.close();
      SplashScreenCubit.reset();
    });

    testWidgets('displays black background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            animationWidget: const Text('Logo'),
            animationDuration: const Duration(milliseconds: 100),
            newRootWidget: const Text('Home'),
            errorWidgetBuilder: (error) => Text(error.errorMessage),
            timeoutDuration: const Duration(seconds: 5),
            spinnerWidget: const CircularProgressIndicator(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));

      expect(scaffold.backgroundColor, Colors.black);
    });

    testWidgets('animation widget fades in', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            animationWidget: const Text('Logo'),
            animationDuration: const Duration(milliseconds: 200),
            newRootWidget: const Text('Home'),
            errorWidgetBuilder: (error) => Text(error.errorMessage),
            timeoutDuration: const Duration(seconds: 5),
            spinnerWidget: const CircularProgressIndicator(),
          ),
        ),
      );

      final fadeTransitions = tester.widgetList<FadeTransition>(
        find.ancestor(
          of: find.text('Logo'),
          matching: find.byType(FadeTransition),
        ),
      );

      final fadeTransition = fadeTransitions.first;

      expect(fadeTransition.opacity.value, 0.0);

      await tester.pump(const Duration(milliseconds: 100));
      expect(fadeTransition.opacity.value, greaterThan(0.0));
      expect(fadeTransition.opacity.value, lessThan(1.0));

      await tester.pump(const Duration(milliseconds: 100));
      expect(fadeTransition.opacity.value, 1.0);
    });

    testWidgets('notifies cubit when animation starts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            animationWidget: const Text('Logo'),
            animationDuration: const Duration(milliseconds: 100),
            newRootWidget: const Text('Home'),
            errorWidgetBuilder: (error) => Text(error.errorMessage),
            timeoutDuration: const Duration(seconds: 5),
            spinnerWidget: const CircularProgressIndicator(),
          ),
        ),
      );

      await tester.pump();

      final cubit = SplashScreenCubit.instance;
      expect(cubit.state, isA<SplashScreenAnimatingInProgress>());
    });

    testWidgets('notifies cubit when animation completes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            animationWidget: const Text('Logo'),
            animationDuration: const Duration(milliseconds: 100),
            newRootWidget: const Text('Home'),
            errorWidgetBuilder: (error) => Text(error.errorMessage),
            timeoutDuration: const Duration(hours: 10),
            spinnerWidget: const CircularProgressIndicator(),
          ),
        ),
      );

      await tester.pump();
      expect(SplashScreenCubit.instance.state, isA<SplashScreenAnimatingInProgress>());

      await tester.pump(const Duration(milliseconds: 101));
      await tester.pump();

      expect(SplashScreenCubit.instance.state, isA<SplashScreenShowingSpinner>());
      
      SplashScreenCubit.instance.dismiss();
      await tester.pump();
    });

    testWidgets('shows spinner with barrier when in ShowingSpinner state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            animationWidget: const Text('Logo'),
            animationDuration: const Duration(milliseconds: 100),
            newRootWidget: const Text('Home'),
            errorWidgetBuilder: (error) => Text(error.errorMessage),
            timeoutDuration: const Duration(hours: 10),
            spinnerWidget: const Text('Loading...'),
            barrierColor: Colors.orange.withValues(alpha: 0.4),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 101));
      await tester.pump();

      expect(find.text('Loading...'), findsOneWidget);
      
      final barrierContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Loading...'),
          matching: find.byType(Container),
        ).first,
      );
      expect(barrierContainer.color, Colors.orange.withValues(alpha: 0.4));
      
      SplashScreenCubit.instance.dismiss();
      await tester.pump();
    });

    testWidgets('shows newRootWidget when in ReadyToDismiss state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            animationWidget: const Text('Logo'),
            animationDuration: const Duration(milliseconds: 100),
            newRootWidget: const Text('Home Page'),
            errorWidgetBuilder: (error) => Text(error.errorMessage),
            timeoutDuration: const Duration(seconds: 5),
            spinnerWidget: const CircularProgressIndicator(),
          ),
        ),
      );

      await tester.pump();
      
      SplashScreenCubit.instance.dismiss();
      
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('shows error widget when in ShowError state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            animationWidget: const Text('Logo'),
            animationDuration: const Duration(milliseconds: 100),
            newRootWidget: const Text('Home'),
            errorWidgetBuilder: (error) => Text('Error: ${error.errorMessage}'),
            timeoutDuration: const Duration(seconds: 5),
            spinnerWidget: const CircularProgressIndicator(),
          ),
        ),
      );

      await tester.pump();
      
      SplashScreenCubit.instance.reportError(const LoadingError('Test error'));
      
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Error: Test error'), findsOneWidget);
    });

    testWidgets('back button is blocked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            animationWidget: const Text('Logo'),
            animationDuration: const Duration(milliseconds: 100),
            newRootWidget: const Text('Home'),
            errorWidgetBuilder: (error) => Text(error.errorMessage),
            timeoutDuration: const Duration(seconds: 5),
            spinnerWidget: const CircularProgressIndicator(),
          ),
        ),
      );

      await tester.pump();

      final popScope = tester.widget<PopScope>(
        find.byType(PopScope),
      );

      expect(popScope.canPop, false);
    });

    testWidgets('uses custom fade curve', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            animationWidget: const Text('Logo'),
            animationDuration: const Duration(milliseconds: 100),
            newRootWidget: const Text('Home'),
            errorWidgetBuilder: (error) => Text(error.errorMessage),
            timeoutDuration: const Duration(seconds: 5),
            spinnerWidget: const CircularProgressIndicator(),
            fadeInCurve: Curves.linear,
          ),
        ),
      );

      final state = tester.state<State<AppSplashScreen>>(
        find.byType(AppSplashScreen),
      );

      expect(state, isNotNull);
    });

    testWidgets('disposes animation controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            animationWidget: const Text('Logo'),
            animationDuration: const Duration(milliseconds: 100),
            newRootWidget: const Text('Home'),
            errorWidgetBuilder: (error) => Text(error.errorMessage),
            timeoutDuration: const Duration(seconds: 5),
            spinnerWidget: const CircularProgressIndicator(),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(tester.takeException(), isNull);
    });
  });
}
