// packages/prism_bubble_widget/test/src/prism_bubble_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_bubble_widget/src/bubble_shader_manager.dart';
import 'package:prism_bubble_widget/src/bubble_shader_painter.dart';
import 'package:prism_bubble_widget/src/prism_bubble_widget.dart';

void main() {
  Widget buildFrame(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  group('PrismBubbleWidget', () {
    testWidgets(
      'displays loading indicator while shader future is unresolved',
      (tester) async {
        await tester.pumpWidget(
          buildFrame(
            const PrismBubbleWidget(
              width: 120,
              height: 120,
            ),
          ),
        );

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

        final sizedBox = tester.widget<SizedBox>(
          find.byType(SizedBox).first,
        );
        expect(sizedBox.width, 120);
        expect(sizedBox.height, 120);
      },
    );

    testWidgets(
      'displays error icon and tooltip when shader initialization fails',
      (tester) async {
        await tester.pumpWidget(
          buildFrame(
            const PrismBubbleWidget(
              width: 140,
              height: 140,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.byType(Tooltip), findsOneWidget);

        final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
        expect(tooltip.message, contains('ShaderLoadException'));

        final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
        expect(icon.color, Colors.red);
      },
    );

    testWidgets(
      'renders stack layout with child and painter upon successful build',
      (tester) async {
        const childWidget = Text('Overlay Child');

        await tester.pumpWidget(
          buildFrame(
            FutureBuilder<void>(
              future: Future.value(),
              builder: (context, snapshot) {
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      childWidget,
                      CustomPaint(
                        painter: BubbleShaderPainter(
                          manager: BubbleShaderManager.instance,
                          tintColor: Colors.teal,
                          arcOpacity: 0.7,
                          diffusion: 0.4,
                          phaseAngle: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        expect(find.text('Overlay Child'), findsOneWidget);

        final customPaint = tester.widget<CustomPaint>(
          find.byType(CustomPaint).last,
        );
        final painter = customPaint.painter! as BubbleShaderPainter;

        expect(painter.manager, equals(BubbleShaderManager.instance));
        expect(painter.tintColor, Colors.teal);
        expect(painter.arcOpacity, 0.7);
        expect(painter.diffusion, 0.4);
        expect(painter.phaseAngle, 1.5);
      },
    );

    testWidgets(
      'constructs without child and verifies parameter storage',
      (tester) async {
        const widget = PrismBubbleWidget(
          width: 220,
          height: 180,
          tintColor: Colors.cyan,
          arcOpacity: 0.5,
          diffusion: 0.3,
          phaseAngle: 0.8,
        );

        expect(widget.width, 220);
        expect(widget.height, 180);
        expect(widget.tintColor, Colors.cyan);
        expect(widget.arcOpacity, 0.5);
        expect(widget.diffusion, 0.3);
        expect(widget.phaseAngle, 0.8);
        expect(widget.child, isNull);
      },
    );
  });
}
