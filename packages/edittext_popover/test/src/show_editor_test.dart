// test/src/show_editor_test.dart
import 'package:edittext_popover/edittext_popover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class WebPlatformChecker extends PlatformChecker {
  const WebPlatformChecker();

  @override
  bool get isWeb => true;

  @override
  bool get isMobile => false;
}

class MobilePlatformChecker extends PlatformChecker {
  const MobilePlatformChecker();

  @override
  bool get isWeb => false;

  @override
  bool get isMobile => true;
}

class DesktopPlatformChecker extends PlatformChecker {
  const DesktopPlatformChecker();

  @override
  bool get isWeb => false;

  @override
  bool get isMobile => false;
}

void main() {
  group('showEditor', () {
    testWidgets('returns EditorCompleted when save tapped', (tester) async {
      EditorResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showEditor(
                    context: context,
                    initialText: 'hello',
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
      expect(result?.text, equals('hello'));
    });

    testWidgets('returns EditorDismissed when cancel tapped', (tester) async {
      EditorResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showEditor(
                    context: context,
                    initialText: 'hello',
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
      expect(result?.text, equals('hello'));
    });

    testWidgets('uses default empty initial text', (tester) async {
      EditorResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showEditor(context: context);
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

      expect(result?.text, equals(''));
    });

    testWidgets('uses custom text style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showEditor(
                    context: context,
                    textStyle: const TextStyle(fontSize: 24),
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

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.fontSize, equals(24));
    });

    testWidgets('uses custom barrier color', (tester) async {
      const customColor = Color(0x80FF0000);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showEditor(
                    context: context,
                    barrierColor: customColor,
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

      final coloredBoxes = tester.widgetList<ColoredBox>(
        find.byType(ColoredBox),
      );
      final hasBarrierColor = coloredBoxes.any(
        (box) => box.color == customColor,
      );
      expect(hasBarrierColor, isTrue);
    });

    testWidgets('uses custom save widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showEditor(
                    context: context,
                    saveWidget: const Icon(Icons.check),
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

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('uses custom cancel widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showEditor(
                    context: context,
                    cancelWidget: const Icon(Icons.close),
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

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('returns updated text on save', (tester) async {
      EditorResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showEditor(
                    context: context,
                    // ignore: avoid_redundant_argument_values
                    initialText: '',
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

      await tester.enterText(find.byType(TextField), 'updated');
      await tester.pump();

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(result, isA<EditorCompleted>());
      expect(result?.text, equals('updated'));
    });

    testWidgets('returns current text on cancel', (tester) async {
      EditorResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showEditor(
                    context: context,
                    initialText: 'initial',
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

      await tester.enterText(find.byType(TextField), 'modified');
      await tester.pump();

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(result, isA<EditorDismissed>());
      expect(result?.text, equals('modified'));
    });

    testWidgets('returns EditorDismissed when result is null', (tester) async {
      EditorResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showEditor(
                    context: context,
                    initialText: 'fallback',
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

      Navigator.of(tester.element(find.byType(TextField))).pop();
      await tester.pumpAndSettle();

      expect(result, isA<EditorDismissed>());
      expect(result?.text, equals('fallback'));
    });

    testWidgets('uses full screen on web with narrow width', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showEditor(
                    context: context,
                    platformChecker: const WebPlatformChecker(),
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

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('uses positioned editor on web with wide width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showEditor(
                    context: context,
                    platformChecker: const WebPlatformChecker(),
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

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('uses full screen on mobile with small screen', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showEditor(
                    context: context,
                    platformChecker: const MobilePlatformChecker(),
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

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('uses positioned editor on mobile with large screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showEditor(
                    context: context,
                    platformChecker: const MobilePlatformChecker(),
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

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('uses positioned editor on desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showEditor(
                    context: context,
                    platformChecker: const DesktopPlatformChecker(),
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

      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('PlatformChecker', () {
    test('phoneBreakpoint is 600', () {
      expect(PlatformChecker.phoneBreakpoint, equals(600.0));
    });

    test('isWeb returns kIsWeb value', () {
      const checker = PlatformChecker();
      expect(checker.isWeb, isFalse);
    });

    test('isMobile checks Platform.isIOS or Platform.isAndroid', () {
      const checker = PlatformChecker();
      expect(checker.isMobile, isFalse);
    });

    testWidgets('shouldUseFullScreen returns false on desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              const checker = DesktopPlatformChecker();
              final result = checker.shouldUseFullScreen(context);
              return Text('Result: $result');
            },
          ),
        ),
      );

      expect(find.text('Result: false'), findsOneWidget);
    });

    testWidgets('shouldUseFullScreen returns true on web narrow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              const checker = WebPlatformChecker();
              final result = checker.shouldUseFullScreen(context);
              return Text('Result: $result');
            },
          ),
        ),
      );

      expect(find.text('Result: true'), findsOneWidget);
    });

    testWidgets('shouldUseFullScreen returns false on web wide', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              const checker = WebPlatformChecker();
              final result = checker.shouldUseFullScreen(context);
              return Text('Result: $result');
            },
          ),
        ),
      );

      expect(find.text('Result: false'), findsOneWidget);
    });

    testWidgets('shouldUseFullScreen returns true on mobile small', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              const checker = MobilePlatformChecker();
              final result = checker.shouldUseFullScreen(context);
              return Text('Result: $result');
            },
          ),
        ),
      );

      expect(find.text('Result: true'), findsOneWidget);
    });

    testWidgets('shouldUseFullScreen returns false on mobile large', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              const checker = MobilePlatformChecker();
              final result = checker.shouldUseFullScreen(context);
              return Text('Result: $result');
            },
          ),
        ),
      );

      expect(find.text('Result: false'), findsOneWidget);
    });
  });
}
