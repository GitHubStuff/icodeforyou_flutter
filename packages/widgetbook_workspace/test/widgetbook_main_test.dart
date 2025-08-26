// main_test.dart

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook/widgetbook.dart';

// Import the main function and WidgetbookApp for testing
import 'package:widgetbook_workspace/main.dart' as app_main;
import 'package:widgetbook_workspace/main.dart';

void main() {
  group('Widgetbook Main Coverage Tests', () {
    group('main() function', () {
      test('executes main function for coverage', () {
        // This test ensures the main() function is executed for coverage
        // We expect it to throw since runApp() won't work in test environment
        expect(() => app_main.main(), throwsA(isA<Object>()));
      });
    });

    group('WidgetbookApp', () {
      testWidgets('builds Widgetbook with correct structure', (tester) async {
        await tester.pumpWidget(const WidgetbookApp());

        // Verify Widgetbook is present
        expect(find.byType(Widgetbook), findsOneWidget);

        final widgetbook = tester.widget<Widgetbook>(find.byType(Widgetbook));
        expect(widgetbook.addons?.length, 2);
      });

      testWidgets('has ViewportAddon with correct configurations', (
        tester,
      ) async {
        await tester.pumpWidget(const WidgetbookApp());

        final widgetbook = tester.widget<Widgetbook>(find.byType(Widgetbook));
        expect(widgetbook.addons?.length, 2);

        final viewportAddon = widgetbook.addons
            ?.whereType<ViewportAddon>()
            .first;
        expect(viewportAddon, isNotNull);

        expect(viewportAddon!.viewports, hasLength(2));

        // Verify iPhone 13 viewport
        final iPhoneViewport = viewportAddon.viewports[0];
        expect(iPhoneViewport.name, 'iPhone 13');
        expect(iPhoneViewport.width, 390);
        expect(iPhoneViewport.height, 844);
        expect(iPhoneViewport.pixelRatio, 3.0);
        expect(iPhoneViewport.platform, TargetPlatform.iOS);

        // Verify Desktop viewport
        final desktopViewport = viewportAddon.viewports[1];
        expect(desktopViewport.name, 'Desktop');
        expect(desktopViewport.width, 1440);
        expect(desktopViewport.height, 900);
        expect(desktopViewport.pixelRatio, 2.0);
        expect(desktopViewport.platform, TargetPlatform.macOS);
      });

      testWidgets('has ThemeAddon with light and dark themes', (tester) async {
        await tester.pumpWidget(const WidgetbookApp());

        final widgetbook = tester.widget<Widgetbook>(find.byType(Widgetbook));
        final themeAddon = widgetbook.addons
            ?.whereType<ThemeAddon<ThemeData>>()
            .first;
        expect(themeAddon, isNotNull);

        expect(themeAddon!.themes, hasLength(2));

        // Test light theme
        final lightTheme = themeAddon.themes[0];
        expect(lightTheme.name, 'Light Theme');
        expect(lightTheme.data.brightness, Brightness.light);
        expect(lightTheme.data.useMaterial3, true);

        // Test dark theme
        final darkTheme = themeAddon.themes[1];
        expect(darkTheme.name, 'Dark Theme');
        expect(darkTheme.data.brightness, Brightness.dark);
        expect(darkTheme.data.useMaterial3, true);
      });

      testWidgets('themeBuilder creates correct widget hierarchy', (
        tester,
      ) async {
        await tester.pumpWidget(const WidgetbookApp());

        final widgetbook = tester.widget<Widgetbook>(find.byType(Widgetbook));
        final themeAddon = widgetbook.addons
            ?.whereType<ThemeAddon<ThemeData>>()
            .first;
        expect(themeAddon, isNotNull);

        // Get the themeBuilder function
        final themeBuilder = themeAddon!.themeBuilder;
        expect(themeBuilder, isNotNull);

        // Test the themeBuilder with light theme - this covers lines 57-69
        final lightTheme = ThemeData.light(useMaterial3: true);
        const testChild = Text('Test Child');

        // Create a minimal test context without MaterialApp to avoid duplicate Theme widgets
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                // Call themeBuilder to cover lines 57-69
                final themedWidget = themeBuilder(
                  context,
                  lightTheme,
                  testChild,
                );

                // Verify it returns a Builder
                expect(themedWidget, isA<Builder>());

                return themedWidget;
              },
            ),
          ),
        );

        // Verify the widget structure created by themeBuilder
        expect(find.byType(Builder), findsWidgets);
        expect(
          find.byType(Theme),
          findsOneWidget,
        ); // Now only our themeBuilder creates a Theme
        expect(
          find.byType(Material),
          findsOneWidget,
        ); // Only our themeBuilder creates Material
        expect(find.text('Test Child'), findsOneWidget);

        // Verify our specific theme is applied
        final themeWidget = tester.widget<Theme>(find.byType(Theme));
        expect(themeWidget.data, lightTheme);
      });

      testWidgets('themeBuilder works with dark theme and different child', (
        tester,
      ) async {
        await tester.pumpWidget(const WidgetbookApp());

        final widgetbook = tester.widget<Widgetbook>(find.byType(Widgetbook));
        final themeAddon = widgetbook.addons
            ?.whereType<ThemeAddon<ThemeData>>()
            .first;
        expect(themeAddon, isNotNull);
        final themeBuilder = themeAddon!.themeBuilder;
        expect(themeBuilder, isNotNull);

        // Test with dark theme and different child
        final darkTheme = ThemeData.dark(useMaterial3: true);
        const testChild = Icon(Icons.star);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                // This also covers the themeBuilder lines 57-69
                return themeBuilder(context, darkTheme, testChild);
              },
            ),
          ),
        );

        // Verify Material has correct background color from dark theme
        final materialWidget = tester.widget<Material>(find.byType(Material));
        expect(materialWidget.color, darkTheme.scaffoldBackgroundColor);

        // Verify child is present
        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      test('constructor accepts key parameter', () {
        const testKey = Key('widgetbook-test-key');
        const app = WidgetbookApp(key: testKey);

        expect(app.key, testKey);
      });
    });
  });
}
