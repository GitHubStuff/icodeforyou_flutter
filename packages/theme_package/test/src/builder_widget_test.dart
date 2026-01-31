// test/src/builder_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_package/theme_package.dart';

void main() {
  const validDbName = 'test_db_1234567890ab';

  setUp(() {
    ThemePackage.reset();
  });

  group('ThemeBuilder', () {
    Future<void> pumpThemeBuilder(
      WidgetTester tester, {
      required Widget Function(BuildContext, ThemeMode) builder,
    }) async {
      await tester.pumpWidget(
        ThemePackageRoot(
          databaseName: validDbName,
          inMemory: true,
          splash: const SizedBox.shrink(),
          child: MaterialApp(
            home: Scaffold(
              body: ThemeBuilder(builder: builder),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    group('builder function', () {
      testWidgets('receives BuildContext', (WidgetTester tester) async {
        BuildContext? capturedContext;

        await pumpThemeBuilder(
          tester,
          builder: (context, themeMode) {
            capturedContext = context;
            return const Text('Test');
          },
        );

        expect(capturedContext, isNotNull);
        expect(capturedContext, isA<BuildContext>());
      });

      testWidgets('receives current ThemeMode', (WidgetTester tester) async {
        ThemeMode? capturedMode;

        await pumpThemeBuilder(
          tester,
          builder: (context, themeMode) {
            capturedMode = themeMode;
            return Text('Mode: ${themeMode.name}');
          },
        );

        expect(capturedMode, ThemeMode.system);
        expect(find.text('Mode: system'), findsOneWidget);
      });

      testWidgets('returns widget from builder', (WidgetTester tester) async {
        await pumpThemeBuilder(
          tester,
          builder: (context, themeMode) {
            return const Text('Custom Widget');
          },
        );

        expect(find.text('Custom Widget'), findsOneWidget);
      });
    });

    group('reactivity', () {
      testWidgets('rebuilds when theme changes to dark',
          (WidgetTester tester) async {
        await pumpThemeBuilder(
          tester,
          builder: (context, themeMode) {
            return Text('Theme: ${themeMode.name}');
          },
        );

        expect(find.text('Theme: system'), findsOneWidget);

        await ThemePackage.setTheme(ThemeMode.dark);
        await tester.pumpAndSettle();

        expect(find.text('Theme: dark'), findsOneWidget);
      });

      testWidgets('rebuilds when theme changes to light',
          (WidgetTester tester) async {
        await pumpThemeBuilder(
          tester,
          builder: (context, themeMode) {
            return Text('Theme: ${themeMode.name}');
          },
        );

        await ThemePackage.setTheme(ThemeMode.light);
        await tester.pumpAndSettle();

        expect(find.text('Theme: light'), findsOneWidget);
      });

      testWidgets('rebuilds on every theme change',
          (WidgetTester tester) async {
        int buildCount = 0;

        await pumpThemeBuilder(
          tester,
          builder: (context, themeMode) {
            buildCount++;
            return Text('Theme: ${themeMode.name}');
          },
        );

        final initialBuildCount = buildCount;

        await ThemePackage.setTheme(ThemeMode.dark);
        await tester.pumpAndSettle();

        await ThemePackage.setTheme(ThemeMode.light);
        await tester.pumpAndSettle();

        await ThemePackage.setTheme(ThemeMode.system);
        await tester.pumpAndSettle();

        // Should have rebuilt at least 3 more times
        expect(buildCount, greaterThan(initialBuildCount));
      });
    });

    group('MaterialApp integration', () {
      testWidgets('can be used to configure MaterialApp themeMode',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ThemePackageRoot(
            databaseName: validDbName,
            inMemory: true,
            splash: const SizedBox.shrink(),
            child: ThemeBuilder(
              builder: (context, themeMode) {
                return MaterialApp(
                  theme: ThemeData.light(useMaterial3: true),
                  darkTheme: ThemeData.dark(useMaterial3: true),
                  themeMode: themeMode,
                  home: Builder(
                    builder: (context) {
                      final brightness = Theme.of(context).brightness;
                      return Text('Brightness: ${brightness.name}');
                    },
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Default system theme - brightness depends on platform
        expect(find.byType(MaterialApp), findsOneWidget);

        // Change to dark
        await ThemePackage.setTheme(ThemeMode.dark);
        await tester.pumpAndSettle();

        expect(find.text('Brightness: dark'), findsOneWidget);

        // Change to light
        await ThemePackage.setTheme(ThemeMode.light);
        await tester.pumpAndSettle();

        expect(find.text('Brightness: light'), findsOneWidget);
      });
    });

    group('nested usage', () {
      testWidgets('multiple ThemeBuilders receive same themeMode',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ThemePackageRoot(
            databaseName: validDbName,
            inMemory: true,
            splash: const SizedBox.shrink(),
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ThemeBuilder(
                      builder: (context, themeMode) {
                        return Text('Builder1: ${themeMode.name}');
                      },
                    ),
                    ThemeBuilder(
                      builder: (context, themeMode) {
                        return Text('Builder2: ${themeMode.name}');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Builder1: system'), findsOneWidget);
        expect(find.text('Builder2: system'), findsOneWidget);

        await ThemePackage.setTheme(ThemeMode.dark);
        await tester.pumpAndSettle();

        expect(find.text('Builder1: dark'), findsOneWidget);
        expect(find.text('Builder2: dark'), findsOneWidget);
      });
    });
  });
}
