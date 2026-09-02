// packages/sincewhen_widgets/test/src/glossary_edits/widgets/glossary_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_models/sincewhen_models.dart';
import 'package:sincewhen_widgets/src/glossary_edits/widgets/glossary_card.dart';

void main() {
  const testItem = GlossaryItem(
    id: 1,
    createdTimestamp: 1000,
    tag: 'Important',
    colorArgb: 0xFFFF0000,
    descr: 'High priority tasks',
  );

  Widget buildSubject({
    GlossaryItem item = testItem,
    VoidCallback? onTap,
    double? colorBoxSize,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: GlossaryCard(
          item: item,
          onTap: onTap,
          colorBoxSize: colorBoxSize ?? 48,
          margin:
              margin ??
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
          padding: padding ?? const EdgeInsets.all(16),
        ),
      ),
    );
  }

  group('GlossaryCard', () {
    testWidgets('renders tag, description, and custom parameters', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          colorBoxSize: 64,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(20),
        ),
      );

      expect(find.text('Important'), findsOneWidget);
      expect(find.text('High priority tasks'), findsOneWidget);

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.all(10));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GlossaryCard),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.minWidth, 64);
      expect(container.constraints?.minHeight, 64);

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFFF0000));
    });

    testWidgets('uses default constructor parameter values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlossaryCard(item: testItem),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(
        card.margin,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GlossaryCard),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.minWidth, 48);
      expect(container.constraints?.minHeight, 48);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildSubject(
          onTap: () {
            tapped = true;
          },
        ),
      );

      await tester.tap(find.byType(GlossaryCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders when bodyMedium color is null in theme', (
      tester,
    ) async {
      final customTheme = ThemeData(
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: null),
        ),
      );

      await tester.pumpWidget(
        buildSubject(
          theme: customTheme,
        ),
      );

      expect(find.text('High priority tasks'), findsOneWidget);
    });
  });
}
