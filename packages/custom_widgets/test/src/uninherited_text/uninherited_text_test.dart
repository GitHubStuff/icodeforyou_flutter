// packages/custom_widgets/test/src/uninherited_text/uninherited_text_test.dart

import 'package:custom_widgets/custom_widgets.dart' show UninheritedText;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UninheritedText', () {
    testWidgets('renders standalone with no inherited ambient widgets',
        (tester) async {
      await tester.pumpWidget(const UninheritedText('Boom'));

      expect(find.text('Boom'), findsOneWidget);

      final directionality = tester.widget<Directionality>(
        find.byType(Directionality).first,
      );
      expect(directionality.textDirection, TextDirection.ltr);

      final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(box.color, Colors.black);

      final style = tester
          .widget<DefaultTextStyle>(find.byType(DefaultTextStyle).last)
          .style;
      expect(style.color, Colors.redAccent);
      expect(style.fontSize, 32);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.decoration, TextDecoration.none);
    });

    testWidgets('honours a custom background and style', (tester) async {
      const style = TextStyle(
        color: Colors.lime,
        fontSize: 12,
        decoration: TextDecoration.none,
      );

      await tester.pumpWidget(
        const UninheritedText(
          'Boom',
          backgroundColor: Colors.indigo,
          style: style,
        ),
      );

      final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(box.color, Colors.indigo);
      expect(
        tester
            .widget<DefaultTextStyle>(find.byType(DefaultTextStyle).last)
            .style,
        style,
      );
    });
  });
}
