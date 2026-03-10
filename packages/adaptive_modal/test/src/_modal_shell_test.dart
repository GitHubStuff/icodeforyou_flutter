// test/src/_modal_shell_test.dart
// ignore_for_file: lines_longer_than_80_chars

import 'package:adaptive_modal/src/_modal_shell.dart';
import 'package:adaptive_modal/src/_position_resolver.dart';
import 'package:adaptive_modal/src/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pumps [ModalShell] inside a [Stack] so [Positioned] (large layout) has a
/// valid parent. A bare [Directionality]+[MediaQuery]+[Stack] tree avoids the
/// extra [FadeTransition]/[ScaleTransition] widgets that [MaterialApp] /
/// [Scaffold] inject into the navigation layer.
Future<void> pumpShell(
  WidgetTester tester, {
  Widget child = const SizedBox.shrink(),
  AdaptiveModalPosition position = AdaptiveModalPosition.below,
  AdaptiveModalConfig config = const AdaptiveModalConfig(),
  double animationValue = 1.0,
  VoidCallback? onClose,
  bool isPhone = false,
  double placementLeft = 100,
  double placementTop = 200,
}) async {
  final controller = AnimationController(
    vsync: const TestVSync(),
    value: animationValue,
  );

  final placement = ModalPlacement(
    left: placementLeft,
    top: placementTop,
    position: position,
  );

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1024, 768)),
        child: Stack(
          children: [
            ModalShell(
              placement: placement,
              config: config,
              animation: controller,
              onClose: onClose ?? () {},
              isPhone: isPhone,
              child: child,
            ),
          ],
        ),
      ),
    ),
  );
}

/// First [FadeTransition] descendant of [ModalShell].
FadeTransition shellFade(WidgetTester tester) => tester.widget<FadeTransition>(
      find
          .descendant(
            of: find.byType(ModalShell),
            matching: find.byType(FadeTransition),
          )
          .first,
    );

/// First [ScaleTransition] descendant of [ModalShell].
ScaleTransition shellScale(WidgetTester tester) => tester.widget<ScaleTransition>(
      find
          .descendant(
            of: find.byType(ModalShell),
            matching: find.byType(ScaleTransition),
          )
          .first,
    );

void main() {
  // -------------------------------------------------------------------------
  // ModalShell — renders
  // -------------------------------------------------------------------------

  group('ModalShell renders', () {
    testWidgets('finds ModalShell in tree', (tester) async {
      await pumpShell(tester);
      expect(find.byType(ModalShell), findsOneWidget);
    });

    testWidgets('renders child widget', (tester) async {
      await pumpShell(tester, child: const Text('hello'));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('contains FadeTransition under ModalShell', (tester) async {
      await pumpShell(tester);
      expect(
        find.descendant(of: find.byType(ModalShell), matching: find.byType(FadeTransition)),
        findsWidgets,
      );
    });

    testWidgets('contains ScaleTransition under ModalShell', (tester) async {
      await pumpShell(tester);
      expect(
        find.descendant(of: find.byType(ModalShell), matching: find.byType(ScaleTransition)),
        findsWidgets,
      );
    });
  });

  // -------------------------------------------------------------------------
  // ModalShell — phone layout
  // -------------------------------------------------------------------------

  group('ModalShell phone layout', () {
    testWidgets('uses SafeArea on phone', (tester) async {
      await pumpShell(tester, isPhone: true, position: AdaptiveModalPosition.fullScreen);
      expect(
        find.descendant(of: find.byType(ModalShell), matching: find.byType(SafeArea)),
        findsOneWidget,
      );
    });

    testWidgets('renders child on phone', (tester) async {
      await pumpShell(
        tester,
        isPhone: true,
        position: AdaptiveModalPosition.fullScreen,
        child: const Text('phone content'),
      );
      expect(find.text('phone content'), findsOneWidget);
    });

    testWidgets('renders close button on phone', (tester) async {
      await pumpShell(tester, isPhone: true);
      expect(
        find.descendant(of: find.byType(ModalShell), matching: find.byType(GestureDetector)),
        findsWidgets,
      );
    });
  });

  // -------------------------------------------------------------------------
  // ModalShell — large layout
  // -------------------------------------------------------------------------

  group('ModalShell large layout', () {
    testWidgets('contains Positioned wrapper on large', (tester) async {
      await pumpShell(tester);
      expect(
        find.descendant(of: find.byType(ModalShell), matching: find.byType(Positioned)),
        findsWidgets,
      );
    });

    testWidgets('does not use SafeArea on large', (tester) async {
      await pumpShell(tester);
      expect(
        find.descendant(of: find.byType(ModalShell), matching: find.byType(SafeArea)),
        findsNothing,
      );
    });

    testWidgets('renders child on large', (tester) async {
      await pumpShell(tester, child: const Text('large content'));
      expect(find.text('large content'), findsOneWidget);
    });

    testWidgets('uses ClipRRect on large', (tester) async {
      await pumpShell(tester);
      expect(
        find.descendant(of: find.byType(ModalShell), matching: find.byType(ClipRRect)),
        findsOneWidget,
      );
    });

    testWidgets('SizedBox uses maxWidth and maxHeight from config', (tester) async {
      await pumpShell(
        tester,
        config: const AdaptiveModalConfig(maxWidth: 320, maxHeight: 500),
      );
      final boxes = tester.widgetList<SizedBox>(
        find.descendant(of: find.byType(ModalShell), matching: find.byType(SizedBox)),
      );
      expect(boxes.where((b) => b.width == 320 && b.height == 500), isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // ModalShell — close button
  // -------------------------------------------------------------------------

  group('ModalShell close button', () {
    testWidgets('calls onClose when tapped', (tester) async {
      var closed = false;
      await pumpShell(tester, onClose: () => closed = true);
      await tester.tap(
        find
            .descendant(of: find.byType(ModalShell), matching: find.byType(GestureDetector))
            .first,
      );
      expect(closed, isTrue);
    });

    testWidgets('shows default Icons.close when closeIcon is null', (tester) async {
      await pumpShell(tester);
      expect(
        find.descendant(of: find.byType(ModalShell), matching: find.byIcon(Icons.close)),
        findsOneWidget,
      );
    });

    testWidgets('shows custom closeIcon and hides default', (tester) async {
      await pumpShell(
        tester,
        config: const AdaptiveModalConfig(closeIcon: Icon(Icons.arrow_back_ios_new)),
      );
      expect(
        find.descendant(of: find.byType(ModalShell), matching: find.byIcon(Icons.arrow_back_ios_new)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(ModalShell), matching: find.byIcon(Icons.close)),
        findsNothing,
      );
    });

    testWidgets('calls onClose on phone layout', (tester) async {
      var closed = false;
      await pumpShell(tester, isPhone: true, onClose: () => closed = true);
      await tester.tap(
        find
            .descendant(of: find.byType(ModalShell), matching: find.byType(GestureDetector))
            .first,
      );
      expect(closed, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // ModalShell — animation
  // -------------------------------------------------------------------------

  group('ModalShell animation', () {
    testWidgets('FadeTransition at 1.0 when animation fully forward', (tester) async {
      await pumpShell(tester);
      expect(shellFade(tester).opacity.value, closeTo(1.0, 0.001));
    });

    testWidgets('FadeTransition at 0.0 when animation at start', (tester) async {
      await pumpShell(tester, animationValue: 0);
      expect(shellFade(tester).opacity.value, closeTo(0.0, 0.001));
    });
  });

  // -------------------------------------------------------------------------
  // ModalShell — scale alignment per position
  // -------------------------------------------------------------------------

  group('ModalShell scale alignment', () {
    testWidgets('below uses topCenter alignment', (tester) async {
      await pumpShell(tester);
      expect(shellScale(tester).alignment, Alignment.topCenter);
    });

    testWidgets('above uses bottomCenter alignment', (tester) async {
      await pumpShell(tester, position: AdaptiveModalPosition.above);
      expect(shellScale(tester).alignment, Alignment.bottomCenter);
    });

    testWidgets('fullScreen uses bottomCenter alignment', (tester) async {
      await pumpShell(tester, isPhone: true, position: AdaptiveModalPosition.fullScreen);
      expect(shellScale(tester).alignment, Alignment.bottomCenter);
    });
  });
}
