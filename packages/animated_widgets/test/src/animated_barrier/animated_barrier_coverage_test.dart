// animated_widgets/test/src/animated_barrier/animated_barrier_coverage_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // StatusBarChameleon talks to the host over this channel. Under flutter_test
  // defaultTargetPlatform is android, so setStatusBarHidden clears its platform
  // guard and actually invokes the channel; without this stub every
  // showAsync/dismissAsync call throws MissingPluginException.
  const statusBarChannel = MethodChannel('status_bar_chameleon/status_bar');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(statusBarChannel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(statusBarChannel, null);
  });

  // A BuildContext that lives under a root Overlay (provided by MaterialApp),
  // which is what AnimatedBarrier.show resolves via Overlay.of(rootOverlay:).
  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext hostContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              hostContext = context;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    return hostContext;
  }

  group('AnimatedBarrier.showAsync', () {
    testWidgets('hides the status bar then inserts and shows the overlay', (
      tester,
    ) async {
      final context = await pumpHost(tester);

      const barrier = AnimatedBarrier(child: Text('async-child'));

      final handle = await barrier.showAsync(context);
      await tester.pumpAndSettle();

      expect(handle, isNotNull);
      expect(find.text('async-child'), findsOneWidget);

      handle!.dismiss();
      await tester.pumpAndSettle();
    });
  });

  group('PopoverHandle.dismissAsync', () {
    testWidgets('restores the status bar then dismisses and fires onComplete', (
      tester,
    ) async {
      final context = await pumpHost(tester);

      const barrier = AnimatedBarrier(child: Text('dismiss-child'));

      final handle = barrier.show(context);
      await tester.pumpAndSettle();
      expect(find.text('dismiss-child'), findsOneWidget);

      var completed = false;
      await handle.dismissAsync(onComplete: () => completed = true);
      await tester.pumpAndSettle();

      expect(find.text('dismiss-child'), findsNothing);
      expect(completed, isTrue);
    });
  });

  group('AnimatedBarrier child', () {
    testWidgets('child GestureDetector swallows taps so they never dismiss', (
      tester,
    ) async {
      const childKey = Key('popover-child');
      final context = await pumpHost(tester);

      const barrier = AnimatedBarrier(
        childSize: Size(200, 200),
        child: ColoredBox(
          key: childKey,
          color: Colors.white,
          child: SizedBox(width: 200, height: 200),
        ),
      );

      final handle = barrier.show(context);
      await tester.pumpAndSettle();
      expect(find.byKey(childKey), findsOneWidget);

      // Tap squarely on the child. The child's onTap is the empty swallow
      // closure; the dismissible barrier behind it must NOT receive the tap.
      await tester.tap(find.byKey(childKey));
      await tester.pumpAndSettle();

      expect(find.byKey(childKey), findsOneWidget);

      handle.dismiss();
      await tester.pumpAndSettle();
    });
  });
}
