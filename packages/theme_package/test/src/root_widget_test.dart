// test/src/root_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:theme_package/theme_package.dart';

void main() {
  const validDbName = 'test_db_1234567890ab';

  setUp(ThemePackage.reset);

  group('ThemePackageRoot', () {
    group('initialization', () {
      testWidgets('initializes and shows child after splash', (
        tester,
      ) async {
        await tester.pumpWidget(
          const ThemePackageRoot(
            databaseName: validDbName,
            inMemory: true,
            splash: Text('Splash'),
            child: MaterialApp(home: Scaffold(body: Text('App Content'))),
          ),
        );

        // Initially shows splash
        expect(find.text('Splash'), findsOneWidget);
        expect(find.text('App Content'), findsNothing);

        // Wait for initialization
        await tester.pumpAndSettle();

        // Shows app content after initialization
        expect(find.text('Splash'), findsNothing);
        expect(find.text('App Content'), findsOneWidget);
      });

      testWidgets(
        'uses pre-initialized ThemePackage when already initialized',
        (tester) async {
          // Pre-initialize
          await ThemePackage.initialize(
            databaseName: validDbName,
            inMemory: true,
          );
          await ThemePackage.setTheme(ThemeMode.dark);

          await tester.pumpWidget(
            ThemePackageRoot(
              splash: const Text('Splash'),
              child: ThemeBuilder(
                builder: (context, themeMode) {
                  return MaterialApp(
                    home: Scaffold(body: Text('Theme: ${themeMode.name}')),
                  );
                },
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Should use the pre-set dark theme
          expect(find.text('Theme: dark'), findsOneWidget);
        },
      );

      testWidgets(
        'throws StateError when databaseName is null and not pre-initialized',
        (tester) async {
          // Build widget - error is caught by Flutter's error handling
          await tester.pumpWidget(
            const ThemePackageRoot(
              // databaseName is null
              splash: Text('Splash'),
              child: MaterialApp(home: Scaffold(body: Text('App'))),
            ),
          );

          // Retrieve the error that was caught during widget building
          final error = tester.takeException();
          expect(error, isA<StateError>());
        },
      );
    });

    group('splash screen', () {
      testWidgets('displays splash with black background', (
        tester,
      ) async {
        await tester.pumpWidget(
          const ThemePackageRoot(
            databaseName: validDbName,
            inMemory: true,
            splash: Text('Loading...'),
            child: MaterialApp(home: Scaffold(body: Text('App'))),
          ),
        );

        // Find the ColoredBox with black background
        final coloredBoxFinder = find.byWidgetPredicate(
          (widget) => widget is ColoredBox && widget.color == Colors.black,
        );
        expect(coloredBoxFinder, findsOneWidget);
      });

      testWidgets('respects splashMinDuration', (tester) async {
        await tester.pumpWidget(
          const ThemePackageRoot(
            databaseName: validDbName,
            inMemory: true,
            splashMinDuration: Duration(seconds: 2),
            splash: Text('Splash'),
            child: MaterialApp(home: Scaffold(body: Text('App'))),
          ),
        );

        // Pump a short duration - splash should still show
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Splash'), findsOneWidget);
        expect(find.text('App'), findsNothing);

        // Pump past min duration
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(find.text('Splash'), findsNothing);
        expect(find.text('App'), findsOneWidget);
      });

      testWidgets('shows app immediately when no splashMinDuration', (
        tester,
      ) async {
        await tester.pumpWidget(
          const ThemePackageRoot(
            databaseName: validDbName,
            inMemory: true,
            splash: Text('Splash'),
            child: MaterialApp(home: Scaffold(body: Text('App'))),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Splash'), findsNothing);
        expect(find.text('App'), findsOneWidget);
      });
    });

    group('transition', () {
      testWidgets('uses default transition duration of 750ms', (
        tester,
      ) async {
        await tester.pumpWidget(
          const ThemePackageRoot(
            databaseName: validDbName,
            inMemory: true,
            splash: Text('Splash'),
            child: MaterialApp(home: Scaffold(body: Text('App'))),
          ),
        );

        // Wait for initialization
        await tester.pump();

        // Find AnimatedSwitcher and verify duration
        final animatedSwitcher = tester.widget<AnimatedSwitcher>(
          find.byType(AnimatedSwitcher),
        );
        expect(animatedSwitcher.duration, const Duration(milliseconds: 750));
      });

      testWidgets('respects custom transitionDuration', (
        tester,
      ) async {
        await tester.pumpWidget(
          const ThemePackageRoot(
            databaseName: validDbName,
            inMemory: true,
            transitionDuration: Duration(milliseconds: 500),
            splash: Text('Splash'),
            child: MaterialApp(home: Scaffold(body: Text('App'))),
          ),
        );

        await tester.pump();

        final animatedSwitcher = tester.widget<AnimatedSwitcher>(
          find.byType(AnimatedSwitcher),
        );
        expect(animatedSwitcher.duration, const Duration(milliseconds: 500));
      });
    });

    group('error handling', () {
      testWidgets(
        'calls onInitializationError callback on initialization failure',
        (tester) async {
          ThemeError? capturedError;

          // Force initialization to fail
          ThemePackage.testDatasourceInitializer = () async {
            return const Left(
              ThemeError.initializationFailed('Simulated failure'),
            );
          };

          await tester.pumpWidget(
            ThemePackageRoot(
              databaseName: validDbName,
              inMemory: true,
              onInitializationError: (error) {
                capturedError = error;
              },
              splash: const Text('Splash'),
              child: const MaterialApp(home: Scaffold(body: Text('App'))),
            ),
          );

          await tester.pumpAndSettle();

          expect(capturedError, isNotNull);
          expect(capturedError.toString(), contains('Simulated failure'));

          // Should still show splash since initialization failed
          expect(find.text('Splash'), findsOneWidget);
          expect(find.text('App'), findsNothing);
        },
      );
    });

    group('BlocProvider', () {
      testWidgets('provides ThemeCubit to child widgets', (
        tester,
      ) async {
        await tester.pumpWidget(
          const ThemePackageRoot(
            databaseName: validDbName,
            inMemory: true,
            splash: Text('Splash'),
            child: _TestChildWidget(),
          ),
        );

        await tester.pumpAndSettle();

        // ThemeBuilder should work (which uses BlocBuilder internally)
        expect(find.text('ThemeMode: system'), findsOneWidget);
      });
    });
  });
}

class _TestChildWidget extends StatelessWidget {
  const _TestChildWidget();

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, themeMode) {
        return MaterialApp(
          home: Scaffold(body: Text('ThemeMode: ${themeMode.name}')),
        );
      },
    );
  }
}
