// test/src/editor_overlay_test.dart
import 'package:edittext_popover/src/_editor_overlay.dart';
import 'package:edittext_popover/src/editor_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditorOverlay', () {
    testWidgets('renders with initial text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditorOverlay(
              initialText: 'hello',
              textStyle: TextStyle(fontSize: 18),
              barrierColor: Colors.black54,
              saveWidget: Text('SAVE'),
              cancelWidget: Text('CANCEL'),
              targetRect: null,
              isFullScreen: true,
            ),
          ),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
    });

    testWidgets('barrier onTap executes without effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditorOverlay(
              initialText: '',
              textStyle: TextStyle(fontSize: 18),
              barrierColor: Colors.black54,
              saveWidget: Text('SAVE'),
              cancelWidget: Text('CANCEL'),
              targetRect: null,
              isFullScreen: false,
            ),
          ),
        ),
      );

      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      expect(find.byType(EditorOverlay), findsOneWidget);
    });

    testWidgets('renders full screen editor when isFullScreen true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditorOverlay(
              initialText: '',
              textStyle: TextStyle(fontSize: 18),
              barrierColor: Colors.black54,
              saveWidget: Text('SAVE'),
              cancelWidget: Text('CANCEL'),
              targetRect: null,
              isFullScreen: true,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders positioned editor when isFullScreen false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditorOverlay(
              initialText: '',
              textStyle: TextStyle(fontSize: 18),
              barrierColor: Colors.black54,
              saveWidget: Text('SAVE'),
              cancelWidget: Text('CANCEL'),
              targetRect: Rect.fromLTWH(100, 100, 200, 50),
              isFullScreen: false,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays barrier with provided color', (tester) async {
      const barrierColor = Color(0x80FF0000);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditorOverlay(
              initialText: '',
              textStyle: TextStyle(fontSize: 18),
              barrierColor: barrierColor,
              saveWidget: Text('SAVE'),
              cancelWidget: Text('CANCEL'),
              targetRect: null,
              isFullScreen: true,
            ),
          ),
        ),
      );

      final coloredBoxes = tester.widgetList<ColoredBox>(
        find.byType(ColoredBox),
      );
      final barrierBox = coloredBoxes.firstWhere(
        (box) => box.color == barrierColor,
        orElse: () => throw StateError('Barrier ColoredBox not found'),
      );
      expect(barrierBox.color, equals(barrierColor));
    });

    testWidgets('tapping barrier does nothing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditorOverlay(
              initialText: '',
              textStyle: TextStyle(fontSize: 18),
              barrierColor: Colors.black54,
              saveWidget: Text('SAVE'),
              cancelWidget: Text('CANCEL'),
              targetRect: null,
              isFullScreen: true,
            ),
          ),
        ),
      );

      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      expect(find.byType(EditorOverlay), findsOneWidget);
    });

    testWidgets('pops EditorCompleted when save tapped', (tester) async {
      EditorResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<EditorResult>(
                    MaterialPageRoute(
                      builder: (_) => const EditorOverlay(
                        initialText: 'test',
                        textStyle: TextStyle(fontSize: 18),
                        barrierColor: Colors.black54,
                        saveWidget: Text('SAVE'),
                        cancelWidget: Text('CANCEL'),
                        targetRect: null,
                        isFullScreen: true,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(result, isA<EditorCompleted>());
      expect(result?.text, equals('test'));
    });

    testWidgets('pops EditorDismissed when cancel tapped', (tester) async {
      EditorResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<EditorResult>(
                    MaterialPageRoute(
                      builder: (_) => const EditorOverlay(
                        initialText: 'test',
                        textStyle: TextStyle(fontSize: 18),
                        barrierColor: Colors.black54,
                        saveWidget: Text('SAVE'),
                        cancelWidget: Text('CANCEL'),
                        targetRect: null,
                        isFullScreen: true,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(result, isA<EditorDismissed>());
      expect(result?.text, equals('test'));
    });

    testWidgets('returns updated text when saved', (tester) async {
      EditorResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<EditorResult>(
                    MaterialPageRoute(
                      builder: (_) => const EditorOverlay(
                        initialText: '',
                        textStyle: TextStyle(fontSize: 18),
                        barrierColor: Colors.black54,
                        saveWidget: Text('SAVE'),
                        cancelWidget: Text('CANCEL'),
                        targetRect: null,
                        isFullScreen: true,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'new text');
      await tester.pump();

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(result, isA<EditorCompleted>());
      expect(result?.text, equals('new text'));
    });

    testWidgets('requests focus on text field after first layout', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditorOverlay(
              initialText: '',
              textStyle: TextStyle(fontSize: 18),
              barrierColor: Colors.black54,
              saveWidget: Text('SAVE'),
              cancelWidget: Text('CANCEL'),
              targetRect: null,
              isFullScreen: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.focusNode?.hasFocus, isTrue);
    });
  });
}
