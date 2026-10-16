// packages/prism_bubble_widget/test/src/prism_bubble_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_bubble_widget/src/bubble_shader_manager.dart';
import 'package:prism_bubble_widget/src/bubble_shader_painter.dart';
import 'package:prism_bubble_widget/src/prism_bubble_widget.dart';

Widget _frame(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

Finder _inBubble(Finder matching) => find.descendant(
  of: find.byType(PrismBubbleWidget),
  matching: matching,
);

BubbleShaderPainter _painter(WidgetTester tester) {
  final customPaint = tester.widget<CustomPaint>(
    _inBubble(find.byType(CustomPaint)),
  );
  return customPaint.painter! as BubbleShaderPainter;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => BubbleShaderManager.instance.resetForTesting());
  tearDown(() => BubbleShaderManager.instance.resetForTesting());

  group('PrismBubbleWidget', () {
    group('constructors', () {
      test('default constructor stores every parameter', () {
        const child = Text('child');
        const widget = PrismBubbleWidget(
          width: 220,
          height: 180,
          isLight: true,
          tintColor: Colors.cyan,
          arcOpacity: 0.5,
          diffusion: 0.3,
          phaseAngle: 0.8,
          child: child,
        );

        expect(widget.width, 220);
        expect(widget.height, 180);
        expect(widget.isLight, isTrue);
        expect(widget.tintColor, Colors.cyan);
        expect(widget.arcOpacity, 0.5);
        expect(widget.diffusion, 0.3);
        expect(widget.phaseAngle, 0.8);
        expect(widget.child, same(child));
      });

      test('default constructor defaults to the dark preset', () {
        const widget = PrismBubbleWidget(width: 10, height: 10);

        expect(widget.isLight, isFalse);
        expect(widget.tintColor, Colors.white);
        expect(widget.arcOpacity, 0.3);
        expect(widget.diffusion, 0.0);
        expect(widget.phaseAngle, 0.0);
        expect(widget.child, isNull);
      });

      test('dark factory forces isLight false and forwards parameters', () {
        const key = Key('dark');
        const child = Text('child');
        final widget = PrismBubbleWidget.dark(
          key: key,
          width: 50,
          height: 60,
          tintColor: Colors.amber,
          arcOpacity: 0.9,
          diffusion: 0.7,
          phaseAngle: 2.1,
          child: child,
        );

        expect(widget.key, key);
        expect(widget.width, 50);
        expect(widget.height, 60);
        expect(widget.isLight, isFalse);
        expect(widget.tintColor, Colors.amber);
        expect(widget.arcOpacity, 0.9);
        expect(widget.diffusion, 0.7);
        expect(widget.phaseAngle, 2.1);
        expect(widget.child, same(child));
      });

      test('dark factory defaults match the default constructor', () {
        final widget = PrismBubbleWidget.dark(width: 10, height: 10);

        expect(widget.isLight, isFalse);
        expect(widget.tintColor, Colors.white);
        expect(widget.arcOpacity, 0.3);
        expect(widget.diffusion, 0.0);
        expect(widget.phaseAngle, 0.0);
      });

      test('light factory forces isLight true and forwards parameters', () {
        const key = Key('light');
        const child = Text('child');
        final widget = PrismBubbleWidget.light(
          key: key,
          width: 50,
          height: 60,
          tintColor: Colors.amber,
          arcOpacity: 0.9,
          diffusion: 0.7,
          phaseAngle: 2.1,
          child: child,
        );

        expect(widget.key, key);
        expect(widget.width, 50);
        expect(widget.height, 60);
        expect(widget.isLight, isTrue);
        expect(widget.tintColor, Colors.amber);
        expect(widget.arcOpacity, 0.9);
        expect(widget.diffusion, 0.7);
        expect(widget.phaseAngle, 2.1);
        expect(widget.child, same(child));
      });

      test('light factory has its own softer defaults', () {
        final widget = PrismBubbleWidget.light(width: 10, height: 10);

        expect(widget.isLight, isTrue);
        expect(widget.tintColor, const Color(0xFFE2E8F0));
        expect(widget.arcOpacity, 0.2);
        expect(widget.diffusion, 0.25);
        expect(widget.phaseAngle, 0.0);
      });
    });

    group('build', () {
      testWidgets('shows a sized progress indicator while init is pending', (
        tester,
      ) async {
        await tester.pumpWidget(
          _frame(const PrismBubbleWidget(width: 120, height: 120)),
        );

        expect(
          _inBubble(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
        final box = tester.widget<SizedBox>(_inBubble(find.byType(SizedBox)));
        expect(box.width, 120);
        expect(box.height, 120);

        // Let init resolve so no shader work is left pending at teardown.
        await tester.pump();
      });

      testWidgets('shows a sized error panel when init fails', (tester) async {
        BubbleShaderManager.programLoader = (_) async =>
            throw Exception('simulated');

        await tester.pumpWidget(
          _frame(const PrismBubbleWidget(width: 140, height: 140)),
        );
        await tester.pump();

        expect(_inBubble(find.byType(CircularProgressIndicator)), findsNothing);
        expect(_inBubble(find.byType(CustomPaint)), findsNothing);

        final box = tester.widget<SizedBox>(_inBubble(find.byType(SizedBox)));
        expect(box.width, 140);
        expect(box.height, 140);

        final text = tester.widget<Text>(_inBubble(find.byType(Text)));
        expect(text.data, startsWith('Shader Load Error:\n'));
        expect(text.data, contains('ShaderLoadException'));
        expect(text.data, contains('simulated'));
        expect(text.textAlign, TextAlign.center);
        expect(text.style?.color, Colors.redAccent);
        expect(text.style?.fontSize, 11);
        expect(text.style?.fontWeight, FontWeight.bold);

        final container = tester.widget<Container>(
          _inBubble(find.byType(Container)),
        );
        expect(container.color, Colors.red.withAlpha(30));
        expect(container.padding, const EdgeInsets.all(8));
      });

      testWidgets(
        'renders the painter beneath nothing when there is no child',
        (tester) async {
          await tester.pumpWidget(
            _frame(const PrismBubbleWidget(width: 100, height: 100)),
          );
          await tester.pump();

          expect(
            _inBubble(find.byType(CircularProgressIndicator)),
            findsNothing,
          );

          final box = tester.widget<SizedBox>(_inBubble(find.byType(SizedBox)));
          expect(box.width, 100);
          expect(box.height, 100);

          final stack = tester.widget<Stack>(_inBubble(find.byType(Stack)));
          expect(stack.fit, StackFit.expand);
          expect(stack.children, hasLength(1));
          expect(stack.children.single, isA<CustomPaint>());
        },
      );

      testWidgets('renders the child beneath the painter and forwards params', (
        tester,
      ) async {
        const childKey = Key('overlay');

        await tester.pumpWidget(
          _frame(
            const PrismBubbleWidget(
              width: 200,
              height: 200,
              isLight: true,
              tintColor: Colors.teal,
              arcOpacity: 0.7,
              diffusion: 0.4,
              phaseAngle: 1.5,
              child: SizedBox(key: childKey),
            ),
          ),
        );
        await tester.pump();

        final stack = tester.widget<Stack>(_inBubble(find.byType(Stack)));
        expect(stack.children, hasLength(2));
        expect(stack.children.first, isA<SizedBox>());
        expect((stack.children.first as SizedBox).key, childKey);
        expect(stack.children.last, isA<CustomPaint>());

        final painter = _painter(tester);
        expect(painter.manager, same(BubbleShaderManager.instance));
        expect(painter.isLight, isTrue);
        expect(painter.tintColor, Colors.teal);
        expect(painter.arcOpacity, 0.7);
        expect(painter.diffusion, 0.4);
        expect(painter.phaseAngle, 1.5);
      });

      testWidgets('rebuilds the painter with new parameters', (tester) async {
        await tester.pumpWidget(
          _frame(
            const PrismBubbleWidget(width: 100, height: 100, diffusion: 0.1),
          ),
        );
        await tester.pump();
        expect(_painter(tester).diffusion, 0.1);

        await tester.pumpWidget(
          _frame(
            const PrismBubbleWidget(width: 100, height: 100, diffusion: 0.9),
          ),
        );
        expect(_painter(tester).diffusion, 0.9);
      });
    });
  });
}
